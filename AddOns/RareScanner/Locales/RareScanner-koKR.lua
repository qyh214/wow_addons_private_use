-- Locale
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local AL = AceLocale:NewLocale("RareScanner", "koKR", false);

if AL then
	AL["ALARM_MESSAGE"] = "희귀 NPC를 표시만 합니다, 맵을 확인하십시오!"
	AL["ALARM_SOUND"] = "희귀 NPC에 대한 경보음"
	AL["ALARM_SOUND_DESC"] = "희귀 NPC가 미니맵에 표시될 때 효과음을 재생합니다."
	AL["ALARM_TREASURES_SOUND"] = "이벤트/보물에 대한 경보음"
	AL["ALARM_TREASURES_SOUND_DESC"] = "보물/상자 또는 이벤트가 미니맵에 표시될 때 효과음을 재생합니다."
	AL["AUTO_HIDE_BUTTON"] = "버튼과 미니어쳐 자동 숨김"
	AL["AUTO_HIDE_BUTTON_DESC"] = "버튼과 미니어쳐를 선택한 시간(초 단위) 후에 자동으로 숨깁니다. 0초를 선택했다면 버튼과 미니어쳐는 자동으로 숨겨지지 않습니다."
	AL["CLEAR_FILTERS_SEARCH"] = "모두 표시"
	AL["CLEAR_FILTERS_SEARCH_DESC"] = "이전 검색을 초기화하고 전체 목록을 보여줍니다."
	AL["CLICK_TARGET"] = "NPC를 선택하려면 클릭"
	AL["DISABLE_SEARCHING_RARE_TOOLTIP"] = "이 희귀 NPC에 대한 알림을 비활성화합니다."
	AL["DISABLE_SOUND"] = "소리로 알림 비활성화"
	AL["DISABLE_SOUND_DESC"] = "활성화하면, 소리로 알림을 받을 수 없습니다."
	AL["DISABLED_SEARCHING_RARE"] = "이 희귀 NPC에 대해 알림 비활성화"
	AL["DISPLAY"] = "표시"
	AL["DISPLAY_BUTTON"] = "버튼과 미니어쳐 표시 토글"
	AL["DISPLAY_BUTTON_DESC"] = "버튼과 미니어쳐가 비활성화되면 다시 표시되지 않습니다. 이것은 알람음과 대화창 알림에는 영향을 미치지 않습니다."
	AL["DISPLAY_LOOT_PANEL"] = "전림품 획득 바 토글"
	AL["DISPLAY_LOOT_PANEL_DESC"] = "활성화하면, 발견된 NPC가 떨어뜨린 전리품을 바에 표시합니다."
	AL["DISPLAY_OPTIONS"] = "표시 옵션"
	AL["ENABLE_SCAN_CONTAINERS"] = "보물이나 상자 검색 토글"
	AL["ENABLE_SCAN_CONTAINERS_DESC"] = "활성화하면, 매번 보물이나 상자를 소리와 함께 시각적으로 미니 맵에 표시하여 알립니다."
	AL["ENABLE_SCAN_EVENTS"] = "이벤트 검색 토글"
	AL["ENABLE_SCAN_EVENTS_DESC"] = "활성화하면, 매번 이벤트를 소리와 함께 시각적으로 미니 맵에 표시하여 알립니다."
	AL["ENABLE_SCAN_GARRISON_CHEST"] = "주둔지 보물 검색 토글"
	AL["ENABLE_SCAN_GARRISON_CHEST_DESC"] = "활성화하면, 매번 주둔지 상자를 소리와 함께 시각적으로 미니 맵에 표시하여 알립니다."
	AL["ENABLE_SCAN_RARES"] = "희귀 NPC 검색 토글"
	AL["ENABLE_SCAN_RARES_DESC"] = "활성화하면, 매번 희귀 NPC를 소리와 함께 시각적으로 미니 맵에 표시하여 알립니다."
	AL["ENABLE_SEARCHING_RARE_TOOLTIP"] = "이 희귀 NPC에 대해 알림을 활성화합니다."
	AL["ENABLED_SEARCHING_RARE"] = "이 희귀 NPC에 대해 알림 활성화"
	AL["FILTER"] = "필터"
	AL["FILTER_RARE_LIST"] = "희귀 NPC 검색 필터"
	AL["FILTER_RARE_LIST_DESC"] = "희귀 NPC에 대한 검색을 토글합니다. 비활성화되면, NPC가 발견되도 알림을 받지 못합니다."
	AL["FILTER_ZONES_LIST"] = "지역 목록"
	AL["FILTER_ZONES_LIST_DESC"] = "이 지역에서 알림을 토글합니다. 이 지역에서 희귀 NPC, 이벤트 또는 보물 발견했을 때 알림을 원하지 않는 경우 비활성화합니다."
	AL["FILTERS"] = "희귀 NPC 필터"
	AL["FILTERS_SEARCH"] = "검색"
	AL["FILTERS_SEARCH_DESC"] = "목록 아래 필터할 NPC 이름을 입력하십시오."
	AL["GENERAL_OPTIONS"] = "기본 옵션"
	AL["LOOT_MIN_QUALITY"] = "최소 전리품 등급"
	AL["LOOT_MIN_QUALITY_DESC"] = "전리품 획득 바에 표시할 최소 전리품 등급을 결정합니다."
	AL["LOOT_PANEL_OPTIONS"] = "전리품 획득 바 옵션"
	AL["LOOT_TOOLTIP_POSITION"] = "전리품 획득 툴팁 위치"
	AL["LOOT_TOOLTIP_POSITION_DESC"] = "마우스를 아이콘 위로 가져갔을 때 표시되는 전리품 획득 툴팁을 어디에 표시할 지 결정합니다."
	AL["NOT_TARGETEABLE"] = "선택할 수 없는 대상"
	AL["SHOW_CHAT_ALERT"] = "대화창 알림 토글"
	AL["SHOW_CHAT_ALERT_DESC"] = "보물, 상자 또는 NPC를 발견할 때마다 대화창에 메시지를 표시합니다."
	AL["SOUND"] = "소리"
	AL["SOUND_OPTIONS"] = "소리 옵션"
	AL["TEST"] = "테스트 시작"
	AL["TEST_DESC"] = "알림 예제를 표시하려면 버튼을 누르세요. 패널을 다른 위치로 드래그 앤 드롭할 수 있습니다."
	AL["TOC_NOTES"] = "미니맵 스캐너. 매번 희귀 NPC, 보물/상자 또는 이벤트를 소리와 함께 시각적으로 미니 맵에 표시하여 알립니다."
	AL["TOOLTIP_BOTTOM"] = "아래쪽"
	AL["TOOLTIP_CURSOR"] = "커서위치"
	AL["TOOLTIP_LEFT"] = "왼쪽"
	AL["TOOLTIP_RIGHT"] = "오른쪽"
	AL["TOOLTIP_TOP"] = "위쪽"
	AL["UNKNOWN_TARGET"] = "알 수 없는 대상"
	AL["ZONES_FILTER"] = "지역 필터"
	AL["ZONES_FILTERS_SEARCH_DESC"] = "아래 목록에 필터할 지역 이름을 입력합니다."

	-- CONTINENT names
	AL["ZONES_CONTINENT_LIST"] = {
		[9999] = "Class Halls"; --Class Halls
		[9998] = "다크문 섬"; --Darkmoon Island
		[9997] = "Dungeons/Scenarios"; --Dungeons/Scenarios
		[9996] = "Raids"; --Raids
		[9995] = "Unknown"; --Unknown
	}
end