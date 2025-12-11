local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1296\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["给技能"] = "%s给你%s"
	L["子弹风暴"] = "子弹风暴"
	L["牢笼分配"] = "牢笼%d-%d %s %s"
	L["打断排序"] = "打断排序"
	L["铁板"] = "|cff95b6c6铁板|r"
	L["泥土"] = "|cffd99b38泥土|r"
	L["转"] = "转 %s "
	L["地雷"] = "地雷"
	L["冰靴"] = "冰靴"
	L["大团分担"] = "大团分担"
	L["免疫分担"] = "免疫分担"
elseif G.Client == "ruRU" then
	L["给技能"] = "%s использует %s на вас"
	L["子弹风暴"] = "Пулеметный огонь"
	L["牢笼分配"] = "Тюрьма%d-%d %s %s"
	L["打断排序"] = "Очередь прерываний"
	L["铁板"] = "|cff95b6c6Сталь|r"
	L["泥土"] = "|cffd99b38Земля|r"
	L["转"] = "Перейти на %s "
	L["地雷"] = "Мины"
	L["冰靴"] = "Ледяные сапоги"
	L["大团分担"] = "Основное поглощение"
	L["免疫分担"] = "Поглощение с иммунитетом"
else
	L["给技能"] = "%s uses %s on you"
	L["子弹风暴"] = "Bullet Storm"
	L["牢笼分配"] = "Gaol%d-%d %s %s"
	L["打断排序"] = "InterruptOrder"
	L["铁板"] = "|cff95b6c6Steel|r"
	L["泥土"] = "|cffd99b38Dirt|r"
	L["转"] = "go to %s "
	L["地雷"] = "Mines"
	L["冰靴"] = "Ice boots"
	L["大团分担"] = "Majority Soak"
	L["免疫分担"] = "Immunity Soak"
end

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2645] = {
	engage_id = 3015,
	npc_id = {"229953"},
	alerts = {
		{ -- 胆大妄为
			spells = {
				{466385},
			},
			options = {
				{ -- 图标 胆大妄为
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 466385,
					tip = L["BOSS强化"],
				},
			},
		},
		{ -- 元素屠戮
			spells = {
				{468658},
			},
			options = {
				{ -- 文字 高能量
					category = "TextAlert",
					type = "spell",
					color = {1, .1, .19},
					preview = string.format(L["转"], L["泥土"]).."95",
					data = {
						spellID = 466460,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
							["UNIT_POWER_UPDATE"] = true,
						},	
					},
					update = function(self, event, ...)
						if event == "UNIT_POWER_UPDATE" then
							local unit = ...
							if unit == "boss1" then
								local power = UnitPower("boss1")
								if power >= 90 and AuraUtil.FindAuraBySpellID(466460, "boss1", "HELPFUL") and not self.ignore_start and not self.ignore_switch then -- 顶头大佬：兹伊
									self.text:SetText(string.format(L["转"], L["泥土"])..power)
									self:Show()
								else
									self:Hide()
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and (spellID == 466459 or spellID == 466460) then
								self.ignore_switch = true
								self:Hide()
								C_Timer.After(2, function()
									self.ignore_switch = false
								end)
							end
						elseif event == "ENCOUNTER_START" then
							self.ignore_start = true
							C_Timer.After(10, function()
								self.ignore_start = false
							end)
						end
					end,
				},
				{ -- 计时条 元素屠戮
					category = "AlertTimerbar",
					type = "cast",
					spellID = 468658,
					color = {.8, .94, .55},
				},
				{ -- 图标 元素灾祸
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 468663,
					tip = L["DOT"],
				},
			},
		},
		{ -- 失控毁灭
			spells = {
				{468694},
			},
			options = {
				{ -- 文字 高能量
					category = "TextAlert",
					type = "spell",
					color = {1, .1, .19},
					preview = string.format(L["转"], L["铁板"]).."95",
					data = {
						spellID = 466459,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
							["UNIT_POWER_UPDATE"] = true,
						},	
					},
					update = function(self, event, ...)
						if event == "UNIT_POWER_UPDATE" then
							local unit = ...
							if unit == "boss1" then
								local power = UnitPower("boss1")
								if power >= 90 and AuraUtil.FindAuraBySpellID(466459, "boss1", "HELPFUL") and not self.ignore_start and not self.ignore_switch then -- 顶头大佬：穆格
									self.text:SetText(string.format(L["转"], L["铁板"])..power)
									self:Show()
								else
									self:Hide()
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and (spellID == 466459 or spellID == 466460) then
								self.ignore_switch = true
								self:Hide()
								C_Timer.After(2, function()
									self.ignore_switch = false
								end)
							end
						elseif event == "ENCOUNTER_START" then
							self.ignore_start = true
							C_Timer.After(10, function()
								self.ignore_start = false
							end)
						end
					end,
				},
				{ -- 计时条 失控毁灭
					category = "AlertTimerbar",
					type = "cast",
					spellID = 468694,
					color = {1, .44, .25},
				},
				{ -- 图标 失控燃烧
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 469715,
					tip = L["DOT"],
				},
			},
		},
		{ -- 鲁莽怒火
			spells = {
				{1216142, "4"},
			},
			options = {
				{ -- 图标 鲁莽怒火
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 1216142,
					tip = L["BOSS狂暴"],
					hl = "red",
				},
			},
		},
		{ -- 穆格：震地牢狱			
			spells = {
				{472631, "5"},
			},
			npcs = {
				{31739},
			},
			options = {
				{ -- 计时条 震地牢狱
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 472631,
					dur = 6,
					color = {.98, .79, .33},
				},
				{ -- 首领模块 震地牢狱 MRT轮次分配
					category = "BossMod",
					spellID = 474461,
					ficon = "12",
					enable_tag = "everyone",
					name = string.format(L["NAME点名位置分配"], T.GetIconLink(474461)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = 205, y = 100, width = 240, height = 110},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["JST_CUSTOM"] = true,
						["ADDON_MSG"] = true,
					},
					custom = {
						{
							key = "preview_index_dd",
							text = L["预览轮次"],
							default = 2,
							key_table = {
								{2, "2"},
								{3, "3"},
								{4, "4"},
							},
							apply = function(value, frame)
								frame:UpdatePreviewInfo()
							end,
						},
						{
							key = "rl_bool",
							text = L["团队分配"],
							default = false,
							apply = function(value, frame)
								if value then
									frame.group_status:display(2, {{G.PlayerGUID, G.PlayerGUID}, {G.PlayerGUID, G.PlayerGUID}})
									frame.group_status.enable = true
									T.RestoreDragFrame(frame.group_status, frame)
								else
									frame.group_status.enable = false
									frame.group_status:Hide()
									T.ReleaseDragFrame(frame.group_status)
								end
							end,
						},
						{
							key = "mrt_custom_btn",
							text = L["粘贴MRT模板"],
						},
					},
					init = function(frame)
						T.GetScaleCustomData(frame)
						
						frame.assignment = {}
						frame.rescue_caster = {}
						frame.rescue_assigned = {}
						frame.affected = {}
						frame.voidelf_cds = {}
						frame.rescue_cds = {}
						frame.spell_ready = {}
						frame.set = 0
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						frame.text_frame2 = T.CreateAlertTextShared("bossmod"..frame.config_id.."-rescue", 1)

						frame.graphs = {}
						frame.graph_bg = CreateFrame("Frame", nil, frame)
						frame.graph_bg:SetAllPoints(frame)
						frame.graph_bg:Hide()
						
						frame.graph_tex_info = {
							hot_mess = {layer = "BACKGROUND", sub_layer = 2, tex = G.media.circle, color = {1, .29, .18}, w = 70, h = 70, points = {"TOP", 0, 0}},
							
							gaol1 = {layer = "BACKGROUND", sub_layer = 1, tex = G.media.ring, color = {1, .87, .42}, w = 50, h = 50, points = {"TOP", -50, -25}}, -- 左近
							gaol2 = {layer = "BACKGROUND", sub_layer = 1, tex = G.media.ring, color = {1, .87, .42}, w = 50, h = 50, points = {"TOP", -95, -55}}, -- 左远
							gaol3 = {layer = "BACKGROUND", sub_layer = 1, tex = G.media.ring, color = {1, .87, .42}, w = 50, h = 50, points = {"TOP", 50, -25}}, -- 右近
							gaol4 = {layer = "BACKGROUND", sub_layer = 1, tex = G.media.ring, color = {1, .87, .42}, w = 50, h = 50, points = {"TOP", 95, -55}}, -- 右近
							
							pos1 = {layer = "BACKGROUND", sub_layer = 3, tex = G.media.circle, color = {.22, .93, .3}, w = 45, h = 45, points = {"TOP", -50, -28}},
							pos2 = {layer = "BACKGROUND", sub_layer = 3, tex = G.media.circle, color = {.22, .93, .3}, w = 45, h = 45, points = {"TOP", -95, -57}},
							pos3 = {layer = "BACKGROUND", sub_layer = 3, tex = G.media.circle, color = {.22, .93, .3}, w = 45, h = 45, points = {"TOP", 50, -28}},
							pos4 = {layer = "BACKGROUND", sub_layer = 3, tex = G.media.circle, color = {.22, .93, .3}, w = 45, h = 45, points = {"TOP", 95, -57}},
							
							mark1 = {layer = "ARTWORK", rm = 1, w = 30, points = {"TOP", -50, -20}},
							mark2 = {layer = "ARTWORK", rm = 2, w = 30, points = {"TOP", -95, -45}},						
							mark3 = {layer = "ARTWORK", rm = 3, w = 30, points = {"TOP", 50, -20}},
							mark4 = {layer = "ARTWORK", rm = 4, w = 30, points = {"TOP", 95, -45}},
						}
						
						T.UpdateGraphTextures(frame, frame.graph_bg)
						
						frame.info = {
							[2] = {
								{index = 1, rm = 4, sound = "left", msg = L["左"]},
								{index = 3, rm = 7, sound = "right", msg = L["右"]},
							},
							[3] = {
								{index = 1, rm = 1, sound = "nearleft", msg = L["左近"]},
								{index = 2, rm = 2, sound = "farleft", msg = L["左远"]},
								{index = 3, rm = 3, sound = "right", msg = L["右"]},
							},
							[4] = {
								{index = 1, rm = 5, sound = "nearleft", msg = L["左近"]},
								{index = 2, rm = 1, sound = "farleft", msg = L["左远"]},
								{index = 3, rm = 6, sound = "nearright", msg = L["右近"]},
								{index = 4, rm = 2, sound = "farright", msg = L["右远"]},
							},
						}						
						
						local classes = {
							PRIEST = true,
							DRUID = true,
							SHAMAN = false,
							PALADIN = true,
							WARRIOR = false,
							MAGE = true,
							WARLOCK = true,
							HUNTER = false,
							ROGUE = false,
							DEATHKNIGHT = true,
							MONK = true,
							DEMONHUNTER = true,
							EVOKER = true,
						}

						local races = {
							VoidElf = true,
						}
						
						function frame:copy_mrt()
							local players = {}
							local raidlist = ""
							
							for unit in T.IterateGroupMembers() do
								if #players <= 4 then
									local name = UnitName(unit)
									table.insert(players, T.ColorNameForMrt(name))
								end
							end
							
							for i = 2, 4 do
								for k = 1, i do
									local rm = frame.info[i][k].rm
									local str = string.format("[%d:%s]{rt%d} %s", i, k, rm, table.concat(players, " "))
									raidlist = raidlist..str.."\n"
								end
								raidlist = raidlist.."\n"
								if i == 4 then
									local priest = T.GetClassMrtStr("PRIEST")
									local evoker = T.GetClassMrtStr("EVOKER")
									raidlist = raidlist..string.format("[%s] %s %s\n", L["救人"], priest, evoker)
								end
							end
							
							local spellName = C_Spell.GetSpellName(self.config_id)
							raidlist = string.format("#%dstart%s\n%send", self.config_id, spellName, raidlist)
							
							return raidlist
						end
						
						function frame:GetAssignmentByMrt()
							self.assignment = table.wipe(self.assignment)
							
							local text = C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1
							local tag = string.format("#%dstart", self.config_id)
							
							if text then
								local betweenLine
								for line in text:gmatch('[^\r\n]+') do
									if line == "end" then
										betweenLine = false
									end
									if betweenLine then
										local gaolCount, gaolNumber = string.match(line, "%[(%d):(%d)%]")
										if gaolCount and gaolNumber then
											gaolCount = tonumber(gaolCount)
											gaolNumber = tonumber(gaolNumber)
											
											if self.info[gaolCount] and self.info[gaolCount][gaolNumber] then
												if not self.assignment[gaolCount] then
													self.assignment[gaolCount] = {}
												end
												if not self.assignment[gaolCount][gaolNumber] then
													self.assignment[gaolCount][gaolNumber] = {}
												end
												for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
													local info = T.GetGroupInfobyName(name)
													if info then
														table.insert(self.assignment[gaolCount][gaolNumber], info.GUID)
													else
														T.msg(string.format(L["昵称错误"], name))
													end
												end
											end
										end
										
										if string.find(line, L["救人"]) then
											for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
												local info = T.GetGroupInfobyName(name)
												if info then
													if not frame.spell_ready[info.GUID] then
														table.insert(frame.rescue_caster, info.GUID)
														
														frame.spell_ready[info.GUID] = {}
														
														local class = select(2, UnitClass(info.unit))
														for spellID, cd_type in pairs(G.ClassShareSpellData[class]) do
															if cd_type == "rescue" then
																frame.spell_ready[info.GUID][spellID] = 1
															end
														end
													end
												else
													T.msg(string.format(L["昵称错误"], name))
												end
											end
										end
									end
									if line:match(tag) then
										betweenLine = true
									end
								end
							end
						end
						
						function frame:CreateDefaultStates(gaolCount)	
							for i = 1, 4 do
								frame.graphs["gaol"..i]:SetAlpha(0)
								frame.graphs["mark"..i]:SetAlpha(0)
							end
								
							for i, info in pairs(frame.info[gaolCount]) do
								frame.graphs["gaol"..info.index]:SetAlpha(1)
								frame.graphs["mark"..info.index]:SetAlpha(1)
								SetRaidTargetIconTexture(frame.graphs["mark"..info.index].rm_tex, info.rm)
							end
						end
						
						function frame:Assign(gaolCount, gaolNumber, affected, different, preview)
							local info = frame.info[gaolCount] and frame.info[gaolCount][gaolNumber]
							
							if not info then return end
							
							if not preview then
								local color = different and "|cffff0000" or "|cffffffff"
								
								T.Start_Text_Timer(frame.text_frame, 6, string.format("%s%s%s|r", T.FormatRaidMark(info.rm), color, info.msg), true)
								T.PlaySound(info.sound)
								
								if affected then	
									T.SendChatMsg(info.msg, 6)
								end
							end
							
							for i = 1, 4 do
								local tex = frame.graphs["pos"..i]
								if i == info.index then
									tex:SetAlpha(1)
								else
									tex:SetAlpha(0)
								end
							end
						end

						function frame:UpdateAssignment()
							self.set = self.set + 1
							T.SortTable(self.affected)
							
							local gaolCount = #self.affected
							local gaolAssignments = {}
							local regularAssignedGUIDs = {}
							local playerAffected = tContains(self.affected, G.PlayerGUID)
							local playerPreferredGaol

							if self.assignment[gaolCount] then
								for i, GUIDs in pairs(self.assignment[gaolCount]) do
									gaolAssignments[i] = GUIDs
								end
								if #gaolAssignments < gaolCount then return end
							end
							
							-- 记录分担组的人
							for _, gaolGUIDs in ipairs(gaolAssignments) do
								for _, GUID in ipairs(gaolGUIDs) do
									regularAssignedGUIDs[GUID] = true
								end
							end
							
							-- 获取预期牢笼序号，仅为区别是否为预期，改变文字颜色
							for gaolNumber, gaolGUIDs in ipairs(gaolAssignments) do
								if tContains(gaolGUIDs, G.PlayerGUID) then
									playerPreferredGaol = gaolNumber
									break
								end
							end
							
							local hasAffectedGUID = {}
							
							-- 分担组中有人被点
							for gaolNumber, gaolGUIDs in ipairs(gaolAssignments) do
								for _, GUID in ipairs(gaolGUIDs) do
									if tContains(self.affected, GUID) then
										hasAffectedGUID[gaolNumber] = true
										break
									end
								end
							end
							
							-- 分配非分担组法师到空牢笼
							for _, affectedGUID in ipairs(self.affected) do
								local info = T.GetGroupInfobyGUID(affectedGUID)
								if info and info.class == "MAGE" and not regularAssignedGUIDs[info.GUID] then
									for gaolNumber, gaol in ipairs(gaolAssignments) do
										if not hasAffectedGUID[gaolNumber] then
											table.insert(gaol, affectedGUID)
											hasAffectedGUID[gaolNumber] = true
											break
										end
									end
								end
							end
							
							-- 调剂序号向后找
							for gaolNumber, gaolGUIDs in ipairs(gaolAssignments) do
								local affectedPlayers = 0
								
								for guidNumber, GUID in ipairs(gaolGUIDs) do
									if tContains(self.affected, GUID) then
										affectedPlayers = affectedPlayers + 1
										
										-- 如果一组里有超过一人被点，则和后面的组里同序号的人交换组
										if affectedPlayers > 1 then
											local swapped = false
											
											-- 和后面的组里同序号的人交换组，先找同序号有人的
											for otherGaolNumber, otherGaolGUIDs in ipairs(gaolAssignments) do
												-- 选择空的牢笼
												if gaolNumber ~= otherGaolNumber and not hasAffectedGUID[otherGaolNumber] then
													local otherGUID = otherGaolGUIDs[guidNumber]
													
													if otherGUID then -- 先找同序号有人的
														
														gaolGUIDs[guidNumber] = otherGUID
														otherGaolGUIDs[guidNumber] = GUID
														
														affectedPlayers = affectedPlayers - 1
														
														hasAffectedGUID[otherGaolNumber] = true
														
														swapped = true
														
														break
													end
												end
											end
											
											-- 和后面的组里同序号的人交换，或者后面组这个序号为空也行
											if not swapped then
												for otherGaolNumber, otherGaolGUIDs in ipairs(gaolAssignments) do
													-- 选择空的牢笼
													if gaolNumber ~= otherGaolNumber and not hasAffectedGUID[otherGaolNumber] then
														local otherGUID = otherGaolGUIDs[guidNumber]
														
														-- 交换
														gaolGUIDs[guidNumber] = otherGUID
														otherGaolGUIDs[guidNumber] = GUID
														
														affectedPlayers = affectedPlayers - 1
														
														hasAffectedGUID[otherGaolNumber] = true
														
														break
													end
												end
											end
										end
									end
								end
							end
							
							-- 从受影响的玩家列表中剔除已分配牢笼的
							for _, gaolGUIDs in ipairs(gaolAssignments) do
								for _, GUID in ipairs(gaolGUIDs) do
									tDeleteItem(self.affected, GUID)
								end
							end
							
							-- 剩下还没分配的，分配到剩余的空牢笼里面去
							for _, affectedGUID in ipairs(self.affected) do
								for gaolNumber, gaol in ipairs(gaolAssignments) do
									if not hasAffectedGUID[gaolNumber] then
										table.insert(gaol, affectedGUID)
										
										hasAffectedGUID[gaolNumber] = true
										
										break
									end
								end
							end
							
							-- Replace dead people?
							
							T.FireEvent("JST_CUSTOM", self.config_id, "ASSIGNMENT", gaolCount, gaolAssignments)
							
							for gaolNumber, GUIDs in ipairs(gaolAssignments) do
								for _, GUID in pairs(GUIDs) do
									if GUID == G.PlayerGUID then
										self:CreateDefaultStates(gaolCount)
										self:Assign(gaolCount, gaolNumber, playerAffected, playerPreferredGaol and playerPreferredGaol ~= gaolNumber)
										self.graph_bg:Show()
										C_Timer.After(6, function()
											self.graph_bg:Hide()
										end)
										T.FireEvent("JST_CUSTOM", self.config_id, "INTERRUPT", gaolCount, gaolNumber, GUIDs)
									end
									
									local info = T.GetGroupInfobyGUID(GUID)
									local debuffed = AuraUtil.FindAuraBySpellID(472631, info.unit, "HARMFUL")
									T.msg(string.format(L["牢笼分配"], gaolCount, gaolNumber, info.format_name, debuffed and L["被点"] or ""))
									
									T.FireEvent("JST_CUSTOM", self.config_id, "RESCUE", GUID, self.info[gaolCount][gaolNumber].rm)
								end
							end
							
							self.affected = table.wipe(self.affected)
						end
						
						function frame:Filter(GUID)
							local info = T.GetGroupInfobyGUID(GUID)
							local unit = info and info.unit
							if unit then
								local class = select(2, UnitClass(unit))
								local race = select(2, UnitRace(unit))
								
								if classes[class] then
									return false
								elseif races[race] then
									if self.voidelf_cds[GUID] then
										local remain = self.voidelf_cds[GUID] - GetTime()
										if remain <= 8 then
											return false
										else
											return true
										end
									end
								else
									return true
								end
							end
						end
						
						function frame:GetRescueSpellID(unit)
							local class = select(2, UnitClass(unit))
							for spellID, cd_type in pairs(G.ClassShareSpellData[class]) do
								if cd_type == "rescue" then
									return spellID
								end
							end	
						end
						
						function frame:CheckCooldown(GUID)
							for spellID, charge in pairs(self.spell_ready[GUID]) do
								if charge > 0 then
									return true
								end
							end
						end
						
						function frame:GetNextAssign()
							for _, GUID in pairs(self.rescue_caster) do
								local info = T.GetGroupInfobyGUID(GUID)
								local unit = info and info.unit
								if unit and not self.rescue_assigned[GUID] then
									local alive = not UnitIsDeadOrGhost(unit)
									local connected = UnitIsConnected(unit)
									local visible = UnitIsVisible(unit)
									local cd_check = self:CheckCooldown(GUID)
									local debuffed = AuraUtil.FindAuraBySpellID(1215760, unit, "HARMFUL")
									
									--print(UnitName(unit), "存活", alive, "在线", connected, "可见", visible, "技能可用", cd_check)
									
									if alive and connected and visible and cd_check and not debuffed then
										self.rescue_assigned[GUID] = true
										return GUID
									end
								end
							end
						end
						
						T.CreateMovableFrame(frame, "group_status", 300, 80, {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 20, y = -200}, "_Group", L["团队分配"])
						frame.group_status.text = T.createtext(frame.group_status, "OVERLAY", 16, "OUTLINE", "LEFT", "TOP")
						frame.group_status.text:SetPoint("TOPLEFT", frame.group_status, "TOPLEFT", 0, 0)
						frame.group_status:Hide()
						
						function frame.group_status:display(gaolCount, gaolAssignments)
							local str = ""
							for gaolNumber, GUIDs in ipairs(gaolAssignments) do
								if gaolNumber > 1 then
									str = str.."\n"
								end
								
								local rm = frame.info[gaolCount][gaolNumber].rm
								str = str..T.FormatRaidMark(rm)
								
								for _, GUID in ipairs(GUIDs) do
									str = str.." "..T.GetGroupInfobyGUID(GUID)["format_name"]
								end
							end
							
							self.text:SetText(str)
						end
						
						T.CreateMovableFrame(frame, "interrupt_frame", 150, 100, {a1 = "TOPLEFT", a2 = "CENTER", x = 450, y = 100}, "_Interrupt", L["打断排序"])
						frame.interrupt_frame:Hide()
						frame.interrupt_str = {}
						frame.interrupt_subframes = {}
						
						frame.cantinterrupt = {
							[256] = true, -- Discipline (Heal)
							[257] = true, -- Holy (Heal)
						}
						
						function frame:GetInterruptSubFrame(index, name)
							if self.interrupt_subframes[index] then
								local f = self.interrupt_subframes[index]
								
								f.str:SetText(f.index..name)
								f.mark:Hide()
								
								f:Show()
								
								return f
							else
								local f = CreateFrame("Frame", nil, self.interrupt_frame)
								f:SetSize(150, 25)
								f.index = index
								
								if index == 1 then
									f:SetPoint("TOPLEFT", self.interrupt_frame, "TOPLEFT", 0, 0)
								else
									f:SetPoint("TOPLEFT", self.interrupt_subframes[index-1], "BOTTOMLEFT", 0, -2)
								end
								
								f.str = T.createtext(f, "OVERLAY", 20, "OUTLINE", "LEFT")
								f.str:SetPoint("LEFT", f, "LEFT", 0, 0)
								f.str:SetText(f.index..name)
								
								f.mark = f:CreateTexture(nil, "ARTWORK")
								f.mark:SetTexture(G.media.red_arrow)
								f.mark:SetRotation(.5*math.pi)
								f.mark:SetPoint("LEFT", f.str, "RIGHT", 0, 0)
								f.mark:Hide()
								
								self.interrupt_subframes[index] = f
								
								return f
							end
						end
						
						function frame:DisplayInterruptOrder(GUIDs)
							for _, GUID in ipairs(GUIDs) do
								local info = T.GetGroupInfobyGUID(GUID)
								if self.cantinterrupt[info.spec_id] then
									tDeleteItem(GUIDs, GUID) -- 移除不能打断的专精
								end
							end
							
							table.sort(
								GUIDs,
								function (GUID1, GUID2)
									if not GUID1 then return false end
									if not GUID2 then return true end
									
									local info1 = T.GetGroupInfobyGUID(GUID1)
									local info2 = T.GetGroupInfobyGUID(GUID1)
										
									local type1, spec1, role1 = info1.pos, info1.spec_id, info1.role
									local type2, spec2, role2 = info2.pos, info2.spec_id, info2.role
									   
									if role1 and role2 and role1 ~= role2 then
										return role1 == "HEALER"
									elseif type1 and type2 and type1 ~= type2 then
										return type1 == "MELEE"
									elseif spec1 and spec2 and spec1 ~= spec2 then
										return spec1 < spec2
									else
										return GUID1 < GUID2
									end
								end
							)
							
							self.interrupt_str = table.wipe(self.interrupt_str)
							
							for i, f in pairs(self.interrupt_subframes) do
								f:Hide()
							end
							
							for i, GUID in pairs(GUIDs) do
								local info = T.GetGroupInfobyGUID(GUID)
								local f = self:GetInterruptSubFrame(i, info.format_name)
							end
							
							self.interrupt_frame:Show()
						end
						
						function frame:UpdatePreviewInfo()
							local gaolCount = C.DB["BossMod"][self.config_id]["preview_index_dd"]
							local goalNumber = 2
							
							self:CreateDefaultStates(gaolCount)
							self:Assign(gaolCount, goalNumber, false, false, true)
						end
						
						function frame:PreviewShow()
							self:UpdatePreviewInfo()
							self.graph_bg:Show()
							
							self:DisplayInterruptOrder({G.PlayerGUID, G.PlayerGUID})
							
							if C.DB["BossMod"][self.config_id]["rl_bool"] then
								self.group_status:Show()
								self.group_status:display(2, {{G.PlayerGUID, G.PlayerGUID}, {G.PlayerGUID, G.PlayerGUID}})
							end
						end
						
						function frame:PreviewHide()
							self.graph_bg:Hide()
							
							self.interrupt_frame:Hide()
							for i, f in pairs(self.interrupt_subframes) do
								f:Hide()
							end
							
							if C.DB["BossMod"][self.config_id]["rl_bool"] then
								self.group_status:Hide()
								self.group_status.text:SetText("")
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 472631 then -- 震地牢狱
								table.insert(frame.affected, destGUID)		
								if #frame.affected == 1 then
									C_Timer.After(0.4, function()
										frame:UpdateAssignment()
									end)
								end
							end
						elseif event == "JST_CUSTOM" then
							local id, key = ...
							if id == frame.config_id then
								if key == "RESCUE" then
									local GUID, rm = select(3, ...)
									if frame:Filter(GUID) then
										local sourceGUID = frame:GetNextAssign()
										if sourceGUID then
											local caster_info = T.GetGroupInfobyGUID(sourceGUID)
											local dest_info = T.GetGroupInfobyGUID(GUID)
											local spellID = frame:GetRescueSpellID(caster_info.unit)
											
											if sourceGUID == G.PlayerGUID then
												T.PlaySound("rescue", "mark\\mark"..rm)
												T.Start_Text_Timer(frame.text_frame2, 5, string.format("%s%s%s", T.GetIconLink(spellID), T.FormatRaidMark(rm), dest_info.format_name), true)
												T.GlowRaidFramebyUnit_Show("proc", "bm"..frame.config_id, dest_info.unit, {0, 1, 0}, 5)
											end
											
											T.msg(string.format("%s%s%s%s", caster_info.format_name, T.GetIconLink(spellID), T.FormatRaidMark(rm), dest_info.format_name))
										end
									end
								elseif key == "INTERRUPT" then
									local gaolCount, gaolNumber, GUIDs =  select(3, ...)
									frame:DisplayInterruptOrder(GUIDs)
								elseif key == "ASSIGNMENT" then
									local gaolCount, gaolAssignments =  select(3, ...)
									if C.DB["BossMod"][frame.config_id]["rl_bool"] then
										frame.group_status:display(gaolCount, gaolAssignments)
										frame.group_status:Show()
										C_Timer.After(6, function()
											frame.group_status:Hide()
										end)
									end
								end
							end
						elseif event == "ADDON_MSG" then
							local channel, sender, GUID, message = ...
							if message == "ShareSpellState" then
								local spellID, charge = select(5, ...)
								spellID = tonumber(spellID)
								charge = tonumber(charge)
								if frame.spell_ready[GUID] and frame.spell_ready[GUID][spellID] then
									frame.spell_ready[GUID][spellID] = charge
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.set = 0
							frame.affected = table.wipe(frame.affected)
							
							frame:GetAssignmentByMrt()
						end
					end,
					reset = function(frame, event)
						frame.spell_ready = table.wipe(frame.spell_ready)
						frame.graph_bg:Hide()
						frame.interrupt_frame:Hide()
						frame.group_status:Hide()
						for i, f in pairs(frame.interrupt_subframes) do
							f:Hide()
						end
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},
				{ -- 图标 震地牢狱
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 472631,
					hl = "org_flash",
				},
				{ -- 图标 震地牢狱
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1215760,
					hl = "",
				},
				{ -- 首领模块 小怪血量 加乐宫恶棍
					category = "BossMod",
					spellID = 1214623,
					enable_tag = "rl",
					name = string.format(L["NAME小怪血量"], T.GetFomattedNameFromNpcID("233474")),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 20, y = -300},
					events = {
						["ENCOUNTER_SHOW_BOSS_UNIT"] = true,
						["ENCOUNTER_HIDE_BOSS_UNIT"] = true,
						["UNIT_HEALTH"] = true,
						["RAID_TARGET_UPDATE"] = true,
					},
					init = function(frame)
						frame.npcIDs = {
							["233474"] = {color = {.95, .84, .54}}, -- 加乐宫恶棍
						}					
						
						T.InitMobHealth(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateMobHealth(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetMobHealth(frame)
					end,
				},
				{ -- 姓名板打断图标 致敬
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 472782,
					mobID = "233474",
					interrupt = 3,
					ficon = "6",
				},
				{ -- 图标 震动大地
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 474554,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 穆格：霜裂冰靴
			spells = {
				{466476},
			},
			options = {
				{ -- 文字 霜裂冰靴 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.25, .78, .98},
					preview = L["冰靴"]..L["倒计时"],
					data = {
						spellID = 466470,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},					
						info = {							
							[15] = {
								[2] = {37},
								[3] = {18, 86},
							},
							[16] = {
								[2] = {37},
								[3] = {18, 86},
							},
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 466470, L["冰靴"], self, event, ...)
					end,
				},
				{ -- 计时条 霜裂冰靴
					category = "AlertTimerbar",
					type = "cast",
					spellID = 466470,
					spellIDs = {1232971},
					color = {.25, .78, .98},
					sound = soundfile("466470cast", "cast"),
				},
				{ -- 计时条 霜裂长矛
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 466476,
					options_spellIDs = {466480},
					dur = 8,
					target_me = true,
					color = {.52, .61, 1},
					icon_tex = 135855,
					text = C_Spell.GetSpellName(466480),
				},
				{ -- 图标 霜裂冰靴
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 466476,
					hl = "org_flash",
				},
				{ -- 声音 霜裂冰靴 移除
					category = "Sound",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 466476,
					target_me = true,
					file = "[sound_water]",	
				},
				{ -- 首领模块 霜裂冰靴 方向分配
					category = "BossMod",
					spellID = 466476,
					enable_tag = "everyone",
					name = L["自动分配"]..T.GetIconLink(466476),
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.affected = {}
						frame.set = 0
						frame.aura_spellID = 466476
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						frame.text_frame.count_down_start = 3
						
						frame.assignment_local = {
							left = "←"..L["左"].."←",
							right = "→"..L["右"].."→",
						}
						
						function frame:GetAssignmentByMrt()
							self.set = self.set + 1
							
							if self.set == 2 then
								T.SortTable(self.affected)
							else
								T.SortTable(self.affected, true)
							end
							
							local totalAssignments = #self.affected
							for index, GUID in pairs(self.affected) do
								
								local assignment
								
								if index <= (totalAssignments / 2) then
									assignment = "left"
								else
									assignment = "right"
								end
								
								local info = T.GetGroupInfobyGUID(GUID)
								local icon = T.GetSpellIcon(466476)
								local dir_text = self.assignment_local[assignment]
																
								T.msg(string.format("%s %d %s %s", T.GetIconLink(466476), index, info.format_name, dir_text))
								
								if G.PlayerGUID == GUID then
									T.Start_Text_Timer(self.text_frame, 7.7, string.format("%s %s %s", icon, dir_text, icon), true)
									T.PlaySound(assignment)
								end
							end
							
							self.affected = table.wipe(self.affected)
						end
					end,	
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == frame.aura_spellID then
								table.insert(frame.affected, destGUID)
            
								if #frame.affected == 1 then
									C_Timer.After(0.3, function()
										frame:GetAssignmentByMrt()
									end)
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.affected = table.wipe(frame.affected)
							frame.set = 0
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},
			},
		},
		{ -- 穆格：风暴手指枪
			spells = {
				{466509},
			},
			options = {
				{ -- 计时条 风暴手指枪
					category = "AlertTimerbar",
					type = "cast",
					spellID = 466509,
					color = {.01, .26, .85},
					text = L["冲击波"],
					show_tar = true,
					glow = true,
				},
				{ -- 图标 风暴手指枪
					category = "AlertIcon",
					type = "com",
					unit = "player",
					spellID = 466509,
					hl = "org_flash",
				},
				{ -- 团队框架图标 风暴手指枪
					category = "RFIcon",
					type = "Cast",
					spellID = 466509,
				},
				{ -- 首领模块 给技能提示 风暴手指枪
					category = "BossMod",
					spellID = 466509,
					enable_tag = "everyone",
					name = string.format(L["NAME点名提示和减伤分配"], T.GetIconLink(466509)),
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_SPELLCAST_START"] = true,
						["JST_CUSTOM"] = true,
					},
					custom = {
						{
							key = "mrt_custom_btn",
							text = L["粘贴MRT模板"],
						},
					},
					init = function(frame)
						frame.cast_spellID = 466509
						frame.spell = C_Spell.GetSpellName(frame.cast_spellID)
						
						frame.text_frames = {}
						frame.assignment = {}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						frame.figure = T.CreateRingCD(frame, {.07, 1, 1})
						
						function frame:copy_mrt()
							local str, raidlist = "", ""
							
							local i = 0
							for class, info in pairs(G.ClassShareSpellData) do
								for spellID, tag in pairs(info) do
									if tag == "protect" then
										i = i + 1
										if mod(i, 2) == 1 then
											raidlist = raidlist..string.format("[%d] %s{spell:%d}", ceil(i/2), T.GetClassMrtStr(class), spellID)
										else
											raidlist = raidlist..string.format(" %s{spell:%d}", T.GetClassMrtStr(class), spellID).."\n"
										end
									end
								end
							end
							
							str = string.format("#%sstart%s\n%send\n", frame.config_id, frame.spell, raidlist)
							
							return str
						end
						
						function frame:GetAssignmentByMrt()
							self.assignment = table.wipe(self.assignment)
							
							local text = C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1
							local tag = string.format("#%dstart", self.config_id)
							
							if text then
								local betweenLine
								for line in text:gmatch('[^\r\n]+') do
									if line == "end" then
										betweenLine = false
									end
									if betweenLine then
										local index_str = string.match(line, "%[(.+)%]")
										local index = index_str and tonumber(index_str)
										if index then
											if not self.assignment[index] then
												self.assignment[index] = {}
											end
											
											local info = {}
											local line = gsub(line, " ", "")
											for name_str, spellID_str in line:gmatch("||c%x%x%x%x%x%x%x%x([^|]+)||r{spell:([^}]+)}") do
												local spellID = tonumber(spellID_str)
												if spellID and C_Spell.GetSpellName(spellID) then
													local info = T.GetGroupInfobyName(name_str)
													if info then
														table.insert(self.assignment[index], {GUID = info.GUID, spellID = spellID})
													else
														T.msg(string.format(L["昵称错误"], name_str))
													end
												else
													T.msg(string.format(L["法术错误"], spellID_str))
												end
											end
										end
									end
									if line:match(tag) then
										betweenLine = true
									end
								end
							end
						end
						
						function frame:PreviewShow()
							self.figure:begin(GetTime() + 6.5, 6.5, {{dur = 4, color = {1, 1, 0}}})
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
						if event == "JST_CUSTOM" then
							local id, key = ...
							if id == frame.config_id then
								local destGUID = UnitGUID("boss1target")
								
								if destGUID == G.PlayerGUID then
									T.Start_Text_Timer(frame.text_frame, 7, T.GetIconLink(frame.cast_spellID)..L["点你"], true)
									frame.figure:begin(GetTime() + 6.5, 6.5, {{dur = 4, color = {1, 1, 0}}})
									T.PlaySound("1296\\466509cast") -- [音效:手指枪点你]
									T.SendChatMsg("{rt6}{rt6}{rt6}", 6)
								end
								
								local assignment = frame.assignment[frame.count]
								if assignment then
									for i, info in pairs(assignment) do	
										local sourceInfo = T.GetGroupInfobyGUID(info.GUID)
										local destInfo = T.GetGroupInfobyGUID(destGUID)
										
										if info.GUID == G.PlayerGUID then
											T.FormatAskedSpell(destGUID, info.spellID, 3)
										elseif destGUID == G.PlayerGUID then
											if not frame.text_frames[i] then
												frame.text_frames[i] = T.CreateAlertTextShared("bossmod"..frame.config_id.."-"..i, 1)
											end

											T.Start_Text_Timer(frame.text_frames[i], 3, string.format(L["给技能"], sourceInfo.format_name, T.GetIconLink(info.spellID)))
										end
										
										T.msg(string.format("%s[%d]%s%s%s", T.GetIconLink(frame.cast_spellID), frame.count, sourceInfo.format_name, T.GetIconLink(info.spellID), destInfo.format_name))
									end
								end
							end
						elseif event == "UNIT_SPELLCAST_START" then
							local unit, cast_GUID, cast_spellID = ...
							if unit == "boss1" and cast_spellID == frame.cast_spellID then
								if not frame.last_cast or GetTime() - frame.last_cast > 5 then
									frame.last_cast = GetTime()
									frame.count = frame.count + 1
									
									C_Timer.After(.3, function()
										T.FireEvent("JST_CUSTOM", frame.config_id)
									end)
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.count = 0
							frame.last_cast = 0
							
							frame:GetAssignmentByMrt()
						end
					end,
					reset = function(frame, event)
						for i, text in pairs(frame.text_frames) do
							T.Stop_Text_Timer(text)
						end
						T.Stop_Text_Timer(frame.text_frame)
						frame.figure:stop()
					end,
				},
			},
		},
		{ -- 穆格：熔火真金指虎
			spells = {
				{466518, "0"},
			},
			options = {
				{ -- 计时条 熔火真金指虎
					category = "AlertTimerbar",
					type = "cast",
					spellID = 466518,
					color = {.01, .26, .85},
					ficon = "0",
					show_tar = true,
					sound = "[knockback]cast",
				},
				{ -- 图标 纯金滴露
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 467202,
					hl = "org",
					ficon = "0",
				},
				{ -- 首领模块 换坦光环
					category = "BossMod",
					spellID = 467202,
					enable_tag = "role",
					ficon = "0",
					name = string.format(L["NAME换坦技能提示"], T.GetIconLink(467202)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.spellIDs = {
							[467202] = { -- 纯金滴露
								color = {.91, .96, .04},
							},
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
				{ -- 图标 熔火真金池
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 470089,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 兹伊：不稳定的蛛形地雷
			spells = {
				{466539, "5"},
			},
			options = {
				{ -- 文字 不稳定的蛛形地雷 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.76, .8, .78},
					preview = L["地雷"]..L["倒计时"],
					data = {
						spellID = 472458,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[1] = {14},
								[3] = {4, 29},
							},
							[16] = {
								[1] = {14},
								[3] = {4, 29},
							},
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 472458, L["地雷"], self, event, ...)
					end,
				},
				{ -- 计时条 不稳定的蛛形地雷
					category = "AlertTimerbar",
					type = "cast",
					spellID = 472458,
					color = {.76, .8, .78},
					sound = "[bomb]cast",
				},
				{ -- 计时条 不稳定的蛛形地雷 接圈
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_REMOVED",
					spellID = 1219283,
					dur = 4.85,
					color = {.56, .39, 1},
					text = L["接圈"],
					copy = true,
				},
				{ -- 首领模块 撞雷 计时圆圈
					category = "BossMod",
					spellID = 1219283,
					enable_tag = "spell",
					name = T.GetIconLink(1219283)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1219283] = { -- 实验性护板
								event = "SPELL_AURA_REMOVED",
								dur = 1.5,
								color = {.56, .38, 1},
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
				{ -- 声音 锁定
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 472354,
					private_aura = true,
					file = "[bombonyou]",
				},
				{ -- 图标 灼烧弹片
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 469043,
					effect = 1,
					hl = "",
					tip = L["吸收治疗"].."+"..L["DOT"],
				},
				{ -- 文字 灼烧弹片 团队DEBUFF数量
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					color = {1, .3, .1},
					preview = T.GetIconLink(469043)..L["计数"],
					data = {
						spellID = 469043,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},	
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 469043 then
								self.count = self.count + 1
								self.text:SetText(string.format("%s %d", L["吸收盾"], self.count))
								if self.count == 0 then
									self.text:Hide()
								else
									self.text:Show()
								end
							elseif (sub_event == "SPELL_AURA_REMOVED" or sub_event == "SPELL_AURA_REMOVED_DOSE") and spellID == 469043 then
								self.count = self.count - 1
								self.text:SetText(string.format("%s %d", L["吸收盾"], self.count))
								if self.count == 0 then
									self.text:Hide()
								else
									self.text:Show()
								end
							end
						elseif event == "ENCOUNTER_START" then
							self.count = 0
						end
					end,
				},
				{ -- 文字 灼烧弹片 血量过低提示
					category = "TextAlert",
					type = "spell",
					color = {1, 0, 0},
					preview = L["血量过低"],
					data = {
						spellID = 472354,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
						sound = "[defense]",
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if (sub_event == "SPELL_AURA_APPLIED" or sub_event == "SPELL_AURA_APPLIED_DOSE") and spellID == 469043 and destGUID == G.PlayerGUID then
								local hp = UnitHealth("player")
								local hp_max = UnitHealthMax("player")
								local perc = hp/hp_max*100
								if perc <= 30 then
									local absorb = UnitGetTotalHealAbsorbs("player")/10000
									if absorb > 0 then
										T.Start_Text_Timer(self, 3, string.format("%s %d%% |cff0ba7f9%s %dw|r", L["血量过低"], prec, L["吸收盾"], absorb))
									else
										T.Start_Text_Timer(self, 3, string.format("%s %d%%", L["血量过低"], prec))
									end
								end
							end
						end
					end,
				},
				{ -- 首领模块 团队吸收量计时条 灼烧弹片
					category = "BossMod",
					spellID = 472458,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环数值提示"], L["吸收治疗"]),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 350},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 8
						
						frame.spellIDs = {
							[469043] = { -- 灼烧弹片 M 193w/层
								aura_type = "HARMFUL",
								color = {1, .16, .04},
								effect = 1,
								progress_value = 4000000,
							},
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
				{ -- 图标 不稳定的蛛形地雷
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 472061,
					tip = L["易伤"].."500%",
				},
				{ -- 首领模块 姓名板标记 不稳定的蛛形地雷
					category = "BossMod",
					spellID = 472061,
					enable_tag = "none",
					name = string.format(L["NAME姓名板标记"], T.GetNameFromNpcID("231788")),
					points = {hide = true},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
					},
					custom = {
						{
							key = "test_btn", 
							text = L["测试姓名板标记"],
							onclick = function(alert)
								T.ShowAllNameplateExtraTex("bomb")
								C_Timer.After(3, function()
									T.HideAllNameplateExtraTex()
								end)
							end
						},
					},
					init = function(frame)
						frame.mobID = "231788"
					end,
					update = function(frame, event, ...)
						if event == "NAME_PLATE_UNIT_ADDED" then
							local unit = ...
							local GUID = UnitGUID(unit)
							local npcID = select(6, strsplit("-", GUID))
							if npcID == frame.mobID then
								T.ShowNameplateExtraTex(unit, "bomb")
							end
						end
					end,
					reset = function(frame, event)
						T.HideAllNameplateExtraTex()
					end,
				},
			},
		},
		{ -- 兹伊：地精制导火箭
			spells = {
				{467381},
			},
			npcs = {
				{31761},
			},
			options = {
				{ -- 计时条 地精制导火箭
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 467380,
					dur = 8,
					color = {.91, .38, .31},
				},
				{ -- 文字 分担组
					category = "TextAlert",
					type = "spell",
					color = {.91, .38, .31},
					preview = L["大团分担"].."/"..L["免疫分担"],
					data = {
						spellID = 467380,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},	
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 467380 then
								self.spell_count = self.spell_count + 1								
								if mod(self.spell_count, 2) == 1 then
									T.Start_Text_Timer(self, 8, L["大团分担"], true)
								else
									T.Start_Text_Timer(self, 8, L["免疫分担"], true)
								end
							end
						elseif event == "ENCOUNTER_START" then
							self.spell_count = 0
						end
					end,
				},
				{ -- 图标 地精制导火箭
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 467380,
					hl = "org_flash",
				},
				{ -- 图标 衰变光束
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1215488,
					hl = "red",
					tip = L["强力DOT"],
				},
				{ -- 图标 烫手污物
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 472057,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
				{ -- 图标 辐射疫病
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 469076,
					hl = "",
					tip = L["易伤"].."500%",
				},
			},
		},
		{ -- 兹伊：祈祷与乱射
			spells = {
				{466545},
			},
			options = {
				{ -- 计时条 祈祷与乱射
					category = "AlertTimerbar",
					type = "cast",
					spellID = 466545,
					color = {.78, .31, .04},
					text = L["冲击波"],
					show_tar = true,
					glow = true,
				},
				{ -- 图标 祈祷与乱射
					category = "AlertIcon",
					type = "com",
					unit = "player",
					spellID = 466545,
					hl = "org_flash",
				},
				{ -- 团队框架图标 祈祷与乱射
					category = "RFIcon",
					type = "Cast",
					spellID = 466545,
				},
				{ -- 图标 祈祷与乱射
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 466545,
					hl = "",
					tip = L["强力DOT"],
					ficon = "13",
				},
				{ -- 首领模块 给技能提示 祈祷与乱射
					category = "BossMod",
					spellID = 466545,
					enable_tag = "everyone",
					name = string.format(L["NAME点名提示和减伤分配"], T.GetIconLink(466545)),
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_SPELLCAST_START"] = true,
						["JST_CUSTOM"] = true,
					},
					custom = {
						{
							key = "mrt_custom_btn",
							text = L["粘贴MRT模板"],
						},
					},
					init = function(frame)
						frame.cast_spellID = 466545
						frame.spell = C_Spell.GetSpellName(frame.cast_spellID)
						
						frame.text_frames = {}
						frame.assignment = {}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						frame.figure = T.CreateRingCD(frame, {1, 0, 0})
						
						function frame:copy_mrt()
							local str, raidlist = "", ""
							
							local i = 0
							for class, info in pairs(G.ClassShareSpellData) do
								for spellID, tag in pairs(info) do
									if tag == "protect" then
										i = i + 1
										if mod(i, 2) == 1 then
											raidlist = raidlist..string.format("[%d] %s{spell:%d}", ceil(i/2), T.GetClassMrtStr(class), spellID)
										else
											raidlist = raidlist..string.format(" %s{spell:%d}", T.GetClassMrtStr(class), spellID).."\n"
										end
									end
								end
							end
							
							str = string.format("#%sstart%s\n%send\n", frame.config_id, frame.spell, raidlist)
							
							return str
						end
						
						function frame:GetAssignmentByMrt()
							self.assignment = table.wipe(self.assignment)
							
							local text = C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1
							local tag = string.format("#%dstart", self.config_id)
							
							if text then
								local betweenLine
								for line in text:gmatch('[^\r\n]+') do
									if line == "end" then
										betweenLine = false
									end
									if betweenLine then
										local index_str = string.match(line, "%[(.+)%]")
										local index = index_str and tonumber(index_str)
										if index then
											if not self.assignment[index] then
												self.assignment[index] = {}
											end
											
											local info = {}
											local line = gsub(line, " ", "")
											for name_str, spellID_str in line:gmatch("||c%x%x%x%x%x%x%x%x([^|]+)||r{spell:([^}]+)}") do
												local spellID = tonumber(spellID_str)
												if spellID and C_Spell.GetSpellName(spellID) then
													local info = T.GetGroupInfobyName(name_str)
													if info then
														table.insert(self.assignment[index], {GUID = info.GUID, spellID = spellID})
													else
														T.msg(string.format(L["昵称错误"], name_str))
													end
												else
													T.msg(string.format(L["法术错误"], spellID_str))
												end
											end
										end
									end
									if line:match(tag) then
										betweenLine = true
									end
								end
							end
						end
						
						function frame:PreviewShow()
							self.figure:begin(GetTime() + 6.5, 6.5, {{dur = 2.5, color = {1, 1, 0}}})
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
						if event == "JST_CUSTOM" then
							local id, key = ...
							if id == frame.config_id then
								local destGUID = UnitGUID("boss1target")
								
								if destGUID == G.PlayerGUID then
									T.Start_Text_Timer(frame.text_frame, 6.5, T.GetIconLink(frame.cast_spellID)..L["点你"], true)
									frame.figure:begin(GetTime() + 6.5, 6.5, {{dur = 2.5, color = {1, 1, 0}}})
									T.PlaySound("1296\\466545cast") -- [音效:乱射点你]
									T.SendChatMsg("{rt8}{rt8}{rt8}", 6)
								end
								
								local assignment = frame.assignment[frame.count]
								if assignment then
									for i, info in pairs(assignment) do	
										local sourceInfo = T.GetGroupInfobyGUID(info.GUID)
										local destInfo = T.GetGroupInfobyGUID(destGUID)
										
										if info.GUID == G.PlayerGUID then
											T.FormatAskedSpell(destGUID, info.spellID, 3)
										elseif destGUID == G.PlayerGUID then
											if not frame.text_frames[i] then
												frame.text_frames[i] = T.CreateAlertTextShared("bossmod"..frame.config_id.."-"..i, 1)
											end

											T.Start_Text_Timer(frame.text_frames[i], 3, string.format(L["给技能"], sourceInfo.format_name, T.GetIconLink(info.spellID)))
										end
										
										T.msg(string.format("%s[%d]%s%s%s", T.GetIconLink(frame.cast_spellID), frame.count, sourceInfo.format_name, T.GetIconLink(info.spellID), destInfo.format_name))
									end
								end
							end
						elseif event == "UNIT_SPELLCAST_START" then
							local unit, cast_GUID, cast_spellID = ...
							if unit == "boss1" and cast_spellID == frame.cast_spellID then
								if not frame.last_cast or GetTime() - frame.last_cast > 5 then
									frame.last_cast = GetTime()
									frame.count = frame.count + 1
									
									C_Timer.After(.3, function()
										T.FireEvent("JST_CUSTOM", frame.config_id)
									end)
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.count = 0
							frame.last_cast = 0
							
							frame:GetAssignmentByMrt()
						end
					end,
					reset = function(frame, event)
						for i, text in pairs(frame.text_frames) do
							T.Stop_Text_Timer(text)
						end
						T.Stop_Text_Timer(frame.text_frame)
						frame.figure:stop()
					end,
				},		
			},
		},
		{ -- 兹伊：Mk II型电击振荡器
			npcs = {
				{31766},
			},
			options = {
				{ -- 首领模块 弧光激涌 计时圆圈
					category = "BossMod",
					spellID = 1215991,
					enable_tag = "none",
					name = T.GetIconLink(1214991)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_TARGET"] = true,
					},
					init = function(frame)
						frame.cast_spellID = 1214991
						
						frame.figure = T.CreateRingCD(frame, {.2, 1, .8})
						
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
						if event == "UNIT_TARGET" then
							local unit = ...
							if unit then
								local _, _, _, _, _, _, _, _, spellID = UnitCastingInfo(unit)
								
								if spellID and spellID == 1214991 then -- 弧光激涌
									local target_unit = T.GetTarget(unit)
									if target_unit and UnitIsUnit(target_unit, "player") then
										if not frame.last_cast or GetTime() - frame.last_cast > 2 then
											frame.last_cast = GetTime()
											
											if AuraUtil.FindAuraBySpellID(472631, "player", "HARMFUL") then return end -- 震地牢狱
											if AuraUtil.FindAuraBySpellID(469369, "player", "HARMFUL") then return end -- 祈祷与乱射
											if AuraUtil.FindAuraBySpellID(1225933, "player", "HARMFUL") then return end -- 风暴手指枪
											if AuraUtil.FindAuraBySpellID(467380, "player", "HARMFUL") then return end -- 地精制导火箭
											
											frame.figure:begin(GetTime() + 3, 3)
											T.PlaySound("spread")
										end
									end
								end
							end
						end
					end,
					reset = function(frame, event)
						frame.figure:stop()
					end,
				},
				{ -- 首领模块 小怪血量 Mk II型电击振荡器
					category = "BossMod",
					spellID = 1214991,
					enable_tag = "rl",
					name = string.format(L["NAME小怪血量"], T.GetFomattedNameFromNpcID("230316")),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 20, y = -400},
					events = {
						["ENCOUNTER_SHOW_BOSS_UNIT"] = true,
						["ENCOUNTER_HIDE_BOSS_UNIT"] = true,
						["UNIT_HEALTH"] = true,
						["UNIT_AURA"] = true,
						["RAID_TARGET_UPDATE"] = true,
					},
					init = function(frame)
						frame.npcIDs = {
							["230316"] = {color = {.46, .6, .93}}, -- Mk II型电击振荡器
						}
						
						frame.auras = {
							[1215595] = { -- 故障导线
								aura_type = "HELPFUL",
							},
							[1222948] = { -- 电气充能护盾
								aura_type = "HELPFUL",
								color = {0, .6, 1},
							},
						}
						
						T.InitMobHealth(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateMobHealth(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetMobHealth(frame)
					end,
				},
			},
		},
		{ -- 兹伊：双厄射击
			spells = {
				{469490, "0"},
			},
			options = {
				{ -- 计时条 双厄射击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1223085,
					color = {.95, .31, .09},
					show_tar = true,
				},
				{ -- 图标 双厄射击
					category = "AlertIcon",
					type = "bmsg",
					spellID = 469490,
					event = "CHAT_MSG_RAID_BOSS_WHISPER",
					boss_msg = "spell:469490",
					hl = "org_flash",
					dur = 6,
				},
				{ -- 团队框架图标 双厄射击
					category = "RFIcon",
					type = "Cast",
					spellID = 469491,
				},
				{ -- 图标 贯通创伤
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 469391,
					hl = "",
					tip = L["DOT"],
					ficon = "13",
				},
				{ -- 图标 炸药载荷
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 469375,
					hl = "red_flash",
					tip = L["大圈"],
				},
				{ -- 首领模块 给技能提示 炸药载荷
					category = "BossMod",
					spellID = 469375,
					enable_tag = "everyone",
					name = string.format(L["NAME点名提示和减伤分配"], T.GetIconLink(1223085)),
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["CHAT_MSG_RAID_BOSS_WHISPER"] = true,
						["ADDON_MSG"] = true,
					},
					custom = {
						{
							key = "mrt_custom_btn",
							text = L["粘贴MRT模板"],
						},
					},
					init = function(frame)
						frame.cast_spellID = 1223085 -- 双厄射击
						frame.aura_spellID = 469375 -- 炸药载荷
						frame.spell = C_Spell.GetSpellName(frame.aura_spellID)
						
						frame.text_frames = {}
						frame.assignment = {}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						frame.figure = T.CreateRingCD(frame, {1, .42, .1})
												
						function frame:copy_mrt()
							local str, raidlist = "", ""
							
							local i = 0
							for class, info in pairs(G.ClassShareSpellData) do
								for spellID, tag in pairs(info) do
									if tag == "protect" then
										i = i + 1
										if mod(i, 2) == 1 then
											raidlist = raidlist..string.format("[%d] %s{spell:%d}", ceil(i/2), T.GetClassMrtStr(class), spellID)
										else
											raidlist = raidlist..string.format(" %s{spell:%d}", T.GetClassMrtStr(class), spellID).."\n"
										end
									end
								end
							end
							
							str = string.format("#%sstart%s\n%send\n", frame.config_id, frame.spell, raidlist)
							
							return str
						end
						
						function frame:GetAssignmentByMrt()
							self.assignment = table.wipe(self.assignment)
							
							local text = C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1
							local tag = string.format("#%dstart", self.config_id)
							
							if text then
								local betweenLine
								for line in text:gmatch('[^\r\n]+') do
									if line == "end" then
										betweenLine = false
									end
									if betweenLine then
										local index_str = string.match(line, "%[(.+)%]")
										local index = index_str and tonumber(index_str)
										if index then
											if not self.assignment[index] then
												self.assignment[index] = {}
											end
											
											local info = {}
											local line = gsub(line, " ", "")
											for name_str, spellID_str in line:gmatch("||c%x%x%x%x%x%x%x%x([^|]+)||r{spell:([^}]+)}") do
												local spellID = tonumber(spellID_str)
												if spellID and C_Spell.GetSpellName(spellID) then
													local info = T.GetGroupInfobyName(name_str)
													if info then
														table.insert(self.assignment[index], {GUID = info.GUID, spellID = spellID})
													else
														T.msg(string.format(L["昵称错误"], name_str))
													end
												else
													T.msg(string.format(L["法术错误"], spellID_str))
												end
											end
										end
									end
									if line:match(tag) then
										betweenLine = true
									end
								end
							end
						end
						
						function frame:PreviewShow()
							for k, v in pairs({1, .42, .1}) do
								self.figure.color[k] = v
							end
							self.figure:begin(GetTime() + 5.5, 5.5)
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
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == frame.cast_spellID then
								if destGUID == G.PlayerGUID then
									T.Start_Text_Timer(frame.text_frame, 6, T.GetIconLink(frame.aura_spellID), true)
									for k, v in pairs({1, 1, 0}) do
										frame.figure.color[k] = v
									end
									frame.figure:begin(GetTime() + 6, 6)
								end
							end
							
						elseif event == "ADDON_MSG" then
							local channel, sender, destGUID, message = ...
							if message == "spell:469490" then
								frame.count = frame.count + 1
								
								local destInfo = T.GetGroupInfobyGUID(destGUID)								
								local assignment = frame.assignment[frame.count]
								
								if destInfo and assignment then
									for i, info in pairs(assignment) do	
										local sourceInfo = T.GetGroupInfobyGUID(info.GUID)
										
										if info.GUID == G.PlayerGUID then
											T.FormatAskedSpell(destGUID, info.spellID, 6)
										elseif destGUID == G.PlayerGUID then
											if not frame.text_frames[i] then
												frame.text_frames[i] = T.CreateAlertTextShared("bossmod"..frame.config_id.."-"..i, 1)
											end

											T.Start_Text_Timer(frame.text_frames[i], 6, string.format(L["给技能"], sourceInfo.format_name, T.GetIconLink(info.spellID)))
										end
										
										T.msg(string.format("%s[%d]%s%s%s", T.GetIconLink(frame.aura_spellID), frame.count, sourceInfo.format_name, T.GetIconLink(info.spellID), destInfo.format_name))
									end
								end
							end
						elseif event == "CHAT_MSG_RAID_BOSS_WHISPER" then
							local msg = ...
							if string.find(msg, "spell:469490") then
								T.addon_msg("spell:469490", "GROUP")
								T.PlaySound("1296\\1223085cast") -- [音效:双厄射击点你]
								T.SendChatMsg("{rt7}{rt7}{rt7}", 5)
								
								T.Start_Text_Timer(frame.text_frame, 5.5, T.GetIconLink(frame.cast_spellID)..L["点你"], true)
								for k, v in pairs({1, .42, .1}) do
									frame.figure.color[k] = v
								end
								frame.figure:begin(GetTime() + 5.5, 5.5)
							end
						elseif event == "ENCOUNTER_START" then
							frame.count = 0
							
							frame:GetAssignmentByMrt()
						end
					end,
					reset = function(frame, event)
						for i, text in pairs(frame.text_frames) do
							T.Stop_Text_Timer(text)
						end
						T.Stop_Text_Timer(frame.text_frame)
						frame.figure:stop()
					end,
				},
			},
		},
		{ -- 电刑矩阵
			spells = {
				{1216495, "12"},
			},
			options = {
				{ -- 血量
					category = "TextAlert", 
					type = "hp",
					data = {
						npc_id = "231075",
						ranges = {
							{ ul = 44, ll = 40.1, tip = L["阶段转换"]..string.format(L["血量2"], 40)},
						},
					},
				},
				{ -- 计时条 电刑矩阵
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1217791,
					color = {.03, .37, .9},
				},
			},
		},
		{ -- 静电充能
			spells = {
				{1215953},
			},
			options = {
				{ -- 计时条 静电充能
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1215953,
					color = {.85, .89, .67},
				},
				{ -- 计时条 子弹风暴
					category = "AlertTimerbar",
					type = "cast",
					spellID = 471419,
					color = {.82, .2, .14},
				},
				{ -- 文字 静电充能 倒计时
					category = "TextAlert",
					type = "spell",
					color = {1, 0, 0},
					preview = C_Spell.GetSpellName(1215953),
					data = {
						spellID = 1215953,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
						sound = "[mindcharge]",
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 1217791 then -- 电刑矩阵
								T.Start_Text_DelayTimer(self, 10, L["冲锋"], true)
							elseif sub_event == "SPELL_CAST_START" and spellID == 1215953 then -- 静电充能
								self.count = self.count + 1
								if self.count < 3 then
									T.Start_Text_DelayTimer(self, 14, L["冲锋"], true)
								end
							end
						elseif event == "ENCOUNTER_START" then
							self.count = 0
							self.round = true
							self.show_time = 5
							self.prepare_sound = "mindcharge"
							
							if C.DB["TextAlert"]["spell"][self.data.spellID]["sound_bool"] then
								self.count_down_start = 5							
							else
								self.count_down_start = nil
							end
						end
					end,
				},
				{ -- 首领模块 方向提示 静电充能
					category = "BossMod",
					spellID = 1215953,
					enable_tag = "none",
					name = string.format(L["NAME示意图"], T.GetIconLink(1215953)),
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = 0, width = 400, height = 100},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					custom = {
						{
							key = "format_dd",
							text = L["文字提示"],
							default = 2,
							key_table = {
								{1, L["左"].."/"..L["右"]},
								{2, L["顺时针"].."/"..L["逆时针"]},
							},
							apply = function(value, frame)
								frame:UpdatePreviewInfo()
							end,
						},
					},
					init = function(frame)
						T.GetScaleCustomData(frame)
						
						frame.format = {
							{L["左"], L["右"]},
							{L["顺时针"], L["逆时针"]},
						}
						
						frame.graph_bg = CreateFrame("Frame", nil, frame)
						frame.graph_bg:SetAllPoints(frame)
						frame.graph_bg:Hide()
						
						frame.graph_tex_info = { -- 按表格生成示意图图案
							left_arrow = {layer = "BACKGROUND", atlas = "poi-traveldirections-arrow2", fade = true, w = 150, h = 150, points = {"LEFT", 0, 0}},
							right_arrow = {layer = "BACKGROUND", atlas = "poi-traveldirections-arrow2", fade = true, w = 150, h = 150, points = {"RIGHT", 0, 0}},
							str = {layer = "ARTWORK", text = "", w = 400, h = 20, fs = 20, points = {"CENTER", 0, 0}},
						}
						
						T.UpdateGraphTextures(frame, frame.graph_bg, true)
						
						function frame:Show_Arrows(clockwise, preview)
							self.clockwise = clockwise
							
							local str_format = C.DB["BossMod"][self.config_id]["format_dd"]
							
							if clockwise then
								self.graphs.left_arrow.tex:SetVertexColor(0, 1, 0)
								self.graphs.right_arrow.tex:SetVertexColor(0, 1, 0)
								self.graphs.left_arrow.tex:SetTexCoord(1, 0, 0, 1)
								self.graphs.right_arrow.tex:SetTexCoord(0, 1, 1, 0)
							else
								self.graphs.left_arrow.tex:SetVertexColor(1, 0, 0)
								self.graphs.right_arrow.tex:SetVertexColor(1, 0, 0)
								self.graphs.left_arrow.tex:SetTexCoord(1, 0, 1, 0)
								self.graphs.right_arrow.tex:SetTexCoord(0, 1, 0, 1)
							end
							
							self.graphs.str.t = 0
							self.graphs.str.text:SetText("")
							self.graphs.str.exp_time = GetTime() + 3
							
							self.graphs.str:SetScript("OnUpdate", function(s, e)
								s.t = s.t + e
								if s.t > 0.05 then
									s.remain = s.exp_time - GetTime()
									if s.remain > 0 then
										if clockwise then
											s.text:SetText(string.format("|cff00ff00%s|r %s %.1f", self.format[str_format][1], L["子弹风暴"], s.remain))
										else
											s.text:SetText(string.format("|cffff0000%s|r %s %.1f", self.format[str_format][2], L["子弹风暴"], s.remain))
										end
									else
										s:SetScript("OnUpdate", nil)
										self.graph_bg:Hide()
									end
									s.t = 0
								end
							end)
							
							if not preview then
								T.PlaySound(clockwise and "clockwise" or "anticlockwise")
							end
							
							self.graph_bg:Show()
						end
						
						function frame:UpdatePreviewInfo()
							if T.IsInPreview() then
								local str_format = C.DB["BossMod"][self.config_id]["format_dd"]
								if self.clockwise then
									self.graphs.str.text:SetText(string.format("|cff00ff00%s|r %s", self.format[str_format][1], L["子弹风暴"]))
								else
									self.graphs.str.text:SetText(string.format("|cffff0000%s|r %s", self.format[str_format][2], L["子弹风暴"]))
								end
							end
						end
						
						function frame:PreviewShow()
							frame:Show_Arrows(math.random(2)==1, true)
						end
						
						function frame:PreviewHide()
							self.graph_bg:Hide()
						end						
					end,	
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 1215953 then -- 静电充能
								frame.count = frame.count + 1
								
								if frame.count == 2 then
									frame:Show_Arrows(false)
								else
									frame:Show_Arrows(true)
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.count = 0
						end
					end,
					reset = function(frame, event)
						frame.graph_bg:Hide()
						frame.graphs.str:SetScript("OnUpdate", nil)
						frame:Hide()
					end,
				},
			},
		},
		{ -- 阶段转换
			title = L["阶段转换"],
			options = {
				{
					category = "PhaseChangeData",
					phase = 1,					
					type = "CLEU",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 466460, -- 顶头大佬：兹伊
				},
				{
					category = "PhaseChangeData",
					phase = 2,					
					type = "CLEU",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 466459, -- 顶头大佬：穆格
				},
				{
					category = "PhaseChangeData",
					phase = 2.5,					
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 1217791, -- 电刑矩阵
				},
				{
					category = "PhaseChangeData",
					phase = 3,					
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 463967, -- 嗜血
				},
			},
		},
	},
}