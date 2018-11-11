local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

--local LOCALE = GetLocale()

if namespace.locale == "koKR" then
	-- The EU English game client also
	-- uses the US English locale code.

-- #######################################################################################################################
-- ##	한국어 (Korean) translations provided by PositiveMind, yuk6196, netaras, meloppy, and next96 on Curseforge.		##
-- #######################################################################################################################

L["  /dcstats config: Opens the DejaCharacterStats addon config menu."] = "/dcstats config: DejaCharacterStats 애드온 설정 메뉴를 엽니다."
L["  /dcstats reset:  Resets DejaCharacterStats options to default."] = "/dcstats reset: DejaCharacterStats 설정을 기본값으로 초기화합니다."
--[[Translation missing --]]
--[[ L["%s of %s increases %s by %.2f%%"] = ""--]] 
L["About DCS"] = "DCS 정보"
L["All Stats"] = "모든 능력치"
--[[Translation missing --]]
--[[ L["Attack"] = ""--]] 
L["Average Durability"] = "평균 내구도"
L["Average equipped item durability percentage."] = "착용 중인 아이템의 평균 내구도 백분율입니다."
L["Average Item Level:"] = "평균 아이템 레벨:"
L["Avoidance Rating"] = "광역회피 수치"
--[[Translation missing --]]
--[[ L["Blizzard's Hide At Zero"] = ""--]] 
L["Character Stats:"] = "캐릭터 능력치:"
L["Class Colors"] = "직업 색상"
L["Class Crest Background"] = "직업 문장 배경"
L["Critical Strike Rating"] = "치명타 및 극대화 수치"
--[[Translation missing --]]
--[[ L["DCS's Hide At Zero"] = ""--]] 
L["Decimals"] = "소수점"
L["Defense"] = "방어"
--[[Translation missing --]]
--[[ L["Dejablue's improved character stats panel view."] = ""--]] 
L["DejaCharacterStats Slash commands (/dcstats):"] = "DejaCharacterStats 슬래시 명령어 (/dcstats):"
L["Displays a durability bar next to each item."] = "각 아이템 옆에 내구도 바를 표시합니다."
L["Displays average item durability on the character shirt slot and durability frames."] = "캐릭터 속옷 칸과 내구도 창에 착용 아이템의 평균 내구도를 표시합니다."
L["Displays average item level to one decimal place."] = "평균 아이템 레벨을 소수점 첫째 자리까지 표시합니다."
L["Displays average item level to two decimal places."] = "평균 아이템 레벨을 소수점 둘째 자리까지 표시합니다."
L["Displays average item level with class colors."] = "평균 아이템 레벨을 직업색상으로 표시합니다."
L["Displays each equipped item's durability."] = "각 착용 아이템의 내구도를 표시합니다."
L["Displays each equipped item's repair cost."] = "각 착용 아이템의 수리비를 표시합니다."
L["Displays 'Enhancements' category stats to two decimal places."] = "'강화 수치' 항목의 능력치를 소수점 2자리까지 표시합니다."
L["Displays Equipped/Available item levels unless equal."] = "동일하지 않으면 착용/소지 아이템 레벨을 표시합니다."
L["Displays the class crest background."] = "직업 문장 배경을 표시합니다."
L["Displays the DCS scrollbar."] = "DCS 스크롤바를 표시합니다"
L["Displays the Expand button for the character stats frame."] = "캐릭터 능력치 창에 확장 버튼을 표시합니다."
L["Displays the item level of each equipped item."] = "각 착용 아이템의 아이템 레벨을 표시합니다."
L["Dodge Rating"] = "회피 수치"
L["Durability"] = "내구도"
L["Durability Bars"] = "내구도 바"
L["Equipped/Available"] = "착용 중/소지 중"
L["Expand"] = "확장 표시"
L["General"] = "일반"
L["General global cooldown refresh time."] = "일반적인 전역 재사용 대기시간입니다."
L["Global Cooldown"] = "전역 재사용 대기시간"
L["Haste Rating"] = "가속 수치"
L["Hide Character Stats"] = "캐릭터 능력치 숨기기"
--[[Translation missing --]]
--[[ L["Hide low level mastery"] = ""--]] 
--[[Translation missing --]]
--[[ L["Hides 'Enhancements' stats if their displayed value would be zero. Checking 'Decimals' changes the displayed value."] = ""--]] 
--[[Translation missing --]]
--[[ L["Hides 'Enhancements' stats only if their numerical value is exactly zero. For example, if stat value is 0.001%, then it would be displayed as 0%."] = ""--]] 
--[[Translation missing --]]
--[[ L["Hides Mastery stat until the character starts to have benefit from it. Hiding Mastery with Select-A-Stat™ in the character panel has priority over this setting."] = ""--]] 
L["Item Durability"] = "아이템 내구도"
L["Item Level"] = "아이템 레벨"
L["Item Repair Cost"] = "아이템 수리비"
L["Item Slots:"] = "아이템 칸:"
L["Leech Rating"] = "생기흡수 수치"
L["Lock DCS"] = "DCS 잠그기"
L["Main Hand"] = "주장비"
L["Mastery Rating"] = "특화 수치"
L["Miscellaneous:"] = "기타:"
L["Movement Speed"] = "이동 속도"
L["Off Hand"] = "보조장비"
L["Offense"] = "공격"
L["One Decimal Place"] = "소수점 첫째 자리"
L["Parry Rating"] = "무기막기 수치"
L["Ratings"] = "수치"
L["Relevant Stats"] = "관련 능력치"
L["Repair Total"] = "총 수리비"
L["Requires Level "] = "최소 요구 레벨 "
L["Reset Stats"] = "능력치 초기화"
L["Reset to Default"] = "기본값으로 초기화"
L["Resets order of stats."] = "능력치 순서를 초기화합니다."
L["Scrollbar"] = "스크롤바"
L["Show all stats."] = "모든 능력치를 표시합니다."
L["Show Character Stats"] = "캐릭터 능력치 표시"
L["Show only stats relevant to your class spec."] = "직업 전문화와 관련된 능력치만 표시합니다."
L["Total equipped item repair cost before discounts."] = "착용 아이템의 할인 전 총 수리비입니다."
L["Two Decimal Places"] = "소수점 둘째 자리"
L["Unlock DCS"] = "DCS 잠금 해제"
L["Versatility Rating"] = "유연성 수치"
L["weapon auto attack (white) DPS."] = "무기의 자동 공격 (흰색) DPS입니다."
L["Weapon DPS"] = "무기 DPS"

return end
