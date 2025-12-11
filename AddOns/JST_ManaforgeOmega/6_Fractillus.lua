local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1302\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["出墙"] = "出墙"
	L["消墙"] = "消墙"
	L["坦克出墙"] = "坦克出墙"
	L["出墙消墙位置分配"] = "出墙、消墙位置分配"
	L["安全区文字持续时间"] = "安全区文字持续时间"
	L["提前5秒提示坦克墙位置"] = "提前5秒提示坦克墙位置"
	L["放墙错误"] = "%s 放墙位置出错(%s)，实际放在了%s。"
	L["消墙错误"] = "%s 消墙位置出错(%s)，实际消了%s。"
	L["显示方向和距离"] = "显示方向和距离"
	L["格子数"] = "%d格"
	L["下个坦克墙"] = "下个坦克墙"
elseif G.Client == "ruRU" then
	--L["出墙"] = "Spawn wall"
	--L["消墙"] = "Break wall"
	--L["坦克出墙"] = "Tank Spawn wall"
	--L["出墙消墙位置分配"] = "Spawn/break wall assignment"
	--L["安全区文字持续时间"] = "Safe spot display duration"
	--L["提前5秒提示坦克墙位置"] = "Notify the tank wall position 5 seconds in advance"
	--L["放墙错误"] = "%s wall placement error (%s), actually placed in %s."
	--L["消墙错误"] = "%s wall break position error (%s), actually breaked %s."
	--L["显示方向和距离"] = "Display direction and distance"
	--L["格子数"] = "%d column"
	--L["下个坦克墙"] = "Next tank wall"
else
	L["出墙"] = "Spawn wall"
	L["消墙"] = "Break wall"
	L["坦克出墙"] = "Tank Spawn wall"
	L["出墙消墙位置分配"] = "Spawn/break wall assignment"
	L["安全区文字持续时间"] = "Safe spot display duration"
	L["提前5秒提示坦克墙位置"] = "Notify the tank wall position 5 seconds in advance"
	L["放墙错误"] = "%s wall spawn position error(%s), actually spawned %s."
	L["消墙错误"] = "%s wall break position error (%s), actually breaked %s."
	L["显示方向和距离"] = "Display direction and distance"
	L["格子数"] = "%d column"
	L["下个坦克墙"] = "Next tank wall"
end
---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------

local event_frame = CreateFrame("Frame")
event_frame:RegisterEvent("ZONE_CHANGED")
event_frame:RegisterEvent("PLAYER_ENTERING_WORLD")

event_frame.player_pos = {}
event_frame.spellIDToColumn = {
	[1223493] = 1, -- Column F Aura
	[1223489] = 2, -- Column E Aura
	[1223486] = 3, -- Column D Aura
	[1223485] = 4, -- Column C Aura
	[1223484] = 5, -- Column B Aura
	[1223483] = 6, -- Column A Aura
}

event_frame:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, castGUID, spellID = ...
		
		if not string.find(unit, "raid") or not castGUID then return end
		
		local column = self.spellIDToColumn[spellID]
		if column then
			local GUID = UnitGUID(unit)
			self.player_pos[GUID] = column
			
			local frame = G.BossModFrames[1233416]
			
			if frame.spawnGUIDs[GUID] or frame.spawnTankGUIDs[GUID] or frame.breakGUIDs[GUID] then
				frame:BarDisplayAll()
			end
			
			if GUID == G.PlayerGUID then
				frame:UpdateDirection()
			end
		end
	else
		local subZone = GetSubZoneText()
		if subZone == C_Map.GetAreaInfo(16572) or subZone == C_Map.GetAreaInfo(16571) then
			self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		else
			self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		end
	end
end)

local function GUIDToColumn(GUID)
	return event_frame.player_pos[GUID]
end

local function SetDefaultColumn(GUID, pos)
	if not event_frame.player_pos[GUID] then
		event_frame.player_pos[GUID] = pos
	end
end

-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2747] = {
	engage_id = 3133,
	npc_id = {"237861"},
	alerts = {
		{ -- 虚空棱镜
			spells = {
				{1233657},--【虚空棱镜】
			},
			options = {
				{ -- 图标 折射熵变（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1241137,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 水晶枢纽
			spells = {
				{1226089},--【水晶枢纽】
				{1232130},--【节点破片】
			},
			options = {
				
			},
		},
		{ -- 破碎节点
			spells = {
				{1236784, "12"},--【破碎节点】
				{1232760, "12"},--【水晶裂伤】
				--{1232130},--【节点破片】
			},
			options = {
				{ -- 图标 水晶裂伤（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1232760,
					tip = L["DOT"],
				},
			},
		},
		{ -- 虚空注能节点
			spells = {
				{1236785},--【虚空注能节点】
				--{1232130},--【节点破片】
				{1247424},--【虚无吞噬】
				--{1247495},--【虚无爆炸】
			},
			options = {
				{ -- 文字 虚无吞噬 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["大圈"]..L["倒计时"],
					data = {
						spellID = 1236785,
						events =  {
							["UNIT_AURA_ADD"] = true,
						},	
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.round = true							
							self.last_cast = 0
							self.difficultyID = select(3, ...)
							
							if self.difficultyID == 16 then
								T.Start_Text_DelayTimer(self, 42, L["大圈"], true)
							else
								T.Start_Text_DelayTimer(self, 51, L["大圈"], true)
							end
						elseif event == "UNIT_AURA_ADD" then
							local unit, spellID = ...
							if spellID == 1247424 and GetTime() - self.last_cast > 1 then
								self.last_cast = GetTime()
								if self.difficultyID == 16 then
									T.Start_Text_DelayTimer(self, 40, L["大圈"], true)
								else
									T.Start_Text_DelayTimer(self, 51, L["大圈"], true)
								end	
							end
						end
					end,
				},
				{ -- 文字 虚无吞噬2层（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1247424)..string.format(L["层数大于"], 1),
					data = {
						spellID = 1247424,
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
								if aura_data and aura_data.applications > 1 then
									self.text:SetText(string.format("%s%d %s", T.GetSpellIcon(1247424), aura_data.applications, L["注意自保"]))
									self:Show()
									T.PlaySound("defense")
								else
									self:Hide()
								end
							end
						elseif event == "UNIT_AURA_REMOVED" then
							local unit, spellID = ...
							if unit == "player" and spellID == self.data.spellID then
								self:Hide()
							end
						end
					end,
				},
				{ -- 首领模块 虚无吞噬 计时圆圈（✓）
					category = "BossMod",
					spellID = 1247424,
					name = T.GetIconLink(1247424)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1247424] = { -- 虚无吞噬
								unit = "player",
								aura_type = "HARMFUL",
								color = {.47, .72, 1},
								
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
				{ -- 自保技能提示 虚无吞噬（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1247424,
					threshold = 65,
				},
				{ -- 团队框架高亮 虚无吞噬（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1247424,
					amount = 2,
				},
			},
		},
		{ -- 结晶过载
			spells = {
				{1233917},--【结晶过载】
			},
			options = {
				{ -- 计时条 狂怒粉碎（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1225673,
					text = L["BOSS狂暴"],
				},
			},
		},
		{ -- 结晶震荡波
			spells = {
				{1224414},--【结晶震荡波】
			},
			options = {
				{ -- 文字 结晶震荡波 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["出墙"]..L["倒计时"],
					data = {
						spellID = 1233411,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},
						info = {
							[15] = {
								[1] = {7, 20.7, 30.3, 20.7, 30.3, 20.7, 30.3, 20.7, 30.3, 20.7, 30.3, 20.7, 30.3, 20.7, 30.3, 20.7, 30.3, 20.7},
							},
							[16] = {
								[1] = {7.5, 14.5, 25.5, 14.5, 25.5, 14.5, 25.5, 14.5, 25.5, 14.5, 25.5, 14.5, 25.5, 14.5, 25.5},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 1233411, L["出墙"], self, event, ...)
					end,
				},
				{ -- 首领模块 结晶震荡波 计时圆圈（✓）
					category = "BossMod",
					spellID = 1233411,
					name = T.GetIconLink(1233411)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1233411] = { -- 结晶震荡波
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
				{ -- 首领模块 出墙、消墙位置分配（待测试）
					category = "BossMod",
					spellID = 1233416,
					enable_tag = "spell",
					name = L["出墙消墙位置分配"].." "..string.format(L["使用标记%s"], T.FormatRaidMark("1,2,3,4,5,6")),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 250, width = 200, height = 200},
					events = {
						["UNIT_SPELLCAST_SUCCEEDED"] = true,
						["UNIT_SPELLCAST_START"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["JST_CUSTOM"] = true,
					},
					custom = {
						{
							key = "difficulty_index_dd",
							text = L["MRT模板难度"],
							default = 15,
							key_table = {
								{14, PLAYER_DIFFICULTY1},
								{15, PLAYER_DIFFICULTY2},
								{16, PLAYER_DIFFICULTY6},
							},
						},
						{
							key = "1_blank",
						},
						{
							key = "mrt_custom_btn",
						},
						{
							key = "mrt_analysis_btn",
						},	
						{
							key = "direction_bool",
							text = L["显示方向和距离"],
							default = false,
							apply = function(value, frame)
								if value then
									frame.arrowframe.enable = true
									T.RestoreDragFrame(frame.arrowframe, frame)
								else
									frame.arrowframe.enable = false
									frame.arrowframe:Hide()
									T.ReleaseDragFrame(frame.arrowframe)
								end
							end,
						},
						{
							key = "rl_bool",
							text = L["团队分配"],
							default = false,
							apply = function(value, frame)
								if value then
									if T.IsInPreview() then
										frame:PreviewRLFrame()
									end
									frame.rl_frame.enable = true
									T.RestoreDragFrame(frame.rl_frame, frame)
								else
									frame.rl_frame.enable = false
									frame.rl_frame:Hide()
									T.ReleaseDragFrame(frame.rl_frame)
								end
							end,
						},
						{
							key = "safe_dur_sl",
							text = L["安全区文字持续时间"],
							default = 30,
							min = 5,
							max = 50,
						},
					},
					init = function(frame)
						T.GetScaleCustomData(frame)
						
						frame.tankSpawnCount = 1
						
						frame.spawns = {}
						frame.tankSpawns = {}
						frame.breaks = {}
						frame.safespots = {}
						frame.breakOrder = {}
						
						frame.spawnGUIDs = {}
						frame.spawnTankGUIDs = {}
						frame.breakGUIDs = {}
						frame.spawns_count = 0
						frame.rotation_count = 0
						frame.last_cast = 0						
						
						frame.wallCounts = {}
						frame.wallAssigned = {}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						frame.text_frame_tankwall = T.CreateAlertTextShared("bossmod"..frame.config_id.."tankwall", 1)
						
						frame.graphs = {}
						frame.graph_bg = CreateFrame("Frame", nil, frame)
						frame.graph_bg:SetAllPoints(frame)
						frame.graph_bg:Hide()
						
						local slices = 6
						local degrees = 100
						local widthMultiplier = 0.82 -- Decrease to create more space between slices
						
						local size = 160
						local circumference = 2 * math.pi * size / (360 / degrees)
						local slice_width = circumference / slices * widthMultiplier
						local slice_height = size
						
						frame.graph_tex_info = {
							str = {layer = "ARTWORK", text = "-", fs = 25, color = {1, 1, 1}, points = {"TOP", 0, -20}},
						}
						
						for column = 1, 6 do
							local rotation = (column - 0.5 - (slices / 2)) * (2 * math.pi * ((degrees / 360) / slices))
							frame.graph_tex_info["slice"..column] = {
								layer = "BACKGROUND",
								sub_layer = 1,
								tex = G.media.triangle,
								color = {1, .3, .3},
								w = slice_width,
								h = slice_height,
								rotation = {rotation, 0.5, 0.92},
								points = {"BOTTOM", 0, 0},
							}
						end
						
						T.UpdateGraphTextures(frame, frame.graph_bg)
								
						frame.arrowframe = T.GetArrowFrame(frame)
						frame.arrowframe:Hide()
						
						local bar_width = 60
						local bar_height = 90
						T.CreateMovableFrame(frame, "rl_frame", bar_width*6+25, bar_height+60, {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 225, y = -150}, "_rl_frame", L["团队分配"])
						frame.rl_frame.bars = {}
						
						for column = 1, 6 do
							local bar = CreateFrame("StatusBar", nil, frame.rl_frame)
							bar:SetSize(bar_width, bar_height)
							bar:SetPoint("TOPLEFT", frame.rl_frame, "TOPLEFT", (bar_width+5)*(column-1), -15)
							
							bar:SetOrientation("VERTICAL")
							bar:SetStatusBarTexture(G.media.blank)
							bar:SetStatusBarColor(0, 1, 1)
							T.createborder(bar, .25, .25, .25, 1)
														
							bar:SetMinMaxValues(0, 6)
							
							bar.name = T.createtext(bar, "OVERLAY", 14, "OUTLINE", "CENTER")
							bar.name:SetPoint("BOTTOM", bar, "BOTTOM", 0, 0)
							
							bar.nameAssign = T.createtext(bar, "OVERLAY", 14, "OUTLINE", "CENTER")
							bar.nameAssign:SetPoint("TOP", bar, "BOTTOM", 0, -5)
							
							bar.rt = T.createtext(bar, "OVERLAY", 14, "OUTLINE", "CENTER")
							bar.rt:SetPoint("BOTTOM", bar, "TOP", 0, 0)
							bar.rt:SetText(T.FormatRaidMark(column))
							
							bar.extraTex = bar:CreateTexture(nil, "OVERLAY")
							bar.extraTex:SetPoint("RIGHT", bar:GetStatusBarTexture(), "RIGHT")
							bar.extraTex:SetPoint("LEFT", bar:GetStatusBarTexture(), "LEFT")
							bar.extraTex:SetPoint("BOTTOM", bar:GetStatusBarTexture(), "TOP", 0, 0)
							bar.extraTex:SetTexture(G.media.overlay1)
							
							bar.players = {}
							bar.playersAssign = {}
							
							table.insert(frame.rl_frame.bars, bar)
						end
						
						function frame:BarDisplay(column)
							local bar = frame.rl_frame.bars[column]
								
							bar.players = table.wipe(bar.players)
							bar.playersAssign = table.wipe(bar.playersAssign)
							
							for GUID, assign in pairs(frame.spawnGUIDs) do
								if GUIDToColumn(GUID) == column then
									table.insert(bar.players, GUID)
								end
								if assign == column then
									table.insert(bar.playersAssign, GUID)
								end
							end
							
							for GUID, assign in pairs(frame.spawnTankGUIDs) do
								if GUIDToColumn(GUID) == column then
									table.insert(bar.players, GUID)
								end
								if assign == column then
									table.insert(bar.playersAssign, GUID)
								end
							end
							
							for GUID, assign in pairs(frame.breakGUIDs) do
								if GUIDToColumn(GUID) == column then
									table.insert(bar.players, GUID)
								end
								if assign == column then
									table.insert(bar.playersAssign, GUID)
								end
							end							
							
							local str = ""						
							table.sort(bar.players)
							for i, GUID in pairs(bar.players) do
								local info = T.GetGroupInfobyGUID(GUID)
								local role = info and info.role == "TANK" and T.GetFlagIconStr("0") or ""
								local format_name = info and info.format_name or "?"
								if i == 1 then
									str = str..role..format_name
								else
									str = str.."\n"..role..format_name
								end
							end
							bar.name:SetText(str)
							
							local strAssign = ""
							table.sort(bar.playersAssign)
							for i, GUID in pairs(bar.playersAssign) do
								local info = T.GetGroupInfobyGUID(GUID)
								if info then
									local role = info.role == "TANK" and T.GetFlagIconStr("0") or ""
									local format_name = info.format_name or "?"
									if i == 1 then
										strAssign = strAssign..role..format_name
									else
										strAssign = strAssign.."\n"..role..format_name
									end
								end
							end
							bar.nameAssign:SetText(strAssign)
							
							local value = self.wallCounts[column]
							
							if value then
								bar:SetValue(value)
							end
							
							local change = self.wallAssigned[column]
							
							if change then
							
								if change == 0 then
									bar.extraTex:Hide()	
								elseif change > 0 then
									bar.extraTex:Show()
									bar.extraTex:SetVertexColor(0, 1, 1)
									bar.extraTex:SetPoint("TOP", bar:GetStatusBarTexture(), "TOP", 0, 15*change)
								else
									bar.extraTex:Show()
									bar.extraTex:SetVertexColor(.25, .25, .25)
									bar.extraTex:SetPoint("TOP", bar:GetStatusBarTexture(), "TOP", 0, 15*change)
								end
							end
						end
						
						function frame:BarDisplayAll()
							for column = 1, 6 do
								self:BarDisplay(column)
							end
						end
						
						function frame:Display(target_column, text)
							self.graph_bg:Show()
							
							self.graphs.str.text:SetText(T.FormatRaidMark(target_column)..text)
							
							for column = 1, 6 do
								local slice = self.graphs["slice"..column]
								if column == target_column then
									local r, g, b = T.GetRaidMarkColor(column)
									slice.tex:SetVertexColor(r, g, b)
								else
									slice.tex:SetVertexColor(.3, .3, .3)
								end
							end
						end
						
						function frame:DisplaySafe(position, preview)
							if position then
								self:Display(position, string.format("|cff00ff00%s|r", L["安全"]))
								if not preview then
									local dur = C.DB["BossMod"][self.config_id]["safe_dur_sl"]
									T.Start_Text_Timer(self.text_frame, dur, T.FormatRaidMark(position)..string.format("|cff00ff00%s|r", L["安全"]))
								end
							end
						end
						
						function frame:UpdateAssign(assignmentType, position, dur)
							local mark = T.FormatRaidMark(position)
							
							if assignmentType == "SPAWN" then
								T.Start_Text_Timer(self.text_frame, dur, mark..string.format("|cff4EE8FF%s|r", L["出墙"]))
							else
								T.Start_Text_Timer(self.text_frame, dur, mark..string.format("|cffFF1D2D%s|r", L["消墙"]))
							end
							
							self.curAssign = position
							
							C_Timer.After(dur, function()
								self.curAssign = nil
								self:UpdateDirection()
							end)
						end
						
						function frame:UpdateDirection()
							if not C.DB["BossMod"][self.config_id]["direction_bool"] then return end
							
							local position = self.curAssign
							
							if position then
								local column = GUIDToColumn(G.PlayerGUID)
								local mark = T.FormatRaidMark(position)
								if column then
									local distance = abs(position - column)
									if distance == 0 then
										self.arrowframe:SetArrowTitle(mark, "|cff00ff00OK|r")
										self.arrowframe:SetArrowColor(0,1,0)
										self.arrowframe:SetArrowDown()
										self.arrowframe:Show()
										
									else
										self.arrowframe:SetArrowTitle(mark, string.format(L["格子数"], distance))
										self.arrowframe:SetGradientArrowColor(1-distance/5)
										if position - column > 0 then
											self.arrowframe:SetArrowDirection("right")
										else
											self.arrowframe:SetArrowDirection("left")
										end
										self.arrowframe:Show()
									end
								else
									self.arrowframe:Hide()
								end
							else
								self.arrowframe:Hide()
							end
						end
						
						function frame:DisplayAssignment(assignmentType, GUID, position, tank, preview)
							if assignmentType == "SPAWN" then
								if GUID == G.PlayerGUID then
									self:Display(position, string.format("|cff4EE8FF%s|r", L["出墙"]))
								end
								
								if not preview then
									if GUID == G.PlayerGUID then
										self:UpdateAssign(assignmentType, position, tank and 4 or 10)
										self:UpdateDirection()
										
										if not tank then
											T.SendChatMsg(L["出墙"]..string.format("{rt%d}", position), 5, "SAY")
										else
											T.SendChatMsg(L["坦克"]..L["出墙"]..string.format("{rt%d}", position), 5, "SAY")
										end
										
										T.PlaySound("mark\\mark"..position)
									end
									
									if not tank then
										local ind = mod(self.spawns_count, 2) == 1 and 1 or 3
										T.msg(string.format("[%d-%d]%s%s%s", self.rotation_count, ind, T.ColorNickNameByGUID(GUID), L["出墙"], T.FormatRaidMark(position)))
										self.wallAssigned[position] = self.wallAssigned[position] + 1
										self.spawnGUIDs[GUID] = position
									else
										T.msg(string.format("[%d-%d]%s%s%s", self.rotation_count, 2, T.ColorNickNameByGUID(GUID), L["坦克"]..L["出墙"], T.FormatRaidMark(position)))
										self.wallAssigned[position] = self.wallAssigned[position] + self.tankSpawnCount
										self.spawnTankGUIDs[GUID] = position
									end
									
									T.FireEvent("JST_CUSTOM", frame.config_id)
								end
							else
								if GUID == G.PlayerGUID then
									self:Display(position, string.format("|cffFF1D2D%s|r", L["消墙"]))
								end
								
								if not preview then
									if GUID == G.PlayerGUID then
										self:UpdateAssign(assignmentType, position, 6)
										self:UpdateDirection()
										
										T.SendChatMsg(L["消墙"]..string.format("{rt%d}", position), 5, "YELL")
										
										T.PlaySound("mark\\mark"..position)
									end
									
									T.msg(string.format("[%d-%d]%s%s%s", self.rotation_count, 4, T.ColorNickNameByGUID(GUID), L["消墙"], T.FormatRaidMark(position)))
									self.wallAssigned[position] = self.wallAssigned[position] - 1
									self.breakGUIDs[GUID] = position
									T.FireEvent("JST_CUSTOM", frame.config_id)
								end
							end
						end
						
						function frame:DisplayTankSpawn()
							for unit in T.IterateGroupMembers() do
								local isTanking = UnitDetailedThreatSituation(unit, "boss1")
								
								if isTanking then
									local GUID = UnitGUID(unit)
									local position = table.remove(frame.tankSpawns, 1)
									
									if position then
										frame:DisplayAssignment("SPAWN", GUID, position, true)
									end
									
									return
								end
							end
						end
						
						function frame:StartTankWallCountdown(dur)
							if UnitGroupRolesAssigned("player") ~= "TANK" then return end
							
							local tankwall = self.text_frame_tankwall
							local position = self.tankSpawns[1]
							
							if not position then return end
							
							tankwall.exp_time = GetTime() + dur
							tankwall.show_time = 10
							tankwall.cur_text = string.format("%s %s", L["下个坦克墙"], T.FormatRaidMark(position))
							
							if dur > tankwall.show_time then
								tankwall.collapse = true
							else
								tankwall.collapse = false
							end
							
							tankwall.text:SetText("")
							tankwall:Show()
							
							tankwall:SetScript("OnUpdate", function(s, e)
								s.t = s.t + e
								if s.t > 0.05 then
									s.remain = s.exp_time - GetTime()
									if s.remain > s.show_time then
										s.text:SetText("")
										if not s.collapse then
											s.collapse = true
											T.LineUpTexts(s.group)
										end
									elseif s.remain > 0 then
										local isTanking = UnitDetailedThreatSituation("player", "boss1")
										if isTanking then
											if s.collapse then
												s.collapse = false
												T.LineUpTexts(s.group)
											end
										else
											if not s.collapse then
												s.collapse = true
												T.LineUpTexts(s.group)
											end
										end
										s.text:SetText(string.format("%s %.1f", s.cur_text, s.remain))
									else
										s:Hide()
										s:SetScript("OnUpdate", nil)
									end
									s.t = 0
								end
							end)
						end	
						
						local normalDefault = [[
							+ 1 1 0 1 0 0 (3)
							T 6 (3)
							+ 0 1 0 1 1 0 (3)
							- 0 2 0 2 0 0
							
							+ 1 1 0 1 0 0 (3)
							T 6 (3)
							+ 0 1 0 1 1 0 (3)
							- 1 1 0 1 1 0
							
							+ 1 1 0 1 0 0 (3)
							T 6 (3)
							+ 0 1 0 1 1 0 (3)
							- 0 2 0 2 0 0
							
							+ 1 1 0 1 0 0 (3)
							T 6 (3)
							+ 0 1 0 1 1 0 (3)
							- 0 1 0 1 0 2
							
							+ 1 1 0 1 0 0 (3)
							T 6 (3)
							+ 0 1 0 1 1 0 (3)
							- 1 1 0 1 1 0
							
							+ 1 1 0 1 0 0 (3)
							T 6 (3)
							+ 0 1 0 1 1 0 (3)
							- 1 2 0 0 0 1
							
							+ 1 1 1 0 0 0 (4)
							T 6 (4)
							+ 1 1 1 0 0 0 (4)
							- 2 2 0 0 0 0
							
							+ 1 1 1 0 0 0 (4)
							T 6 (4)
							+ 1 1 1 0 0 0 (4)
							- 1 1 1 0 0 1
							
							+ 1 1 1 0 0 0 (4)
							T 6 (4)
							+ 0 1 1 0 1 0 (4)
							- 0 0 0 0 0 0
						]]
						
						normalDefault = gsub(normalDefault, "\t", "")
						normalDefault = string.format("#%dstart%s[%s]\n%send", frame.config_id, L["出墙消墙位置分配"], PLAYER_DIFFICULTY1, normalDefault)
						
						local heroicDefault = [[
							+ 1 1 0 1 1 0 (3)
							T 6 (3)
							+ 1 1 0 1 1 0 (3)
							- 2 2 0 2 0 0
							
							+ 1 1 0 1 1 0 (3)
							T 6 (3)
							+ 1 1 0 1 1 0 (3)
							- 0 2 0 2 2 0
							
							+ 1 1 0 1 1 0 (3)
							T 6 (3)
							+ 1 1 0 1 1 0 (3)
							- 2 1 0 0 2 1
							
							+ 1 1 0 1 1 0 (3)
							T 6 (3)
							+ 1 1 0 1 1 0 (3)
							- 2 1 0 1 2 0
							
							+ 1 1 0 1 1 0 (3)
							T 6 (3)
							+ 1 1 0 1 1 0 (3)
							- 2 2 0 0 1 1
							
							+ 1 1 1 0 1 0 (4)
							T 6 (4)
							+ 1 1 1 0 1 0 (4)
							- 1 1 0 0 3 1
							
							+ 1 1 1 0 1 0 (4)
							T 6 (4)
							+ 1 1 1 0 1 0 (4)
							- 2 2 1 0 1 0
							
							+ 1 1 1 0 1 0 (4)
							T 6 (4)
							+ 1 1 1 0 1 0 (4)
							- 0 0 0 0 3 3
							
							+ 0 0 0 0 2 2 (4)
							T 6 (4)
							+ 1 1 1 0 1 0 (4)
							- 0 0 0 0 0 0
						]]
						
						heroicDefault = gsub(heroicDefault, "\t", "")
						heroicDefault = string.format("#%dstart%s[%s]\n%send", frame.config_id, L["出墙消墙位置分配"], PLAYER_DIFFICULTY2, heroicDefault)
						
						local mythicDefault = [[
							+ 1 1 0 1 1 0 (3)
							T 6 (3)
							+ 1 1 0 1 1 0 (3)
							- 2 2 0 2 2 0
							
							+ 1 1 0 1 1 0 (3)
							T 4 (3)
							+ 1 1 0 1 1 0 (3)
							- 0 2 0 1 2 3
							
							+ 0 1 1 0 1 1 (4)
							T 1 (4)
							+ 0 1 1 0 1 1 (4)
							- 0 2 2 0 2 2
							
							+ 0 1 1 0 1 1 (4)
							T 6 (4)
							+ 0 1 1 0 1 1 (4)
							- 1 2 2 0 2 1
							
							+ 0 1 1 0 1 1 (4)
							T 5 (4)
							+ 1 1 1 0 1 0 (4)
							- 1 2 2 0 2 1
							
							+ 1 1 1 0 1 0 (4)
							T 3 (4)
							+ 0 1 1 0 1 1 (4)
							- 1 3 1 0 2 1
							
							+ 1 1 1 0 1 0 (4)
							T 2 (3)
							+ 0 1 0 1 1 1 (3)
							- 0 6 0 0 1 1
							
							+ 0 2 0 0 1 1 (3)
							T 2 (3)
							+ 1 1 0 0 1 1 (3)
							- 0 0 0 0 0 0
						]]
						
						mythicDefault = gsub(mythicDefault, "\t", "")
						mythicDefault = string.format("#%dstart%s[%s]\n%send", frame.config_id, L["出墙消墙位置分配"], PLAYER_DIFFICULTY6, mythicDefault)
						
						function frame:copy_mrt()
							local difficultyID = C.DB["BossMod"][self.config_id]["difficulty_index_dd"]
							if difficultyID == 14 then
								return normalDefault
							elseif difficultyID == 15 then
								return heroicDefault
							else
								local raidlist = ""
								for unit in T.IterateGroupMembers() do
									local name = UnitName(unit)
									raidlist = raidlist.." "..name
								end
								
								raidlist = string.format("#%dprioritystart\n%s\nend", self.config_id, raidlist)
								
								return mythicDefault.."\n\n"..raidlist.."\n"
							end
						end
						
						function frame:ReadNote(display)
							self.spawns = table.wipe(self.spawns)
							self.tankSpawns = table.wipe(self.tankSpawns)
							self.breaks = table.wipe(self.breaks)
							self.safespots = table.wipe(self.safespots)
							self.breakOrder = table.wipe(self.breakOrder)
							
							local tag = string.format("#%sstart", self.config_id)
							local note = VMRT and VMRT.Note and VMRT.Note.Text1
							local useDefaultAssignments = not (note and note:match(tag))
							local defaultAssignment
							
							if useDefaultAssignments then
								local difficultyID = select(3, GetInstanceInfo())
								if difficultyID ~= 14 and difficultyID ~= 15 and difficultyID ~= 16 then
									difficultyID = C.DB["BossMod"][self.config_id]["difficulty_index_dd"]
								end
								
								if difficultyID == 15 then
									defaultAssignment = heroicDefault
								elseif difficultyID == 16 then
									defaultAssignment = mythicDefault
								elseif difficultyID == 14 then
									defaultAssignment = normalDefault
								end
							end
	
							for _, line in T.IterateNoteAssignment(self.config_id, defaultAssignment) do
								local assignmentType = line:match("^[T%+%-]")
								
								if assignmentType == "+" then -- Spawns
									local spawns, safespot = line:match("^[T%+%-]%s*(.+)%((%d)%)")
									
									safespot = tonumber(safespot)
									
									if spawns and safespot then
										local position = 0
										local assignments = {}
										
										for count in spawns:gmatch("%d") do
											position = position + 1
											
											for _ = 1, tonumber(count) do
												table.insert(assignments, position)
											end
										end
										
										table.insert(self.spawns, assignments)
										table.insert(self.safespots, safespot)
										
										if display then
											local ind = mod(#self.spawns, 2) == 0 and 3 or 1
											local tag = string.format("%d-%d", ceil(#self.spawns/2), ind)
											local assignment_str = table.concat(assignments, ",")
											T.msg(tag, L["出墙"], assignment_str, L["安全"], safespot)
										end
									end
								elseif assignmentType == "T" then -- Tank spawns
									local tankSpawn, safespot = line:match("^[T%+%-]%s*(%d)%s*%((%d)%)")
									
									tankSpawn = tonumber(tankSpawn)
									safespot = tonumber(safespot)
									
									if tankSpawn and safespot then
										table.insert(self.tankSpawns, tankSpawn)
										table.insert(self.safespots, safespot)
										
										if display then
											local tag = string.format("%d-%d", #self.tankSpawns, 2)
											T.msg(tag, L["坦克"]..L["出墙"], tankSpawn, L["安全"], safespot)
										end
									end
								elseif assignmentType == "-" then -- Breaks
									local breaks = line:match("^[T%+%-]%s*(.+)")
									
									if breaks then
										local position = 0
										local assignments = {}
										
										for count in breaks:gmatch("%d") do
											position = position + 1
											
											for _ = 1, tonumber(count) do
												table.insert(assignments, position)
											end
										end
										
										table.insert(self.breaks, assignments)
										
										if display then
											local assignment_str = table.concat(assignments, ",")
											local tag = string.format("%d-%d", #self.breaks, 4)
											T.msg(tag, L["消墙"], assignment_str)
											T.msg("--------------")
										end
									end
								end
							end
							
							for _, line in T.IterateNoteAssignment(self.config_id.."priority") do
								local GUIDs = T.LineToGUIDArray(line)
								local str = ""
								
								for i, GUID in ipairs(GUIDs) do
									self.breakOrder[GUID] = i
									local name = T.ColorNickNameByGUID(GUID)
									str = str .. " "..name
								end
								
								if display then
									T.msg(string.format("%s→%s", L["左"], L["右"]), str)
								end
							end
						end
						
						function frame:Assign(assignmentType)
							local affected, positions = {}, {}
							
							if assignmentType == "SPAWN" then
								for GUID in pairs(self.spawnGUIDs) do
									table.insert(affected, GUID)
								end
								positions = table.remove(self.spawns, 1)
							else
								for GUID in pairs(self.breakGUIDs) do
									table.insert(affected, GUID)
								end
								positions = table.remove(self.breaks, 1)
							end
							
							if not positions then return end
							
							if next(self.breakOrder) then
								table.sort(affected, function(guidA, guidB)
									local orderA = self.breakOrder[guidA] or 0
									local orderB = self.breakOrder[guidB] or 0
									
									if orderA ~= orderB then
										return orderA < orderB
									else
										return guidA < guidB
									end
								end)
							else
								T.SortTable(affected, true)
							end
							
							for i, GUID in ipairs(affected) do
								local position = positions[i]

								if position then
									self:DisplayAssignment(assignmentType, GUID, position)
								end
							end
							
							T.msg("--------------")
						end
						
						function frame:PreviewRLFrame()
							self.spawnGUIDs = table.wipe(self.spawnGUIDs)
							self.breakGUIDs = table.wipe(self.breakGUIDs)
							self.wallCounts = table.wipe(self.wallCounts)
							
							if C.DB["BossMod"][self.config_id]["rl_bool"] then
								local change
								
								if self.rad_type == 2 then
									self.spawnGUIDs[G.PlayerGUID] = self.rad_spot
									change = 1
								elseif self.rad_type == 3 then
									self.breakGUIDs[G.PlayerGUID] = self.rad_spot
									change = -1
								end
								
								for column = 1, 6 do
									self.wallCounts[column] = math.random(5)
									self.wallAssigned[column] = self.rad_spot == column and change or 0
								end
								
								self:BarDisplayAll()
								self.rl_frame:Show()
							end
						end
						
						function frame:PreviewShow()
							self.graph_bg:Show()
							
							self.rad_type = math.random(3)
							self.rad_spot = math.random(6)
							
							if self.rad_type == 1 then
								self:DisplaySafe(self.rad_spot, true)
							elseif self.rad_type == 2 then
								self:DisplayAssignment("SPAWN", G.PlayerGUID, self.rad_spot, false, true)
							else
								self:DisplayAssignment("BREAK", G.PlayerGUID, self.rad_spot, false, true)
							end
							
							self:PreviewRLFrame()
						end
						
						function frame:PreviewHide()
							self.graph_bg:Hide()
							if C.DB["BossMod"][self.config_id]["rl_bool"] then
								self.rl_frame:Hide()
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "ENCOUNTER_START" then
							frame.difficultyID = select(3, ...)
							
							if frame.difficultyID == 16 then
								frame.tankSpawnCount = 3
							else
								frame.tankSpawnCount = 1
							end
							
							frame.spawnGUIDs = table.wipe(frame.spawnGUIDs)
							frame.spawnTankGUIDs = table.wipe(frame.spawnTankGUIDs)
							frame.breakGUIDs = table.wipe(frame.breakGUIDs)
							frame.spawns_count = 0
							frame.rotation_count = 0							
							frame.last_cast = 0
							
							frame.wallAssigned = table.wipe(frame.wallAssigned)
							frame.wallCounts = table.wipe(frame.wallCounts)
							
							for column = 1, 6 do
								local bar = frame.rl_frame.bars[column]
								bar.players = table.wipe(bar.players)
								
								frame.wallAssigned[column] = 0
								frame.wallCounts[column] = 0
							end
							
							frame:ReadNote()
							
							-- Broadcast the initial safespot
							frame.safespot = table.remove(frame.safespots, 1)
							frame:DisplaySafe(frame.safespot)
							
							for unit in T.IterateGroupMembers() do
								local GUID = UnitGUID(unit)
								SetDefaultColumn(GUID, frame.safespot)
							end
							
							if C.DB["BossMod"][frame.config_id]["rl_bool"] then
								frame.rl_frame:Show()
							end
							
							local tank_dur = frame.difficultyID == 16 and 16 or 18
							frame:StartTankWallCountdown(tank_dur)
							
							T.FireEvent("JST_CUSTOM", frame.config_id)
							
						elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, castGUID, spellID = ...
							
							if not castGUID then return end
							
							if unit == "boss1" then
								if spellID == 1233416 then -- 结晶震荡波
									frame.safespot = table.remove(frame.safespots, 1)
									frame:DisplaySafe(frame.safespot)
								elseif spellID == 1231871 then -- 震波猛击
									frame.safespot = table.remove(frame.safespots, 1)
									frame:DisplaySafe(frame.safespot)
								elseif spellID == 1220394 then -- 粉碎抽打
									frame:DisplaySafe(frame.safespot)
								end
							end

						elseif event == "UNIT_SPELLCAST_START" then
							local unit, castGUID, spellID = ...
							
							if not castGUID then return end
							
							if unit == "boss1" and spellID == 1231871 then -- 震波猛击
								frame:DisplayTankSpawn()
								
								local tank_dur = frame.difficultyID == 16 and 40 or 51
								frame:StartTankWallCountdown(tank_dur)
							end
							
						elseif event == "JST_CUSTOM" then
							local id, set = ...
							if id == frame.config_id then
								frame:BarDisplayAll()
							end
							
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							
							if sub_event == "SPELL_AURA_APPLIED" then
								if spellID == 1233411 then -- 结晶震荡波
									frame.spawnGUIDs[destGUID] = 0
					
									if GetTime() - frame.last_cast > 3 then
										frame.last_cast = GetTime()
										frame.spawns_count = frame.spawns_count + 1
										frame.rotation_count = ceil(frame.spawns_count/2)
										
										C_Timer.After(0.2, function() 
											frame:Assign("SPAWN")
											T.FireEvent("JST_CUSTOM", frame.config_id)
										end)
									end
									
								elseif spellID == 1227373 then -- 碎壳
									frame.breakGUIDs[destGUID] = 0
									
									if GetTime() - frame.last_cast > 3 then
										frame.last_cast = GetTime()
										C_Timer.After(0.2, function()
											frame:Assign("BREAK")
											T.FireEvent("JST_CUSTOM", frame.config_id)
										end)
									end
									
								end
							 elseif sub_event == "SPELL_CAST_SUCCESS" then
								
								if spellID == 1233416 then -- 结晶震荡波 (spawn)
									for GUID, assign in pairs(frame.spawnGUIDs) do
										local column = GUIDToColumn(GUID)
										if column then
											frame.wallCounts[column] = frame.wallCounts[column] + 1
											if assign > 0 and assign ~= column then
												local name = T.ColorNickNameByGUID(GUID)
												local rt1 = T.FormatRaidMark(assign)
												local rt2 = T.FormatRaidMark(column)
												T.msg(string.format(L["放墙错误"], name, rt1, rt2))
											end
										end
									end
									
									frame.spawnGUIDs = table.wipe(frame.spawnGUIDs)
									for column = 1, 6 do
										frame.wallAssigned[column] = 0
									end
									T.FireEvent("JST_CUSTOM", frame.config_id)
									
								elseif spellID == 1231871 then -- 震波猛击 (tank spawn)
									for GUID, assign in pairs(frame.spawnTankGUIDs) do
										local column = GUIDToColumn(GUID)
										if column then
											frame.wallCounts[column] = frame.wallCounts[column] + frame.tankSpawnCount
											if assign > 0 and assign ~= column then
												local name = T.ColorNickNameByGUID(GUID)
												local rt1 = T.FormatRaidMark(assign)
												local rt2 = T.FormatRaidMark(column)
												T.msg(string.format(L["放墙错误"], name, rt1, rt2))
											end
										end
									end
									
									frame.spawnTankGUIDs = table.wipe(frame.spawnTankGUIDs)
									for column = 1, 6 do
										frame.wallAssigned[column] = 0
									end
									T.FireEvent("JST_CUSTOM", frame.config_id)			
									
								elseif spellID == 1220394 then -- 粉碎抽打 (breaks)
									for GUID, assign in pairs(frame.breakGUIDs) do
										local column = GUIDToColumn(GUID)
										if column then
											frame.wallCounts[column] = frame.wallCounts[column] - 1
											frame.wallCounts[column] = max(frame.wallCounts[column], 0)
											if assign > 0 and assign ~= column then
												local name = T.ColorNickNameByGUID(GUID)
												local rt1 = T.FormatRaidMark(assign)
												local rt2 = T.FormatRaidMark(column)
												T.msg(string.format(L["消墙错误"], name, rt1, rt2))
											end
										end
									end
									
									frame.breakGUIDs = table.wipe(frame.breakGUIDs)
									for column = 1, 6 do
										frame.wallAssigned[column] = 0
									end
									T.FireEvent("JST_CUSTOM", frame.config_id)
								end
							end
						end
					end,
					reset = function(frame, event)
						if frame.timer then
							frame.timer:Cancel()
						end
						
						T.Stop_Text_Timer(frame.text_frame)
						T.Stop_Text_Timer(frame.text_frame_tankwall)
						frame.graph_bg:Hide()
						
						if C.DB["BossMod"][frame.config_id]["rl_bool"] then
							frame.rl_frame:Hide()
						end
						if C.DB["BossMod"][frame.config_id]["direction_bool"] then
							frame.arrowframe:Hide()
						end
					end,
				},
				{ -- 计时条 结晶震荡波（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1233416,
				},
				{ -- 图标 结晶震荡波（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1224414,
					tip = L["DOT"],
				},
				{ -- 团队框架高亮 结晶震荡波（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1224414,
				},
			},
		},
		{ -- 粉碎抽打
			spells = {
				{1220394, "5"},--【粉碎抽打】
			},
			options = {
				{ -- 计时条 粉碎抽打（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1220394,
					text = L["消墙"],
				},
				{ -- 文字 粉碎抽打 击退（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["击退"]..L["倒计时"],
					data = {
						spellID = 1220394,
						events = {
							["UNIT_SPELLCAST_START"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 1220394 then
								local debuff = AuraUtil.FindAuraBySpellID(1227378, "player", "HARMFUL") -- 水晶覆体
								if debuff then
									T.Start_Text_Timer(self, 2, T.GetIconLink(1220394), true)
									T.PlaySound("knockback")
								end
							end
						end
					end,
				},
			},
		},
		{ -- 碎壳
			spells = {
				{1227373, "5"},--【碎壳】
				{1227378, "5"},--【水晶覆体】
			},
			options = {
				{ -- 文字 碎壳 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["消墙"]..L["倒计时"],
					data = {
						spellID = 1227367,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},
						info = {
							[15] = {
								[1] = {40.5, 51, 51, 51, 51, 51, 51, 51, 51},
							},
							[16] = {
								[1] = {32.5, 40, 40, 40, 40, 40, 40, 40, 40},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 1227367, L["消墙"], self, event, ...)
					end,
				},
				{ -- 首领模块 碎壳 计时圆圈（✓）
					category = "BossMod",
					spellID = 1227373,
					name = T.GetIconLink(1227373)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1227373] = { -- 碎壳
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
				{ -- 自保技能提示 碎壳（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1227373,
					threshold = 65,
				},				
				{ -- 图标 水晶覆体（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1227378,
					tip = L["定身"],
				},
			},
		},
		{ -- 震波猛击
			spells = {
				{1231871, "0,12"},--【震波猛击】			
			},
			options = {
				{ -- 文字 震波猛击 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = L["坦克出墙"]..L["倒计时"],
					data = {
						spellID = 1231871,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							[15] = {
								[1] = {18, 51, 51, 51, 51, 51, 51, 51, 51},
							},
							[16] = {
								[1] = {16, 40, 40, 40, 40, 40, 40, 40, 40},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1231871, L["坦克出墙"], self, event, ...)
					end,
				},
				{ -- 计时条 震波猛击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1231871,
					ficon = "0",
					show_tar = true,
					sound = soundfile("1231871cast", "cast"),
				},
				{ -- 嘲讽提示 震波猛击（待测试）
					category = "BossMod",
					spellID = 1231871,
					ficon = "0",
					name = L["嘲讽提示"]..T.GetIconLink(1231871),
					points = {hide = true},
					events = {					
						["UNIT_AURA_ADD"] = true,
						["UNIT_AURA_REMOVED"] = true,
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_THREAT_SITUATION_UPDATE"] = true,
					},
					init = function(frame)
						frame.aura_spellIDs = {
							[1231871] = 1, -- 震波猛击
						}
						frame.cast_spellIDs = {
							[1231871] = true, -- 震波猛击
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
				{ -- 换坦计时条 震波猛击（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 1231871,
					ficon = "0",
					group = 3,
					show_tar = true,
					roles = {"TANK"},
				},
			},
		},
	},
}
