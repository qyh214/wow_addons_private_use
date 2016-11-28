local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

local LOCALE = GetLocale()

if LOCALE == "koKR" then
	-- The EU English game client also
	-- uses the US English locale code.

-- ###################################################################################################
-- ##	한국어 (Korean) translations provided by PositiveMind on Curseforge. Thank you PositiveMind!	##
-- ###################################################################################################

-- ################################
-- ## Slash Commands ##
-- ################################

--	L["/dcstats"] = ""
	L["DejaCharacterStats Slash commands (/dcstats):"] = "DCS 명령어 (/dcstats):"
	L["  /dcstats config: Open the DejaCharacterStats addon config menu."] = "  /dcstats config: DCS 설정 메뉴를 불러옵니다." --configuration
	L["  /dcstats reset:  Resets DejaCharacterStats frames to default positions."] = "  /dcstats reset: DCS 창의 위치를 초기화합니다."
	L["Resetting config to defaults"] = "설정을 기본값으로 초기화합니다." --configuration
	L["DejaCharacterStats is currently using "] = "DCS는 "
	L[" kbytes of memory"] = " kb의 메모리를 사용중입니다." --kilobytes
--	L["DejaCharacterStats is currently using "] = ""
	L[" kbytes of memory after garbage collection"] = " kb의 메모리를 정리하였습니다." --kilobytes
--	L["config"] = "" --configuration
--	L["dumpconfig"] = "" --configuration
--	L["With defaults"] = ""
--	L["Direct table"] = ""
--	L["reset"] = ""
--	L["perf"] = "" --performance
	L["Reset to Default"] = "기본설정"

-- ################################
-- ## Global Options Left Column ##
-- ################################

	L["Equipped/Available"] = "착용중/소지중"
	L['Displays Equipped/Available item levels unless equal.'] = "착용중/소지중인 아이템 레벨을 표시합니다."

	L["Decimals"] = "소수점"
	L['Displays "Enhancements" category stats to two decimal places.'] = "\"강화 수치\" 구역에 소수점 2자리까지 표시합니다."

	L["Ilvl Decimals"] = "아이템레벨 소수점 표시"
	L['Displays average item level to two decimal places.'] = "아이템레벨을 소수점 2자리까지 표시합니다."

	L['Durability '] = "내구도 "
	L['Displays the average Durability percentage for equipped items in the stat frame.'] = "캐릭터 정보 표시 구역에 착용중인 아이템의 평균 내구도를 표시합니다."

	L['Repair Total '] = "총 수리비 "
	L['Displays the Repair Total before discounts for equipped items in the stat frame.'] = "캐릭터 정보 표시 구역에 착용중인 장비의 총 수리비를 표시합니다."

-- ################################

	L["Durability Bars"] = "내구도 바"
	L["Displays a durability bar next to each item." ] = "각 아이템의 옆에 내구도 바를 표시합니다."

	L["Average Durability"] = "평균 내구도"
	L["Displays average item durability on the character shirt slot and durability frames."] = "캐릭터 정보 표시 구역에 착용중인 아이템의 평균 내구도를 표시합니다."

	L["Item Durability"] = "아이템 내구도"
	L["Displays each equipped item's durability."] = "각 아이템에 내구도를 표시합니다."

	L["Item Repair Cost"] = "아이템 수리비"
	L["Displays each equipped item's repair cost."] = "각 아이템에 수리비를 표시합니다."

-- ################################

	L["Expand"] = "확장 표시"
	L['Displays the Expand button for the character stats frame.'] = "캐릭터 정보 창에 확장 버튼을 표시합니다."
	L['Show Character Stats'] = "캐릭터 정보 표시"
	L['Hide Character Stats'] = "캐릭터 정보 숨기기"

	L["Scrollbar"] = "스크롤 바"
	L['Displays the DCS scrollbar.'] = "스크롤바 표시"

-- ################################
-- ## Character Options Right Column ##
-- ################################

	L["Show All Stats"] = "모든 정보 보기"
	L['Checked displays all stats. Unchecked displays relevant stats. Use Shift-scroll to snap to the top or bottom.'] = "모든 정보를 체크합니다. 해제시 필요한 정보만 표시됩니다. (Shift 스크롤로 안보이는 부분을 볼 수 있습니다.)"

	L["Select-A-Stat™"]  = "선택-을-통계를™" -- Try to use something snappy and silly like a Fallout or 1950's appliance feature.
	L['Select which stats to display. Use Shift-scroll to snap to the top or bottom.'] = "설정된 정보만 표시합니다. (Shift 스크롤로 안보이는 부분을 볼 수 있습니다.)"

-- ################################
-- ## Stats ##
-- ################################

	L["Durability"] = "내구도" -- Be sure to include the colon ":" or it will conflict wih the options checkbox.
	L["Durability %s"] = "내구도 %s" -- ## --> %s MUST be included <-- ## 
	L["Average equipped item durability percentage."] = "착용중인 장비의 평균 내구도입니다."

	L["Repair Total"] = "총 수리비" -- Be sure to include the colon ":" or it will conflict wih the options checkbox.
	L["Repair Total %s"] = "총 수리비 %s" -- ## --> %s MUST be included <-- ## 
	L["Total equipped item repair cost before discounts."] = "착용중인 장비의 할인 적용된 총 수리비입니다."

-- ## Attributes ##

	L["Health"] = "생명력"
	L["Power"] = "전원"
	L["Druid Mana"] = "드루이드 마나"
	L["Armor"] = "방어도"
	L["Strength"] = "힘"
	L["Agility"] = "민첩성"
	L["Intellect"] = "지능"
	L["Stamina"] = "체력"
	L["Damage"] = "피해"
	L["Attack Power"] = "전투력"
	L["Attack Speed"] = "공격 속도"
	L["Spell Power"] = "주문력"
	L["Mana Regen"] = "마나 회복량"
	L["Energy Regen"] = "기력 회복량"
	L["Rune Regen"] = "룬 재생 시건"
	L["Focus Regen"] = "집중 회복량"
	L["Movement Speed"] = "이동 속도"
	L["Durability"] = "내구도"
	L["Repair Total"] = "총 수리비"

-- ## Enhancements ##

	L["Critical Strike"] = "치명타 및 극대화"
	L["Haste"] = "가속"
	L["Versatility"] = "유연성"
	L["Mastery"] = "특화"
	L["Leech"] = "생기흡수"
	L["Avoidance"] = "광역회피"
	L["Dodge"] = "회피율"
	L["Parry"] = "무기 막기"
	L["Block"] = "방패 막기"

return end
