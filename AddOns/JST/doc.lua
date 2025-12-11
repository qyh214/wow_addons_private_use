-- 【【   To do list  】】---
--[[
ColorNameForMrt
UIDropDownMenu_SetSelectedValue
]]

-- 【【   API  】】---
--[[
	EJ_GetInstanceByIndex(index, isRaid)
	EJ_GetEncounterInfoByIndex()
	
	UnitTokenFromGUID(GUID)
	
	AuraUtil.FindAuraBySpellID(spellID, unit, "HELPFUL")
	
	C_Spell.GetSpellName(spellIdentifier)
	C_Spell.GetSpellTexture(spellIdentifier)
	
	ipairs_reverse
	
	tAppendAll(tbl, addedArray)
	MergeTable(destination, source)
	CopyTable(settings, shallow)
	tInvert(tbl)
	
	tIndexOf(table, element)
	tContains(table, element)
	tInsertUnique(table, element)
	tDeleteItem(table, element)
	
	CountTable(tbl)
	TableUtil.FindMin(tbl, op)
	TableUtil.FindMax(tbl, op)
	tFilter(tbl, pred, isIndexTable)
	FindInTable(tbl, value)
	FindInTableIf(tbl, pred)	
	FindValueInTableIf(tbl, pred)
	
	tCompare(lhsTable, rhsTable, depth)
]]

-- 【【  隐藏光环   】】---

-- 【【JST TO DO LIST】】---
-- 框架获取bug

-- 导出：禁用全部 bug
-- 私人光环整理，添加音效

-- 小怪
--	小怪技能CD
--	对我施法图标/点名计时圈圈
--	团队框架施法目标
--	团队框架debuff高亮	
--	驱散提示音
--	计时条（需要群控）

-- BOSS
--	BOSS技能倒计时
--	对我施法图标/点名计时圈圈
--	团队框架施法目标
--	团队框架debuff高亮
--	驱散提示音
--	BOSS吸收盾
--	血量对比

-- 【【AltzUI TO DO LIST】】---
-- 卡动作条
-- 单位框架生命条刷新
-- 骑士豆子 能量刷新
-- 传送信息修了
-- 背包搜索框错位

-- 【【WA TO DO LIST】】---
-- 群活
-- 喝水
-- 消耗品

-- 【【图标颜色】】---
-- 红色red：重要点名1
-- 黄色yel：次要点名1 炸弹 分担伤害
-- 天蓝blu：次要点名2 射线 可驱散的
-- 橙色org：强力DOT
-- 绿色gre：有益光环
-- 紫色pur：特殊机制

-- 【【检查标记1】】---（x）
-- 【【检查标记2】】---（✓）
-- 【【检查标记3】】---（?）
-- 【【检查标记4】】---（待测试）
-- 【【检查标记5】】---（缺数据）

----------------------------------------------------------
---------------------[[    图标    ]]---------------------
----------------------------------------------------------
--[[ Debuff
				{ -- 图标 
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 357827,
				},

]]

--[[ 强力DOT
				{ -- 图标 
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 355487,
					tip = L["强力DOT"],
					hl = "red",
				},
]]

--[[ 叠层效果
				{ -- 图标 
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "player",
					spellID = 774,
					tip = "撞球易伤".."%s250%",
					hl = "red_flash",
				},			
]]

--[[ 吸收治疗
				{ -- 图标 
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1232775,
					effect = 1,
					hl = "",
					tip = L["吸收治疗"],
				},	
]]

--[[ 踩水
				{ -- 图标 
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 348366,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
]]

--[[ 对我施法图标
				{ -- 对我施法图标 
					category = "AlertIcon",
					type = "com",
					spellID = 195108,
					hl = "yel_flash",
				},
]]

--[[ BOSS喊话
				{ -- BOSS喊话图标 
					category = "AlertIcon",
					type = "bmsg",
					spellID = 197064,
					event = "CHAT_MSG_MONSTER_YELL",
					boss_msg = "又是你",
					dur = 5,
				},
]]

-- 图标模板通用可选项

--[[
	spellIDs = {1064, 48438}, -- 其他法术ID
	options_spellIDs = {1064, 48438}, -- 控制台显示法术

	effect = 1, -- 数值
	icon_tex = 5764928,
	ficon = "13",
	tip = L["强力DOT"],
	hl = "red",
	
	sound = "[defense]cd3", -- cd3, stack, stackmore, stackless, stacksfx
	msg = {str_applied = "%name %spell", str_rep = "%dur"},	
]]

--  图标聊天讯息栗子

-- msg = {str_applied = "%name %spell", str_rep = "%spell %dur"}
-- msg = {str_applied = "%name %spell", str_cd = "%dur", cd = 5}
-- msg = {str_applied = "%name %spell", str_stack = "%stack"}
-- msg = {str_applied = "%name %spell", str_stack = "%stack", max = 10, min = 5}
-- msg = {str_applied = "%name %spell", channel = "YELL"}

----------------------------------------------------------
--------------------[[    计时条    ]]--------------------
----------------------------------------------------------

--[[ 施法/引导计时条模板
				{ -- 计时条 
					category = "AlertTimerbar",
					type = "cast",
					spellID = 8936,
					
					glow_cast = true,
					glow_channel = true,
				},
]]

--[[ 施法成功计时条模板
				{ -- 计时条 
					category = "AlertTimerbar",
					type = "cast",
					spellID = 774,
					dur = 3,
				},
]]

--[[ CLEU计时条模板
				{ -- 计时条 
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 8936,
					dur = 10,
				},
]]
 
--[[ 光环计时条模板
				{ -- 计时条 
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HELPFUL", -- "HELPFUL" "HARMFUL"
					spellID = 8936,
					unit = "group", -- "gourp" "boss" 及其他特定单位
					
					force_full = true, -- 填充进度
				},
]]

----------------------------------------------------------
----------------[[    特殊计时条模板    ]]----------------
----------------------------------------------------------

--[[ 换坦计时条
				{ -- 换坦计时条 
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 8936,
					group = 3,
					ficon = "0",
					show_tar = true,
					roles = {"TANK"},
				},
]]

--[[ 打坦计时条
				{ -- 打坦计时条
					category = "AlertTimerbar",
					type = "cast",
					spellID = 8936,
					group = 1,
					ficon = "0",
					show_tar = true, -- 可选
					sound = "[minddefense]cast",
				},
]]

--[[ 控断计时条 无目标
				{ -- 控断计时条 弧光震击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1229510,
					ficon = "6",
					sub_group = 2,
				},
]]

--[[ 控断计时条 有目标
				{ -- 控断计时条 弧光震击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1229510,
					ficon = "6",
					show_tar = true,
					sub_group = 2,
				},
]]

--[[ 控断计时条 强断/强控 无目标
				{ -- 控断计时条 弧光震击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1229510,
					ficon = "6",
					group = 1,
					glow = true,
				},
]]

--[[ 控断计时条 强断/强控 有目标
				{ -- 控断计时条 弧光震击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1229510,
					ficon = "14",
					group = 1,
					glow = true,
					show_tar = true,
				},
]]

-- 计时条模板通用可选项

--[[
	spellIDs = {1064, 48438}, -- 其他法术ID
	group = 1, -- 1 重要计时条 2 一般计时条 3 换坦计时条
	ficon = "7,4", -- 标记
	
	range_ck = true, --距离过远检测
	threat_ck = true, --仇恨检测
	roles = {"TANK"}, -- 目标检测
	
	icon_tex = 5764928,
	text = L["接圈"], -- 文字
	show_tar = true, -- 显示目标
	count = true, -- 计数
	color = {.97, .52, 1}, -- 颜色
	tags = {4}, -- 分段标记
	glow = true, -- 边框闪烁
	
	sound = "[add]cast,cd3", -- 声音		
	
	options_spellIDs = {1064, 48438}, -- 控制台显示法术
]]

----------------------------------------------------------
-----------------[[    自保技能提示    ]]-----------------
----------------------------------------------------------

--[[ 自保技能提示 CLEU
				{ -- 自保技能提示 
					category = "HPWatch",
					type = "CLEU",
					spellID = 8936,
					event = "SPELL_CAST_START",
					dur = 5,
					threshold = 65,
					
					target_me = true, -- 可选项，目标是我
				},
]]

--[[ 自保技能提示 Aura
				{ -- 自保技能提示 
					category = "HPWatch",
					type = "Aura",
					spellID = 8936,
					threshold = 65,
					
					amount = 2, -- 可选项，层数
				},
]]

-- 自保技能提示模板通用可选项

--[[
	spellIDs = {774},
	ignore_roles = {"TANK"},
--]]

----------------------------------------------------------
-------------------[[    团队框架    ]]-------------------
----------------------------------------------------------

--[[ 团队框架图标 Cast
				{ -- 团队框架图标 
					category = "RFIcon",
					type = "Cast",
					spellID = 357196,
				},
]]

--[[ 团队框架高亮 Aura
				{ -- 团队框架高亮 迅斩
					category = "RFIcon",
					type = "Aura",
					spellID = 355832,				
					color = "red",
				},
				
	-- color 可选 标准色/自定义色/图标颜色
]]

--[[ 团队框架图标 BOSS谜语
				{ -- 团队框架高亮 迅斩
					category = "RFIcon",
					type = "Msg",
					spellID = 774,
					boss_msg = "346959",
					dur = 6,
				},
]]
----------------------------------------------------------
-------------------[[    声音提示    ]]-------------------
----------------------------------------------------------
--[[ 基础提示音			
				{ -- 声音 空投
					category = "Sound",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 48438,
					file = "[mindstep]",
				},
]]

--[[ 私人光环提示音
				{ -- 声音 阿梅达希尔之种
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 410326,
					private_aura = true,
					file = "[sharedmg]",
				},
]]

--[[ 驱散提示音
				{ -- 驱散提示音 培植毒药
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 8936,
					file = "[dispel]",
					ficon = "7",
				},
]]

-- 声音提示模板通用可选项

--[[
	spellIDs = {774},
	target_me = true,
--]]
----------------------------------------------------------
--------------------[[    姓名板    ]]--------------------
----------------------------------------------------------

--[[ 打断
				{ -- 姓名板打断图标
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 192138,
					mobID = "97269",
					interrupt = 2,
					ficon = "6",
				},
]]

--[[ 法术来源
				{ -- 姓名板法术来源图标
					category = "PlateAlert",
					type = "PlayerAuraSource",
					aura_type = "HARMFUL",
					spellID = 192094,
					hl_np = true,
				},
]]

--[[ 光环
				{ --  恢复
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HELPFUL",
					spellID = 197502,
				},
]]

--[[ 施法
				{ -- 姓名板施法图标
					category = "PlateAlert",
					type = "PlateSpells",
					spellID = 192138,
					hl_np = true,
				},
]]

--[[ 能量
				{ -- 姓名板能量
					category = "PlateAlert",
					type = "PlatePower",
					mobID = "91784",
					hl = 15,
				},
]]

--[[ NPC
				{ -- 姓名板NPC高亮
					category = "PlateAlert",
					type = "PlatePower",
					mobID = "91784",
					hl = 15,
				},
]]

----------------------------------------------------------
-------------------[[    文字提示    ]]-------------------
----------------------------------------------------------
--[[ 能量
				{ -- 文字提示能量
					category = "TextAlert",
					type = "pp",
					data = {
						npc_id = "91784",
						phase = 2, -- 阶段过滤（可选）
						ranges = {
							{ ul = 50, ll = 10, tip = T.GetIconLink(421013)..string.format(L["能量2"], 100)},
						},
					},
				},
]]

--[[ 血量
				{ -- 文字提示血量
					category = "TextAlert",
					type = "hp",
					data = {
						npc_id = "91784",
						phase = 2, -- 阶段过滤（可选）
						ranges = {
							{ ul = 101, ll = 70, tip = T.GetIconLink(401316)..string.format(L["血量2"], 80)},
						},
					},
				},
]]
					
--[[ 技能倒计时
				{ -- 文字 召唤摩托 倒计时
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(459943)..L["倒计时"],
					data = {
						spellID = 48438,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[2] = {5},
								[3] = {5},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 459943, T.GetIconLink(459943), self, event, ...)
					end,
				},
]]

--[[ 其他
				{ -- 文字 召唤摩托 倒计时
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(459943)..L["倒计时"],
					data = {
						spellID = 48438,
						events = {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, sourceName, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 774 then
								T.Start_Text_Timer(self, 5, T.GetIconLink(spellID), true)
							end
						end
					end,
				},
]]

----------------------------------------------------------
-------------------[[    阶段转换    ]]-------------------
----------------------------------------------------------

--[[ CLEU
				{
					category = "PhaseChangeData",
					phase = 2,					
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 1126,
					count = 1, -- 序号（可选）
				},
]]

--[[ CLEU 打断
				{
					category = "PhaseChangeData",
					phase = 2,	
					type = "CLEU",
					sub_event = "SPELL_INTERRUPT",
					extraSpellID = 449734, -- 额外法术
				},
]]

--[[ UNIT
				{
					category = "PhaseChangeData",
					phase = 2,					
					type = "UNIT",
					npcID = "97269",
				},
]]

-- 阶段转换模板通用可选项

--[[
	ficon = "12", -- 难度过滤（可选）
	
--]]