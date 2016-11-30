local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

local LOCALE = GetLocale()

if LOCALE == "zhTW" then
	-- The EU English game client also
	-- uses the US English locale code.

-- #######################################################################################################
-- ##	繁體中文 (Traditional Chinese) translations provided by BNSSNB and konraddo on Curseforge.		##
-- ##	Thank you BNSSNB and konraddo!																	##
-- #######################################################################################################

-- ################################
-- ## Slash Commands ##
-- ################################

	L["/dcstats"] = "/dcstats"
	L["DejaCharacterStats Slash commands (/dcstats):"] = "DejaCharacterStats指令(/dcstats)"
	L["/dcstats config: Open the DejaCharacterStats addon config menu."] = "/dcstats config: 開啟DejaCharacterStats插件設置選項。"
	L["/dcstats reset:  Resets DejaCharacterStats frames to default positions."] = "/dcstats reset:  重設DejaCharacterStats框架到預設位置。"
	L["Resetting config to defaults"] = "恢復預設設定。" --configuration
	L["DejaCharacterStats is currently using"] = "DejaCharacterStats目前使用了"
	L["kbytes of memory"] = " KB的記憶體"--kilobytes
	L["DejaCharacterStats is currently using"] = "DejaCharacterStats目前使用了"
	L[" kbytes of memory after garbage collection"] = " KB的記憶體（已清理垃圾" --kilobytes
--	L["config"] = "" --configuration
--	L["dumpconfig"] = "" --configuration
	L["With defaults"] = "包含預設"
	L["Direct table"] = "直接數據表" -- Needs review
	L["reset"] = "恢復預設設定"
--	L["perf"] = "" --performance
	L["Reset to Default"] = "恢復為預設"

-- ################################
-- ## Global Options Left Column ##
-- ################################

	L["Equipped/Available"] = "已裝備/可用"
	L["Displays Equipped/Available item levels unless equal."] = "顯示已裝備/可用的物品等級除非相等。"

	L["Decimals"] = "小數點"
	L['Displays "Enhancements" category stats to two decimal places.'] = '顯示"強化"欄位的屬性到兩個小數點。'

	L["Ilvl Decimals"] = "物品等級小數點"
	L["Displays average item level to two decimal places."] = "顯示平均物品等級到兩個小數點。"

	L["Durability "] = "耐久度 "
	L["Displays the average Durability percentage for equipped items in the stat frame."] = "在屬性介面顯示已裝備物品的平均耐久度百分比。"

	L['Repair Total '] = "總修理費用 "
	L["Displays the Repair Total before discounts for equipped items in the stat frame."] = "在屬性介面顯示已裝備物品未打折的總修理費用。"

-- ################################

	L["Durability Bars"] = "耐久度條"
	L["Displays a durability bar next to each item."] = "在每個物品的旁邊顯示耐久度條。"

	L["Average Durability"] = "平均耐久度"
	L["Displays average item durability on the character shirt slot and durability frames."] = "在角色介面襯衫欄與耐久度框架顯示平均物品耐久度。"

	L["Item Durability"] = "物品耐久度"
	L["Displays each equipped item's durability."] = "顯示每個已裝備物品的耐久度。"

	L["Item Repair Cost"] = "物品修理費用"
	L["Displays each equipped item's repair cost."] = "顯示每個已裝備物品的修理費用。"

-- ################################

	L["Expand"] = "打開"
	L["Displays the Expand button for the character stats frame."] = "顯示打開角色屬性介面按鈕。"

	L['Show Character Stats'] = "顯示角色屬性"
	L["Hide Character Stats"] = "隱藏角色屬性"

	L["Scrollbar"] = "滾動條"
	L["Displays the DCS scrollbar."] = "顯示DCS滾動條。"

-- ################################
-- ## Character Options Right Column ##
-- ################################

	L["Show All Stats"] = "顯示所有屬性"
	L["Checked displays all stats. Unchecked displays relevant stats. Use Shift-scroll to snap to the top or bottom."] = "勾選顯示所有屬性。不勾選顯示相應屬性。按Shift鍵後以滑鼠滾輪快速回到頂部或底部。"

	L["Select-A-Stat™"] = "選擇-A-屬性™" -- Try to use something snappy and silly like a Fallout or 1950's appliance feature.
	L["Select which stats to display. Use Shift-scroll to snap to the top or bottom."] = "選擇要顯示哪些屬性。按Shift鍵後以滑鼠滾輪快速回到頂部或底部。"

-- ################################
-- ## Stats ##
-- ################################

	L["Durability"] = "耐久度" -- Be sure to include the colon ":" or it will conflict wih the options checkbox.
	L["Durability %s"] = "耐久度 %s" -- ## --> %s MUST be included <-- ## 
	L["Average equipped item durability percentage."] = "平均已裝備物品耐久度百分比。"

	L["Repair Total"] = "總修理費用" -- Be sure to include the colon ":" or it will conflict wih the options checkbox.
	L["Repair Total %s"] = "總修理費用 %s" -- ## --> %s MUST be included <-- ## 
	L["Total equipped item repair cost before discounts."] = "已裝備物品未打折修理花費總計。"

-- ## Attributes ##

	L["Health"] = "生命值"
	L["Power"] = "能量"
	L["Druid Mana"] = "德魯依法力"
	L["Armor"] = "護甲"
	L["Strength"] = "力量"
	L["Agility"] = "敏捷"
	L["Intellect"] = "智力"
	L["Stamina"] = "耐力"
	L["Damage"] = "傷害"
	L["Attack Power"] = "攻擊強度"
	L["Attack Speed"] = "攻擊速度"
	L["Spell Power"] = "法術強度"
	L["Mana Regen"] = "法力恢復"
	L["Energy Regen"] = "能量恢復"
	L["Rune Regen"] = "符能速度"
	L["Focus Regen"] = "集中值恢復"
	L["Movement Speed"] = "移動速度"
	L["Durability"] = "耐久度"
	L["Repair Total"] = "總修理費用"

-- ## Enhancements ##

	L["Critical Strike"] = "致命一擊"
	L["Haste"] = "加速"
	L["Versatility"] = "臨機應變"
	L["Mastery"] = "精通"
	L["Leech"] = "汲取"
	L["Avoidance"] = "閃避"
	L["Dodge"] = "閃躲"
	L["Parry"] = "招架"
	L["Block"] = "格擋"

	-- ## Patch 7.1.0 r2 additions ##
	L["Global Cooldown"] = "通用冷卻"
	L["Global Cooldown %.2fs"] = "通用冷卻 %.2fs"
--	L["General global cooldown for casters. Individual spells, set bonuses, talents, etc. not considered. Not suitable for melee. Improvements coming Soon(TM)."] = ""
	L["Unlock DCS"] = "解鎖DCS"
	L["Lock DCS"] = "鎖定DCS"
	L["Item Level 1 Decimal Place"] = "物品等級1小數點位數"
	L["Displays average item level to one decimal place."] = "顯示平均物品等級到小數點一位。"
	L["Item Level 2 Decimal Places"] = "物品等級2小數點位數"
	L["Displays average item level to two decimal places."] = "顯示平均物品等級到兩個小數點。"
	L["Main Hand"] = "主手"
	L["/Off Hand"] = "/副手"
	L[" weapon auto attack (white) DPS."] = ' 武器自動攻擊(白字)每秒傷害。'
	L["Weapon DPS"] = "武器每秒傷害"
	L["Weapon DPS %s"] = "武器每秒傷害 %s"
--	L["Class Crest Background"] = ""
--	L["Displays the class crest background."] = ""

return end
