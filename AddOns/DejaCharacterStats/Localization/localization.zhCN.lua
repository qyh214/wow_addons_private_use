local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

local LOCALE = GetLocale()

if LOCALE == "zhCN" then
	-- The EU English game client also
	-- uses the US English locale code.

-- #######################################################################################################
-- ##	简体中文 (Simplified Chinese) translations provided by C_Reus(Azpilicuet@主宰之剑) on Curseforge.	##
-- ##	Thank you C_Reus!																				##
-- #######################################################################################################

-- ################################
-- ## Slash Commands ##
-- ################################

	L["/dcstats"] = "/dcstats"
	L["DejaCharacterStats Slash commands (/dcstats):"] = "DejaCharacterStats命令 (/dcstats)"
	L["  /dcstats config: Open the DejaCharacterStats addon config menu."] = "/dcstats config:打开配置界面." --configuration
	L["  /dcstats reset:  Resets DejaCharacterStats frames to default positions."] = "/dcstats reset:重置为默认设置."
	L["Resetting config to defaults"] = "设置已重置" --configuration
	L["DejaCharacterStats is currently using "] = "DejaCharacterStats正在使用"
	L[" kbytes of memory"] = "KB的内存" --kilobytes
	L["DejaCharacterStats is currently using "] = "DejaCharacterStats正在使用"
	L[" kbytes of memory after garbage collection"] = "KB的内存(内存回收后)" --kilobytes
--	L["config"] = "" --configuration
--	L["dumpconfig"] = "" --configuration
	L["With defaults"] = "包含默认值"
	L["Direct table"] = "直接数据表"
	L["reset"] = "重置"
--	L["perf"] = "" --performance
	L["Reset to Default"] = "重置为默认值"

-- ################################
-- ## Global Options Left Column ##
-- ################################

	L["Equipped/Available"] = "已装备/平均"
	L['Displays Equipped/Available item levels unless equal.'] = "显示已装备/可用的物品等级除非相等."

	L["Decimals"] = "小数点"
	L['Displays "Enhancements" category stats to two decimal places.'] = '显示"强化"栏的属性到小数点后两位'

	L["Ilvl Decimals"] = "物品等级小数点"
	L['Displays average item level to two decimal places.'] = "显示平均装备等级到小数点后两位"

	L['Durability '] = "耐久度"
	L['Displays the average Durability percentage for equipped items in the stat frame.'] = "在属性界面显示已装备物品的平均耐久度百分比"

	L['Repair Total '] = "修理费"
	L['Displays the Repair Total before discounts for equipped items in the stat frame.'] = "在属性界面显示已装备物品未打折的修理费用"

-- ################################

	L["Durability Bars"] = "耐久度条"
	L["Displays a durability bar next to each item." ] = "在每个物品旁边显示耐久度条"

	L["Average Durability"] = "平均耐久度"
	L["Displays average item durability on the character shirt slot and durability frames."] = "在衬衫装备栏上显示已装备物品平均耐久度."

	L["Item Durability"] = "物品耐久度"
	L["Displays each equipped item's durability."] = "显示每个已装备物品耐久度"

	L["Item Repair Cost"] = "物品修理费"
	L["Displays each equipped item's repair cost."] = "显示每个已装备物品修理费"

-- ################################

	L["Expand"] = "显示收缩按钮"
	L['Displays the Expand button for the character stats frame.'] = "在角色属性面板显示收缩按钮"
	L['Show Character Stats'] = "显示角色属性"
	L['Hide Character Stats'] = "隐藏角色属性"

	L["Scrollbar"] = "滚动条"
	L['Displays the DCS scrollbar.'] = "显示DCS滚动条"

-- ################################
-- ## Character Options Right Column ##
-- ################################

	L["Show All Stats"] = "显示所有属性"
	L['Checked displays all stats. Unchecked displays relevant stats. Use Shift-scroll to snap to the top or bottom.'] = "勾选显示所有属性,未勾选则显示相关属性.按Shift后滑动,可快速到顶部或底部."

	L["Select-A-Stat™"]  = "选择以下属性" -- Try to use something snappy and silly like a Fallout or 1950's appliance feature.
	L['Select which stats to display. Use Shift-scroll to snap to the top or bottom.'] = "选择显示哪些属性.按Shift后滑动,可快速到顶部或底部."

-- ################################
-- ## Stats ##
-- ################################

	L["Durability"] = "耐久度" -- Be sure to include the colon ":" or it will conflict wih the options checkbox.
	L["Durability %s"] = "耐久度 %s. " -- ## --> %s MUST be included <-- ## 
	L["Average equipped item durability percentage."] = "平均已装备物品耐久度百分比."

	L["Repair Total"] = "修理费" -- Be sure to include the colon ":" or it will conflict wih the options checkbox.
	L["Repair Total %s"] = "修理费 %s. " -- ## --> %s MUST be included <-- ## 
	L["Total equipped item repair cost before discounts."] = "已装备物品未打折修理费用总计."

-- ## Attributes ##

	L["Health"] = "生命值"
	L["Power"] = "能量"
	L["Druid Mana"] = "德鲁伊法力"
	L["Armor"] = "护甲"
	L["Strength"] = "力量"
	L["Agility"] = "敏捷"
	L["Intellect"] = "智力"
	L["Stamina"] = "耐力"
	L["Damage"] = "伤害"
	L["Attack Power"] = "攻击强度"
	L["Attack Speed"] = "攻击速度"
	L["Spell Power"] = "法术能量"
	L["Mana Regen"] = "法力恢复"
	L["Energy Regen"] = "能量恢复"
	L["Rune Regen"] = "符能恢复"
	L["Focus Regen"] = "集中值恢复"
	L["Movement Speed"] = "移动速度"
	L["Durability"] = "耐久度"
	L["Repair Total"] = "修理费"

-- ## Enhancements ##

	L["Critical Strike"] = "爆击"
	L["Haste"] = "急速"
	L["Versatility"] = "全能"
	L["Mastery"] = "精通"
	L["Leech"] = "吸血"
	L["Avoidance"] = "回避"
	L["Dodge"] = "闪避"
	L["Parry"] = "招架"
	L["Block"] = "格挡"

-- ## Patch 7.1.0 r2 additions ##
	L["Global Cooldown"] = "公共冷卻"
	L["Global Cooldown %.2fs"] = "公共冷卻 %.2fs"
--	L["General global cooldown for casters. Individual spells, set bonuses, talents, etc. not considered. Not suitable for melee. Improvements coming Soon(TM)."] = ""
	L["Unlock DCS"] = "解锁DCS"
	L["Lock DCS"] = "锁定DCS"
	L["Item Level 1 Decimal Place"] = "显示物品等级到小数点后一位"
	L["Displays average item level to one decimal place."] = "显示平均装备等级到小数点后一位。"
	L["Item Level 2 Decimal Places"] = "显示物品等级到小数点后两位"
	L["Displays average item level to two decimal places."] = "显示平均装备等级到小数点后两位。"
	L["Main Hand"] = "主手"
	L["/Off Hand"] = "/副手"
	L[" weapon auto attack (white) DPS."] = ' 武器平砍(白字)秒伤。'
	L["Weapon DPS"] = "武器秒伤"
	L["Weapon DPS %s"] = "武器秒伤 %s"
--	L["Class Crest Background"] = ""
--	L["Displays the class crest background."] = ""

return end
