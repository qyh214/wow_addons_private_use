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
	AL["CLASS_HALLS"] = "직업 전당"
	AL["CLEAR_FILTERS_SEARCH"] = "모두 표시"
	AL["CLEAR_FILTERS_SEARCH_DESC"] = "이전 검색을 초기화하고 전체 목록을 보여줍니다."
	AL["CLICK_TARGET"] = "NPC를 선택하려면 클릭"
	AL["CMD_HELP1"] = "명령어 목록"
	AL["CMD_HELP2"] = "- \"/rarescanner show\" 세계지도에 모든 아이콘을 표시"
	AL["CMD_HELP3"] = "- \"/rarescanner hide\" 세계지도에 모든 아이콘을 숨김"
	AL["CMD_HELP4"] = "- \"/rarescanner toggle\" 세계지도에 모든 아이콘을 표시/숨기기"
	AL["CMD_HELP5"] = "- \"/rarescanner toggle rares\" 또는 \"/rarescanner tr\" 세계지도에 NPC 아이콘을 표시/숨기기"
	AL["CMD_HELP6"] = "- \"/rarescanner toggle events\" 또는 \"/rarescanner te\" 세계지도에 이벤트 아이콘을 표시/숨기기"
	AL["CMD_HELP7"] = "- \"/rarescanner toggle treasures\" 또는 \"/rarescanner tt\" 세계지도에 보물 아이콘을 표시/숨기기"
	AL["CMD_HIDE"] = "세계지도에서 RareScanner 아이콘 숨기기"
	AL["CMD_HIDE_EVENTS"] = "세계지도에서 RareScanner 이벤트 아이콘 숨기기"
	AL["CMD_HIDE_RARES"] = "세계지도에서 RareScanner 희귀몹 아이콘 숨기기"
	AL["CMD_HIDE_TREASURES"] = "세계지도에서 RareScanner 보물 아이콘 숨기기"
	AL["CMD_SHOW"] = "세계 지도에 RareScanner 아이콘 표시"
	AL["CMD_SHOW_EVENTS"] = "세계지도에 RareScanner 이벤트 아이콘 표시"
	AL["CMD_SHOW_RARES"] = "세계지도에 RareScanner 희귀몹 아이콘 표시"
	AL["CMD_SHOW_TREASURES"] = "세계지도에 RareScanner 보물 아이콘 표시"
	AL["CONTAINER"] = "상자"
	AL["DATABASE_HARD_RESET"] = "가장 효율적인 확장과 마지막 RareScanner 버전 이후 데이터베이스에 큰 변화가 발생하여 불일치를 피하기 위해 데이터베이스를 재설정해야했습니다. 불편을 드려 죄송합니다."
	AL["DISABLE_SEARCHING_RARE_TOOLTIP"] = "이 희귀 NPC에 대한 알림을 비활성화합니다."
	AL["DISABLE_SOUND"] = "소리로 알림 비활성화"
	AL["DISABLE_SOUND_DESC"] = "활성화하면, 소리로 알림을 받을 수 없습니다."
	AL["DISABLED_SEARCHING_RARE"] = "이 희귀 NPC에 대해 알림 비활성화"
	AL["DISPLAY"] = "표시"
	AL["DISPLAY_BUTTON"] = "버튼과 미니어쳐 표시 토글"
	AL["DISPLAY_BUTTON_CONTAINERS"] = "보물/상자 버튼 표시 전환"
	AL["DISPLAY_BUTTON_CONTAINERS_DESC"] = "보물/상자 버튼 표시를 토글합니다. 경보음 및 채팅 알림에는 영향을 미치지 않습니다."
	AL["DISPLAY_BUTTON_DESC"] = "버튼과 미니어쳐가 비활성화되면 다시 표시되지 않습니다. 이것은 알람음과 대화창 알림에는 영향을 미치지 않습니다."
	AL["DISPLAY_BUTTON_SCALE"] = "버튼과 미니어쳐의 크기"
	AL["DISPLAY_BUTTON_SCALE_DESC"] = "이 옵션은 버튼의 크기와 미니어쳐가 조정되며 원래 크기는 0.85입니다."
	AL["DISPLAY_CONTAINER_ICONS"] = "세계지도에서 상자 아이콘 표시 전환"
	AL["DISPLAY_CONTAINER_ICONS_DESC"] = "비활성화하면 상자/보물 아이콘이 세계지도에 표시되지 않습니다."
	AL["DISPLAY_EVENT_ICONS"] = "세계지도에서 이벤트 아이콘 표시 전환"
	AL["DISPLAY_EVENT_ICONS_DESC"] = "비활성화하면 이벤트 아이콘이 세계지도에 표시되지 않습니다."
	AL["DISPLAY_LOG_WINDOW"] = "로그 창 표시 전환"
	AL["DISPLAY_LOG_WINDOW_DESC"] = "비활성화하면 로그 창이 다시 표시되지 않습니다."
	AL["DISPLAY_LOOT_ON_MAP"] = "지도 툴팁에 전리품 표시"
	AL["DISPLAY_LOOT_ON_MAP_DESC"] = "아이콘 위로 마우스를 움직일 때 표시되는 툴팁에 NPC/상자 전리품 표시를 전환합니다."
	AL["DISPLAY_LOOT_PANEL"] = "전림품 획득 바 토글"
	AL["DISPLAY_LOOT_PANEL_DESC"] = "활성화하면, 발견된 NPC가 떨어뜨린 전리품을 바에 표시합니다."
	AL["DISPLAY_MAP_NOT_DISCOVERED_ICONS"] = "검색되지 않은 아이콘을 지도에 표시하도록 전환"
	AL["DISPLAY_MAP_NOT_DISCOVERED_ICONS_DESC"] = "비활성화하면 희귀 NPC(빨간색과 주황색 아이콘), 상자 또는 이벤트가 발견되지 않은 아이콘이 세계지도에 표시되지 않습니다."
	AL["DISPLAY_MAP_OLD_NOT_DISCOVERED_ICONS"] = "이전 확장의 경우 검색되지 않은 아이콘 표시를 전환합니다."
	AL["DISPLAY_MAP_OLD_NOT_DISCOVERED_ICONS_DESC"] = "비활성화하면 희귀 NPC(빨간색 및 주황색 아이콘), 상자 또는 이벤트가 발견되지 않은 아이콘은 이전 확장에 속하는 영역에 대해 세계지도에 표시되지 않습니다."
	AL["DISPLAY_MINIATURE"] = "미니어처 표시 전환"
	AL["DISPLAY_MINIATURE_DESC"] = "비활성화하면 미니어처가 다시 표시되지 않습니다."
	AL["DISPLAY_NPC_ICONS"] = "세계지도에서 희귀 NPC 아이콘 표시 전환"
	AL["DISPLAY_NPC_ICONS_DESC"] = "비활성화하면 희귀 NPC 아이콘이 세계지도에 표시되지 않습니다."
	AL["DISPLAY_OPTIONS"] = "표시 옵션"
	AL["DUNGEONS_SCENARIOS"] = "던전/시나리오"
	AL["ENABLE_MARKER"] = "대상 표시기 켜기/끄기"
	AL["ENABLE_MARKER_DESC"] = "이 기능이 활성화되면 메인 버튼을 클릭할 때 대상 위에 징표가 표시됩니다."
	AL["ENABLE_SCAN_CHAT"] = "채팅 메시지를 통해 희귀 NPC 검색 표시 전환"
	AL["ENABLE_SCAN_CHAT_DESC"] = "이 기능이 활성화되면 희귀 NPC가 나타날 때 소리를 내거나 희귀 NPC와 관련된 채팅 메시지가 감지될 때마다 시각적으로 경고를 합니다."
	AL["ENABLE_SCAN_CONTAINERS"] = "보물이나 상자 검색 토글"
	AL["ENABLE_SCAN_CONTAINERS_DESC"] = "활성화하면, 매번 보물이나 상자를 소리와 함께 시각적으로 미니 맵에 표시하여 알립니다."
	AL["ENABLE_SCAN_EVENTS"] = "이벤트 검색 토글"
	AL["ENABLE_SCAN_EVENTS_DESC"] = "활성화하면, 매번 이벤트를 소리와 함께 시각적으로 미니 맵에 표시하여 알립니다."
	AL["ENABLE_SCAN_GARRISON_CHEST"] = "주둔지 보물 검색 토글"
	AL["ENABLE_SCAN_GARRISON_CHEST_DESC"] = "활성화하면, 매번 주둔지 상자를 소리와 함께 시각적으로 미니 맵에 표시하여 알립니다."
	AL["ENABLE_SCAN_IN_INSTANCE"] = "인스턴스에서 검색 표시 전환"
	AL["ENABLE_SCAN_IN_INSTANCE_DESC"] = "이 기능이 활성화되면 애드온은 인스턴스(던전, 공격대 등)에 있는 동안 평소와 같이 작동합니다."
	AL["ENABLE_SCAN_ON_TAXI"] = "새나 배로 이동하는 동안 표시 전환"
	AL["ENABLE_SCAN_ON_TAXI_DESC"] = "이 기능이 활성화되면 운송 수단(비행기, 보트 등)을 사용하는 동안 애드온이 정상적으로 작동합니다."
	AL["ENABLE_SCAN_RARES"] = "희귀 NPC 검색 토글"
	AL["ENABLE_SCAN_RARES_DESC"] = "활성화하면, 매번 희귀 NPC를 소리와 함께 시각적으로 미니 맵에 표시하여 알립니다."
	AL["ENABLE_SEARCHING_RARE_TOOLTIP"] = "이 희귀 NPC에 대해 알림을 활성화합니다."
	AL["ENABLE_TOMTOM_SUPPORT"] = "TomTom 지원 켜기/끄기"
	AL["ENABLE_TOMTOM_SUPPORT_DESC"] = "이것이 활성화되면 엔티티의 찾은 좌표에 Tomtom의 웨이 포인트가 추가됩니다."
	AL["ENABLED_SEARCHING_RARE"] = "이 희귀 NPC에 대해 알림 활성화"
	AL["EVENT"] = "이벤트"
	AL["FILTER"] = "필터"
	AL["FILTER_CONTINENT"] = "대륙/범주"
	AL["FILTER_CONTINENT_DESC"] = "대륙 또는 범주 이름"
	AL["FILTER_NPCS_ONLY_MAP"] = "세계 지도에서만 필터 사용"
	AL["FILTER_NPCS_ONLY_MAP_DESC"] = "활성화 된 경우에도 필터링 된 NPC에서 경고가 표시되지만 세계지도에는 표시되지 않습니다. 비활성화하면 필터링 된 NPC에서 알림을 전혀받지 않습니다."
	AL["FILTER_RARE_LIST"] = "희귀 NPC 검색 필터"
	AL["FILTER_RARE_LIST_DESC"] = "희귀 NPC에 대한 검색을 토글합니다. 비활성화되면, NPC가 발견되도 알림을 받지 못합니다."
	AL["FILTER_ZONE"] = "지역"
	AL["FILTER_ZONE_DESC"] = "대륙 또는 범주 내부 지역"
	AL["FILTER_ZONES_LIST"] = "지역 목록"
	AL["FILTER_ZONES_LIST_DESC"] = "이 지역에서 알림을 토글합니다. 이 지역에서 희귀 NPC, 이벤트 또는 보물 발견했을 때 알림을 원하지 않는 경우 비활성화합니다."
	AL["FILTER_ZONES_ONLY_MAP"] = "세계 지도에서만 필터 사용"
	AL["FILTER_ZONES_ONLY_MAP_DESC"] = "활성화 된 경우 여전히 필터링 된 지역에 속하는 NPC로 부터 경고를 받지만 세계지도에는 표시되지 않습니다. 비활성화하면 필터링 된 영역에 속하는 NPC에서 경고를 받지 않습니다."
	AL["FILTERS"] = "희귀 NPC 필터"
	AL["FILTERS_SEARCH"] = "검색"
	AL["FILTERS_SEARCH_DESC"] = "목록 아래 필터할 NPC 이름을 입력하십시오."
	AL["GENERAL_OPTIONS"] = "기본 옵션"
	AL["JUST_SPAWNED"] = "%s 나타났습니다. 지도를 확인해보십시오!"
	AL["LEFT_BUTTON"] = "좌클릭"
	AL["LOG_WINDOW_AUTOHIDE"] = "기록된 NPC 버튼 자동 숨기기"
	AL["LOG_WINDOW_AUTOHIDE_DESC"] = "선택한 시간(분) 후 각 NPC 버튼을 숨긴다. 0분을 선택하면 로그 윈도우를 닫을 때까지 버튼이 유지되거나 최대 버튼 수에 도달할 때까지 버튼이 유지된다(이 경우 가장 오래된 버튼은 교체됨)."
	AL["LOG_WINDOW_OPTIONS"] = "로그 창 옵션"
	AL["LOOT_CATEGORY_FILTERED"] = "범주/하위범주에 대해 필터 활성화: %s/%s. 아이콘을 다시 클릭하거나 RareScanner 애드온 메뉴에서 이 필터를 비활성화할 수 있습니다."
	AL["LOOT_CATEGORY_FILTERS"] = "범주 필터"
	--[[Translation missing --]]
	AL["LOOT_CATEGORY_FILTERS_DESC"] = "Filter the loot shown by category"
	--[[Translation missing --]]
	AL["LOOT_CATEGORY_NOT_FILTERED"] = "Filter disabled for the category/subcategory: %s/%s"
	AL["LOOT_DISPLAY_OPTIONS"] = "표시 옵션"
	--[[Translation missing --]]
	AL["LOOT_DISPLAY_OPTIONS_DESC"] = "Display options for the loot bar"
	--[[Translation missing --]]
	AL["LOOT_FILTER_COLLECTED"] = "Filter collected pets, mounts and toys."
	--[[Translation missing --]]
	AL["LOOT_FILTER_COLLECTED_DESC"] = "When activated, only mounts, pets and toys that you haven't collected yet will be show on the loot bar. This filter doesn't affect other kinds of lootable items, whatsoever."
	--[[Translation missing --]]
	AL["LOOT_FILTER_COMPLETED_QUEST"] = "Filter quest items that don't begin a new quest"
	--[[Translation missing --]]
	AL["LOOT_FILTER_COMPLETED_QUEST_DESC"] = "When activated, any item that is a requirement for a quest, or that begins an already completed quest, won't show up on the loot bar."
	--[[Translation missing --]]
	AL["LOOT_FILTER_NOT_EQUIPABLE"] = "Filter non-equipable items"
	--[[Translation missing --]]
	AL["LOOT_FILTER_NOT_EQUIPABLE_DESC"] = "When activated, armor and weapons that this character cannot wear won't show up on the loot bar. This filter doesn't affect other kinds of lootable items, whatsoever."
	--[[Translation missing --]]
	AL["LOOT_FILTER_NOT_MATCHING_CLASS"] = "Filter items that require a different class than yours"
	--[[Translation missing --]]
	AL["LOOT_FILTER_NOT_MATCHING_CLASS_DESC"] = "When activated, any item that requires a specific class to be used that doesn't match yours, won't show up on the loot bar."
	--[[Translation missing --]]
	AL["LOOT_FILTER_NOT_TRANSMOG"] = "Show only transmog armor and weapons"
	--[[Translation missing --]]
	AL["LOOT_FILTER_NOT_TRANSMOG_DESC"] = "When activated, only armor and weapons that you haven't collected yet will be shown on the loot bar. This filter doesn't affect other kinds of lootable items, whatsoever."
	--[[Translation missing --]]
	AL["LOOT_FILTER_SUBCATEGORY_DESC"] = "Toggle showing this kind of loot on the loot bar. When disabled you won't see any item that matches this category on the loot shown when you find a rare NPC."
	AL["LOOT_FILTER_SUBCATEGORY_LIST"] = "하위범주"
	--[[Translation missing --]]
	AL["LOOT_ITEMS_PER_ROW"] = "Number of items per row to display"
	--[[Translation missing --]]
	AL["LOOT_ITEMS_PER_ROW_DESC"] = "Sets the number of items to display per row on the loot bar. If the number is less than the maximum several rows will be displayed."
	--[[Translation missing --]]
	AL["LOOT_MAIN_CATEGORY"] = "Main category"
	--[[Translation missing --]]
	AL["LOOT_MAX_ITEMS"] = "Number of items to display"
	--[[Translation missing --]]
	AL["LOOT_MAX_ITEMS_DESC"] = "Sets the maximum number of items to display on the loot bar."
	AL["LOOT_MIN_QUALITY"] = "최소 전리품 등급"
	AL["LOOT_MIN_QUALITY_DESC"] = "전리품 획득 바에 표시할 최소 전리품 등급을 결정합니다."
	AL["LOOT_OPTIONS"] = "전리품 옵션"
	AL["LOOT_OTHER_FILTERS"] = "기타 필터"
	AL["LOOT_OTHER_FILTERS_DESC"] = "기타 필터"
	AL["LOOT_PANEL_OPTIONS"] = "전리품 획득 바 옵션"
	AL["LOOT_SUBCATEGORY_FILTERS"] = "하위범주 필터"
	AL["LOOT_TOGGLE_FILTER"] = "Alt+좌클릭으로 필터 켜기/끄기"
	AL["LOOT_TOOLTIP_POSITION"] = "전리품 획득 툴팁 위치"
	AL["LOOT_TOOLTIP_POSITION_DESC"] = "마우스를 아이콘 위로 가져갔을 때 표시되는 전리품 획득 툴팁을 어디에 표시할 지 결정합니다."
	AL["MAIN_BUTTON_OPTIONS"] = "주 버튼 옵션"
	--[[Translation missing --]]
	AL["MAP_MENU_DISABLE_LAST_SEEN_CONTAINER_FILTER"] = "Show containers that you saw a long time ago but that can respawn"
	--[[Translation missing --]]
	AL["MAP_MENU_DISABLE_LAST_SEEN_EVENT_FILTER"] = "Show events that you saw a long time ago but that can respawn"
	--[[Translation missing --]]
	AL["MAP_MENU_DISABLE_LAST_SEEN_FILTER"] = "Show rare NPCs that you saw a long time ago but that can respawn"
	--[[Translation missing --]]
	AL["MAP_MENU_SHOW_CONTAINERS"] = "Show container icons on map"
	--[[Translation missing --]]
	AL["MAP_MENU_SHOW_EVENTS"] = "Show event icons on map"
	--[[Translation missing --]]
	AL["MAP_MENU_SHOW_NOT_DISCOVERED"] = "Not discovered entities"
	--[[Translation missing --]]
	AL["MAP_MENU_SHOW_NOT_DISCOVERED_OLD"] = "Not discovered entities (older expansions)"
	--[[Translation missing --]]
	AL["MAP_MENU_SHOW_RARE_NPCS"] = "Show rare NPC icons on map"
	--[[Translation missing --]]
	AL["MAP_NEVER"] = "Never"
	AL["MAP_OPTIONS"] = "지도 옵션"
	AL["MAP_SCALE_ICONS"] = "아이콘의 크기"
	AL["MAP_SCALE_ICONS_DESC"] = "이렇게 하면 아이콘의 크기가 원래 크기 1로 조정됩니다."
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_COLLECTED"] = "Keep showing container icons after looted"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_COLLECTED_DESC"] = "When disabled the icon will disappear after you loot the container."
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_COMPLETED"] = "Keep showing event icons after completion"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_COMPLETED_DESC"] = "When disabled the icon will disappear after you complete the event."
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_DEAD"] = "Keep showing NPC icons after death"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_DEAD_DESC"] = "When disabled the icon will disappear after you kill the NPC. The icon will reappear as soon as you find the NPC again. This option only works with NPCs that keep being rares after killing them."
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_DEAD_RESETEABLE"] = "Keep showing NPC icons after death (only in resetable zones)"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_DEAD_RESETEABLE_DESC"] = "When disabled the icon will disappear after you kill the NPC. The icon will reappear as soon as you find the NPC again. This option only works with NPCs that keep being rares after killing them in zones that reset with world quests."
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_CONTAINER_MAX_SEEN_TIME"] = "Timer to hide container icons (in minutes)"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_CONTAINER_MAX_SEEN_TIME_DESC"] = "Sets the maximum number of minutes since you have seen the container. After that time, the icon won't be shown on the world map until you find the container again. If you select zero minutes the icons will be shown regardless of how long since you have seen the container. This filter doesn't apply to containers that are part of an achievement."
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_EVENT_MAX_SEEN_TIME"] = "Timer to hide event icons (in minutes)"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_EVENT_MAX_SEEN_TIME_DESC"] = "Sets the maximum number of minutes since you have seen the event. After that time, the icon won't be shown on the world map until you find the event again. If you select zero minutes the icons will be shown regardless of how long since you have seen the event."
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_MAX_SEEN_TIME"] = "Timer to hide rare NPC icons (in hours)"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_MAX_SEEN_TIME_DESC"] = "Sets the maximum number of hours since you have seen the NPC. After that time, the icon won't be shown on the world map until you find the NPC again. If you select zero hours the icons will be shown regardless of how long since you have seen the rare NPC."
	AL["MAP_TOOLTIP_ACHIEVEMENT"] = "%s 업적의 목표입니다."
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_ALREADY_COMPLETED"] = "This event is already completed. Restart on: %s"
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_ALREADY_KILLED"] = "This NPC is already killed. Restart on: %s"
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_ALREADY_OPENED"] = "This container is already opened. Restart on: %s"
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_CONTAINER_LOOTED"] = "Shift-Left-Click to set as looted."
	AL["MAP_TOOLTIP_DAYS"] = "일"
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_EVENT_DONE"] = "Shift-Left-Click to set as completed"
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_IGNORE_ICON"] = "Shift-Left-Click to hide this icon forever if it shouldn't be here."
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_KILLED"] = "Shift-Left-Click to set as killed"
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_NOT_FOUND"] = "You haven't seen this NPC and no one has shared it with you yet."
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_SEEN"] = "Seen before: %s"
	AL["MARKER"] = "대상 표시기"
	AL["MARKER_DESC"] = "메인 버튼을 클릭할 때 대상 위에 추가할 마크를 선택합니다."
	AL["MESSAGE_OPTIONS"] = "메시지 옵션"
	AL["MIDDLE_BUTTON"] = "휠 클릭"
	--[[Translation missing --]]
	AL["NAVIGATION_ENABLE"] = "Toggle navigation"
	--[[Translation missing --]]
	AL["NAVIGATION_ENABLE_DESC"] = "When enabled the navigation arrows will show up beside the main button to allow you access to newer or older entities found"
	--[[Translation missing --]]
	AL["NAVIGATION_LOCK_ENTITY"] = "Block display of new entities if one is already shown"
	--[[Translation missing --]]
	AL["NAVIGATION_LOCK_ENTITY_DESC"] = "When enabled, if the main button is displaying an entity in your screen, it won't update to a newer one automatically. An arrow will appear allowing you to access the new entity whenever you are ready"
	AL["NAVIGATION_OPTIONS"] = "탐색 옵션"
	--[[Translation missing --]]
	AL["NAVIGATION_SHOW_NEXT"] = "Show next entity found"
	--[[Translation missing --]]
	AL["NAVIGATION_SHOW_PREVIOUS"] = "Show previous entity found"
	AL["NOT_TARGETEABLE"] = "선택할 수 없는 대상"
	--[[Translation missing --]]
	AL["NOTE_130350"] = "You have to ride this rare to the container that you will find by following the path to the right of this position."
	--[[Translation missing --]]
	AL["NOTE_131453"] = "You have to ride [Guardian of the Spring] to this position. The horse is a friendly rare that you will find by following the path to the left of this container."
	--[[Translation missing --]]
	AL["NOTE_135497"] = "Only available while doing the daily quest [Aid from Nordrassil] obtained from Mylune. While you are on this quest you will find mushrooms under the trees. Clicking on them might spawn this NPC."
	--[[Translation missing --]]
	AL["NOTE_149847"] = "When you aproach to him, he will tell you a colour that he hates. Once you know what colour it is, you have to go to the coordinates 63.41 where you will be painted that colour. When you will come back to his position, he will attack you."
	--[[Translation missing --]]
	AL["NOTE_150342"] = "Only available during the event [Drill Rig DR-TR35]."
	--[[Translation missing --]]
	AL["NOTE_150394"] = "In order to kill him you have to bring him to the coordinates 63.38, where there is a device with blue lightning. Once the NPC is touched by lightning, it will explode and you will be able to loot him."
	--[[Translation missing --]]
	AL["NOTE_151124"] = "You have to loot a [Smashed Transport Relay] from the enemies that appear during the event [Drill Rig DR-JD99] (coordinates 59.67) and then use it on the machine that is found on the platform."
	--[[Translation missing --]]
	AL["NOTE_151159"] = "He is available only when [Oglethorpe Obnoticus] is in Mechagon (coordinates 72.37). He wanders around Mechagon, so check in every street. Killing him makes [OOX-Avenger/MG] to spawn."
	--[[Translation missing --]]
	AL["NOTE_151202"] = "In order to summon him you have to connect the [Wires] on the shore, with the [Pylons] inside the water."
	--[[Translation missing --]]
	AL["NOTE_151296"] = "First check if [Oglethorpe Obnoticus] is in Mechagon (coordinates 72.37). If he is there, then you have to find and kill [OOX-Fleetfoot/MG] (it is a chicken robot wandering around Mechagon). Once you find him and kill him, come back to this icon's coordinates."
	--[[Translation missing --]]
	AL["NOTE_151308"] = "Only available during [Drill Rig] events."
	--[[Translation missing --]]
	AL["NOTE_151569"] = "You require a [Hundred-Fathom Lure] to summon it."
	--[[Translation missing --]]
	AL["NOTE_151627"] = "You need to use a [Exothermic Evaporator Coil] on the machine that is found on the platform."
	--[[Translation missing --]]
	AL["NOTE_151933"] = "In order to kill him you have to use [Beastbot Powerpack] (you can get the schema at the coordinates 60.41)."
	--[[Translation missing --]]
	AL["NOTE_152007"] = "It is wandering in this area, so the coordinates might not be very accurate."
	--[[Translation missing --]]
	AL["NOTE_152113"] = "Only available during the event [Drill Rig DR-CC88]."
	--[[Translation missing --]]
	AL["NOTE_152569"] = "When you aproach to him, he will tell you a colour that he hates. Once you know what colour it is, you have to go to the coordinates 63.41 where you will be painted that colour. When you will come back to his position, he will attack you."
	--[[Translation missing --]]
	AL["NOTE_152570"] = "When you aproach to him, he will tell you a colour that he hates. Once you know what colour it is, you have to go to the coordinates 63.41 where you will be painted that colour. When you will come back to his position, he will attack you."
	--[[Translation missing --]]
	AL["NOTE_153000"] = "Only available while the daily quest [Bugs, Lots of 'Em!] is active."
	--[[Translation missing --]]
	AL["NOTE_153200"] = "Only available during the event [Drill Rig DR-JD41]."
	--[[Translation missing --]]
	AL["NOTE_153205"] = "Only available during the event [Drill Rig DR-JD99]."
	--[[Translation missing --]]
	AL["NOTE_153206"] = "Only available during the event [Drill Rig DR-TR28]."
	--[[Translation missing --]]
	AL["NOTE_153228"] = "It shows up after killing a LOT of [Upgraded Sentry] that wander around the area."
	--[[Translation missing --]]
	AL["NOTE_154225"] = "He is available only on the interface that you can access using [Personal Time Displacer] that you can create with resources collected in Mechagon. Important: He won't spawn while Chromie's daily quest is available."
	--[[Translation missing --]]
	AL["NOTE_154332"] = "It is in a cave. The entrance is located at the coordinates 57,38."
	--[[Translation missing --]]
	AL["NOTE_154333"] = "It is in a cave. The entrance is located at the coordinates 57,38."
	--[[Translation missing --]]
	AL["NOTE_154342"] = "He is available only on the interface that you can access using [Personal Time Displacer] that you can create with resources collected in Mechagon."
	--[[Translation missing --]]
	AL["NOTE_154559"] = "It is in a cave. The entrance is located at the coordinates 70,58."
	--[[Translation missing --]]
	AL["NOTE_154604"] = "It is in a cave. The entrance is located at the coordinates 36,20."
	--[[Translation missing --]]
	AL["NOTE_154701"] = "Only available during the event [Drill Rig DR-CC61]."
	--[[Translation missing --]]
	AL["NOTE_154739"] = "Only available during the event [Drill Rig DR-CC73]."
	--[[Translation missing --]]
	AL["NOTE_155531"] = "You have to use the orb above him (Essence of the Sun) to get [Aura of the Sun] and be able to attack him."
	--[[Translation missing --]]
	AL["NOTE_156709"] = "You have to kill Faceless Despoiler (normal NPC) to force this one to spawn."
	--[[Translation missing --]]
	AL["NOTE_157162"] = "Inside the temple. The entrance is located at the coordinates 22,24."
	--[[Translation missing --]]
	AL["NOTE_158531"] = "You have to kill Voidwarped Neferset (normal NPC) to force this one to spawn."
	--[[Translation missing --]]
	AL["NOTE_158632"] = "You have to kill Burbling Fleshbeast (normal NPC) to force this one to spawn."
	--[[Translation missing --]]
	AL["NOTE_158706"] = "You have to kill Oozing Putrefaction (normal NPC) to force this one to spawn."
	--[[Translation missing --]]
	AL["NOTE_159087"] = "You have to kill N'Zoth Bonestripper (normal NPC) to force this one to spawn."
	--[[Translation missing --]]
	AL["NOTE_160968"] = "Inside the temple. The entrance is located at the coordinates 22,24."
	--[[Translation missing --]]
	AL["NOTE_162171"] = "It is in a cave. The entrance is located at the coordinates 45,58."
	--[[Translation missing --]]
	AL["NOTE_162352"] = "It is in a cave. The entrance is underwater at the coordinates 52,40."
	--[[Translation missing --]]
	AL["NOTE_280951"] = "Follow the railway until you find a cart. Ride it to discover the treasure."
	--[[Translation missing --]]
	AL["NOTE_287239"] = "If you are horde you have to complete Vol'dun campaign in order to have access to the temple."
	--[[Translation missing --]]
	AL["NOTE_289647"] = "The treasure is in a cave. The entrance is at the coordinates 65.11, between some trees almost on top of the mountain."
	--[[Translation missing --]]
	AL["NOTE_292673"] = "1 of 5 scrolls. Read all of them to discover the treasure [Secret of the Depths]. It is in the basement. Hide this icon manually once you read it."
	--[[Translation missing --]]
	AL["NOTE_292674"] = "2 of 5 scrolls. Read all of them to discover the treasure [Secret of the Depths]. It is under the wood floor, in the corner beside a bunch of candles. Hide this icon manually once you read it."
	--[[Translation missing --]]
	AL["NOTE_292675"] = "3 of 5 scrolls. Read all of them to discover the treasure [Secret of the Depths]. It is in the basement. Hide this icon manually once you read it."
	--[[Translation missing --]]
	AL["NOTE_292676"] = "4 of 5 scrolls. Read all of them to discover the treasure [Secret of the Depths]. It is in the top floor. Hide this icon manually once you read it."
	--[[Translation missing --]]
	AL["NOTE_292677"] = "5 of 5 scrolls. Read all of them to discover the treasure [Secret of the Depths]. It is in an underground cave. The entrance is under water at the coordinates 72.40 (water pool at the monastery). Hide this icon manually once you read it."
	--[[Translation missing --]]
	AL["NOTE_292686"] = "After reading the 5 scrolls, use the [Ominous Altar] to obtain [Secret of the Depths]. Warning: Using the altar will teleport you to the middle of the sea. Hide this icon manually once you use it."
	--[[Translation missing --]]
	AL["NOTE_293349"] = "It is inside the shed, on top of a shelf."
	--[[Translation missing --]]
	AL["NOTE_293350"] = "This treasure is hidden in a cave underneath. Go to the coordinates 61.38, and set the camera on top, then jump backwards through the little crack on the floor and land on the ledge."
	--[[Translation missing --]]
	AL["NOTE_293852"] = "You won't see this until you collect [Soggy Treasure Map] from the pirates at Freehold"
	--[[Translation missing --]]
	AL["NOTE_293880"] = "You won't see this until you collect [Fading Treasure Map] from the pirates at Freehold"
	--[[Translation missing --]]
	AL["NOTE_293881"] = "You won't see this until you collect [Yellowed Treasure Map] from the pirates at Freehold"
	--[[Translation missing --]]
	AL["NOTE_293884"] = "You won't see this until you collect [Singed Treasure Map] from the pirates at Freehold"
	--[[Translation missing --]]
	AL["NOTE_297828"] = "The raven flying on top holds the key. Kill it."
	--[[Translation missing --]]
	AL["NOTE_297891"] = "You have to disable the runes in this order: Left, Down, Up, Right"
	--[[Translation missing --]]
	AL["NOTE_297892"] = "You have to disable the runes in this order: Left, Right, Down, Up"
	--[[Translation missing --]]
	AL["NOTE_297893"] = "You have to disable the runes in this order: Right, Up, Left, Down"
	--[[Translation missing --]]
	AL["NOTE_326395"] = "You have to enable the [Arcane device] that is found on top of a table beside the chest in order to start the minigame. To pass the game you have to separate the three triangles. Click on the orbs to switch their positions."
	--[[Translation missing --]]
	AL["NOTE_326396"] = "You have to enable the [Arcane device] that is found on the ground beside the chest in order to start the minigame. To pass the game you have to separate the two rectangles. Click on the orbs to switch their positions."
	--[[Translation missing --]]
	AL["NOTE_326397"] = "You have to enable the [Arcane device] that is found on the ground beside the chest in order to start the minigame. To pass the game you have to line up three red runes."
	--[[Translation missing --]]
	AL["NOTE_326398"] = "You have to enable the [Arcane device] that is found on top of a table beside the chest in order to start the minigame. To pass the game you have to line up four cyan runes."
	--[[Translation missing --]]
	AL["NOTE_326399"] = "It's in a cave underwater. You have to complete a minigame where you have to shoot the fire balls before they touch the circles on the ground. Everytime a ball touches the ground or you use the spell without hitting a ball, the energy will decrease, and if it reaches zero then you will have to start again."
	--[[Translation missing --]]
	AL["NOTE_326400"] = "It is in a cave. You have to complete a minigame where you have to shoot the fire balls before they touch the circles on the ground. Everytime a ball touches the ground or you use the spell without hitting a ball, the energy will decrease, and if it reaches zero then you will have to start again."
	--[[Translation missing --]]
	AL["NOTE_326403"] = "It is inside the building. You have to access it from the back."
	--[[Translation missing --]]
	AL["NOTE_326405"] = "It is between some ruins in the highest level of the map."
	--[[Translation missing --]]
	AL["NOTE_326406"] = "It is on top of a mountain in the highest level of the map. It's hard to get there on foot, but it's possible from the south side."
	--[[Translation missing --]]
	AL["NOTE_326407"] = "It is on top of a mountain in the highest level of the map."
	--[[Translation missing --]]
	AL["NOTE_326408"] = "It is in a cave underwater. The entrance is in the lake to the south (coordinates 57,39)."
	--[[Translation missing --]]
	AL["NOTE_326410"] = "It is in a cave in the lower level of the map."
	--[[Translation missing --]]
	AL["NOTE_326411"] = "It is between some stones in the highest level of the map."
	--[[Translation missing --]]
	AL["NOTE_326413"] = "It is in a cave in the lower level of the map."
	--[[Translation missing --]]
	AL["NOTE_326415"] = "It requires flying or you can use a [Goblin Glider Kit] from the tall mountain beside. The chest is on top of the coral bridge."
	--[[Translation missing --]]
	AL["NOTE_326416"] = "It is in the highest level of the map, inside a tower in ruins."
	--[[Translation missing --]]
	AL["NOTE_329783"] = "It is on the roof (access at coordinates 83.33). You have to complete a minigame where you have to shoot the fire balls before they touch the circles on the ground. Everytime a ball touches the ground or you use the spell without hitting a ball, the energy will decrease, and if it reaches zero then you will have to start again."
	--[[Translation missing --]]
	AL["NOTE_332220"] = "You have to complete a minigame where you have to shoot the fire balls before they touch the circles on the ground. Everytime a ball touches the ground or you use the spell without hitting a ball, the energy will decrease, and if it reaches zero then you will have to start again."
	AL["PROFILES"] = "프로필"
	AL["RAIDS"] = "공격대"
	AL["RESET_POSITION"] = "위치 리셋"
	AL["RESET_POSITION_DESC"] = "메인 버튼의 원래 위치를 복원한다."
	AL["SHOW_CHAT_ALERT"] = "대화창 알림 토글"
	AL["SHOW_CHAT_ALERT_DESC"] = "보물, 상자 또는 NPC를 발견할 때마다 대화창에 메시지를 표시합니다."
	AL["SHOW_RAID_WARNING"] = "공격대 경보 표시 켜기/끄기"
	AL["SHOW_RAID_WARNING_DESC"] = "보물, 상자 또는 NPC가 발견될 때마다 화면에 공격대 경보 표시"
	AL["SOUND"] = "소리"
	AL["SOUND_OPTIONS"] = "소리 옵션"
	AL["SOUND_VOLUME"] = "음량"
	AL["SOUND_VOLUME_DESC"] = "음량을 설정합니다."
	AL["SYNCRONIZATION_COMPLETED"] = "동기화 완료됨."
	AL["SYNCRONIZE"] = "데이터베이스 동기화"
	--[[Translation missing --]]
	AL["SYNCRONIZE_DESC"] = "This will analize which rare NPCs and treasures that are part of an achievement you have killed/collected already, and they will disappear from your map. There is no way to know the state of non-achievement rare NPCs and treasures, so they will remain in your map as they are currently shown."
	AL["TEST"] = "테스트 시작"
	AL["TEST_DESC"] = "알림 예제를 표시하려면 버튼을 누르세요. 패널을 다른 위치로 드래그 앤 드롭할 수 있습니다."
	AL["TOC_NOTES"] = "미니맵 스캐너. 매번 희귀 NPC, 보물/상자 또는 이벤트를 소리와 함께 시각적으로 미니 맵에 표시하여 알립니다."
	AL["TOGGLE_FILTERS"] = "필터 켜기/끄기"
	AL["TOGGLE_FILTERS_DESC"] = "모든 필터를 한 번에 켜고 끕니다."
	AL["TOOLTIP_BOTTOM"] = "아래쪽"
	AL["TOOLTIP_CURSOR"] = "커서위치"
	AL["TOOLTIP_LEFT"] = "왼쪽"
	AL["TOOLTIP_RIGHT"] = "오른쪽"
	AL["TOOLTIP_TOP"] = "위쪽"
	AL["UNKNOWN"] = "알수없음"
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