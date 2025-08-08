-- ♡ Translation // Crazyyoungs

---@class addon
local addon = select(2, ...)
local L = addon.C.AddonInfo.Locales

--------------------------------

L.koKR = {}
local NS = L.koKR; L.koKR = NS

--------------------------------

function NS:Load()
	if GetLocale() ~= "koKR" then
		return
	end

	--------------------------------
	-- 일반
	--------------------------------

	do

	end

	--------------------------------
	-- 웨이포인트 시스템
	--------------------------------

	do
		-- PINPOINT
		L["WaypointSystem - Pinpoint - Quest - Complete"] = "퀘스트 완료 후 보고 가능"
	end

	--------------------------------
	-- 슬래시 명령어
	--------------------------------

	do
		L["SlashCommand - /way - Map ID - Prefix"] = "현재 지도ID: "
		L["SlashCommand - /way - Map ID - Suffix"] = ""
		L["SlashCommand - /way - Position - Axis (X) - Prefix"] = "X: "
		L["SlashCommand - /way - Position - Axis (X) - Suffix"] = ""
		L["SlashCommand - /way - Position - Axis (Y) - Prefix"] = ", Y: "
		L["SlashCommand - /way - Position - Axis (Y) - Suffix"] = ""
	end

	--------------------------------
	-- 설정
	--------------------------------

	do
		L["Config - General"] = "일반"
		L["Config - General - Title"] = "일반"
		L["Config - General - Title - Subtext"] = "전체 설정을 사용자 지정합니다."
		L["Config - General - Preferences"] = "환경 설정"
		L["Config - General - Preferences - Meter"] = "단위를 야드 대신 미터 변경"
		L["Config - General - Preferences - Meter - Description"] = "측정 단위를 미터법으로 변경합니다.\n[ 거리가 1000M 이상이면 1KM 단위가 변경 됩니다. ]"
		L["Config - General - Preferences - Font"] = "글꼴";
		L["Config - General - Preferences - Font - Description"] = "애드온 전반에 사용되는 글꼴입니다.";
		L["Config - General - Reset"] = "재설정"
		L["Config - General - Reset - Button"] = "기본값으로 재설정"
		L["Config - General - Reset - Confirm"] = "모든 설정을 재설정 하시겠습니까?"
		L["Config - General - Reset - Confirm - Yes"] = "확인"
		L["Config - General - Reset - Confirm - No"] = "취소"
		L["Config - WaypointSystem"] = "위치 표시 구성"
		L["Config - WaypointSystem - Title"] = "위치 표시 구성"
		L["Config - WaypointSystem - Title - Subtext"] = "위치 정보의 표시 방식과 세부 항목(거리, 시간, 정보창 등)을 사용자 환경에 맞게 조정할 수 있습니다."
		L["Config - WaypointSystem - Type"] = "활성화"
		L["Config - WaypointSystem - Type - Both"] = "모두"
		L["Config - WaypointSystem - Type - Waypoint"] = "경로 표시 옵션"
		L["Config - WaypointSystem - Type - Pinpoint"] = "위치 정보창"
		L["Config - WaypointSystem - General"] = "일반"
		L["Config - WaypointSystem - General - RightClickToClear"] = "Right-Click To Clear"
		L["Config - WaypointSystem - General - RightClickToClear - Description"] = "Allows you to clear the Waypoint/Pinpoint/Navigator by right-clicking it."
		L["Config - WaypointSystem - General - Transition Distance"] = "위치 표시 거리 [최대]"
		L["Config - WaypointSystem - General - Transition Distance - Description"] = "위치가 화면에 표시되기까지의 최대 거리입니다.."
		L["Config - WaypointSystem - General - Hide Distance"] = "위치 표시 거리 [최소]"
		L["Config - WaypointSystem - General - Hide Distance - Description"] = "위치 표시가 사라지기 전의 최소 거리입니다."
		L["Config - WaypointSystem - Waypoint"] = "경로 표시 옵션"
		L["Config - WaypointSystem - Waypoint - Footer - Type"] = "경로 정보 표시 방식"
		L["Config - WaypointSystem - Waypoint - Footer - Type - Both"] = "모두"
		L["Config - WaypointSystem - Waypoint - Footer - Type - Distance"] = "거리"
		L["Config - WaypointSystem - Waypoint - Footer - Type - ETA"] = "도착 시간"
		L["Config - WaypointSystem - Waypoint - Footer - Type - None"] = "없음"
		L["Config - WaypointSystem - Pinpoint"] = "위치 정보창"
		L["Config - WaypointSystem - Pinpoint - Info"] = "정보 표시"
		L["Config - WaypointSystem - Pinpoint - Info - Extended"] = "정보 옵션 표시"
		L["Config - WaypointSystem - Pinpoint - Info - Extended - Description"] = "이름 / 설명 등의 추가 정보 포함."
		L["Config - WaypointSystem - Navigator"] = "길 안내 도구"
		L["Config - WaypointSystem - Navigator - Enable"] = "표시"
		L["Config - WaypointSystem - Navigator - Enable - Description"] = "지정한 위치가 화면 밖에 있을 땐, 길 안내 도구가 그 방향을 표시합니다.."
		L["Config - Appearance"] = "UI 디자인"
		L["Config - Appearance - Title"] = "UI 디자인"
		L["Config - Appearance - Title - Subtext"] = "색상, 정보창 크기와 투명도 등 UI의 시각 요소를 사용자 환경에 맞게 조정해 원하는 스타일로 구성할 수 있습니다."
		L["Config - Appearance - Waypoint"] = "위치 아이콘 관련 설정"
		L["Config - Appearance - Waypoint - Scale"] = "위치 아이콘 크기"
		L["Config - Appearance - Waypoint - Scale - Description"] = "위치 아이콘 크기는 거리에 따라 조정됩니다. 이 옵션은 전체 크기를 조정하는 데 사용됩니다."
		L["Config - Appearance - Waypoint - Scale - Min"] = "최소 표시 크기"
		L["Config - Appearance - Waypoint - Scale - Min - Description"] = "위치가 축소될 수 있는 최소 크기를 설정합니다."
		L["Config - Appearance - Waypoint - Scale - Max"] = "최대 표시 크기"
		L["Config - Appearance - Waypoint - Scale - Max - Description"] = "위치가 확대될 수 있는 최대 크기를 설정합니다."
		L["Config - Appearance - Waypoint - Beam"] = "광선 효과"
		L["Config - Appearance - Waypoint - Beam - Alpha"] = "투명도"
		L["Config - Appearance - Waypoint - Footer"] = "정보 글자 표시"
		L["Config - Appearance - Waypoint - Footer - Scale"] = "크기"
		L["Config - Appearance - Waypoint - Footer - Alpha"] = "거리 정보 투명도"
		L["Config - Appearance - Pinpoint"] = "위치 정보창"
		L["Config - Appearance - Pinpoint - Scale"] = "정보창 크기"
		L["Config - Appearance - Navigator"] = "길 안내 도구"
		L["Config - Appearance - Navigator - Scale"] = "크기"
		L["Config - Appearance - Navigator - Alpha"] = "투명도"
		L['Config - Appearance - Navigator - Distance'] = "Distance"
		L["Config - Appearance - Visual"] = "위치 아이콘 설정"
		L["Config - Appearance - Visual - UseCustomColor"] = "사용자 지정 색상"
		L["Config - Appearance - Visual - UseCustomColor - Color"] = "색상"
		L["Config - Appearance - Visual - UseCustomColor - TintIcon"] = "아이콘 색상 변경"
		L["Config - Appearance - Visual - UseCustomColor - Reset"] = "초기화"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Default"] = "일반 퀘스트 아이콘"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Repeatable"] = "반복 퀘스트 아이콘"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Important"] = "중요 퀘스트 아이콘"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Incomplete"] = "미완료 퀘스트 아이콘"
		L["Config - Appearance - Visual - UseCustomColor - Neutral"] = "일반 목표 지점 아이콘"
		L["Config - Audio"] = "오디오"
		L["Config - Audio - Title"] = "오디오"
		L["Config - Audio - Title - Subtext"] = "Waypoint UI에서 거리 도달, 클릭 등 주요 이벤트 발생 시 재생되는 오디오 효과를 전체적으로 활성화하거나 비활성화합니다."
		L["Config - Audio - General"] = "일반"
		L["Config - Audio - General - EnableGlobalAudio"] = "오디오 활성화"
		L["Config - Audio - Customize"] = "사용자 지정"
		L["Config - Audio - Customize - UseCustomAudio"] = "사용자 지정 오디오 사용"
		L["Config - Audio - Customize - UseCustomAudio - Sound ID"] = "사운드 ID"
		L["Config - Audio - Customize - UseCustomAudio - Sound ID - Placeholder"] = "사용자 지정 ID"
		L["Config - Audio - Customize - UseCustomAudio - Preview"] = "미리 듣기"
		L["Config - Audio - Customize - UseCustomAudio - Reset"] = "초기화"
		L["Config - Audio - Customize - UseCustomAudio - WaypointShow"] = "경로 표시 시 오디오 설정"
		L["Config - Audio - Customize - UseCustomAudio - PinpointShow"] = "목표 위치창 표시 시 오디오 설정"
		L["Config - About"] = "정보"
		L["Config - About - Contributors"] = "제작 참여자"
		L["Config - About - Developer"] = "개발자"
	end

	--------------------------------
	-- 제작 참여자
	--------------------------------

	do
		L["Contributors - ZamestoTV"] = "ZamestoTV"
		L["Contributors - ZamestoTV - Description"] = "번역가: 러시아어"
		L["Contributors - huchang47"] = "huchang47"
		L["Contributors - huchang47 - Description"] = "번역가: 중국어(간체)"
		L["Contributors - BlueNightSky"] = "BlueNightSky"
		L["Contributors - BlueNightSky - Description"] = "번역가: 중국어(번체)"
		L["Contributors - Crazyyoungs"] = "Crazyyoungs"
		L["Contributors - Crazyyoungs - Description"] = "번역가: 한국어"
		L["Contributors - Klep"] = "Klep"
		L["Contributors - Klep - Description"] = "번역가 - 프랑스어"
		L["Contributors - Kroffy"] = "Kroffy"
		L["Contributors - Kroffy - Description"] = "번역가 - 프랑스어"
		L["Contributors - cathtail"] = "cathtail"
		L["Contributors - cathtail - Description"] = "Translator - Brazilian Portuguese"
		L["Contributors - Larsj02"] = "Larsj02"
		L["Contributors - Larsj02 - Description"] = "번역가 — 독일어"
		L["Contributors - dabear78"] = "dabear78"
		L["Contributors - dabear78 - Description"] = "번역가 — 독일어"
		L["Contributors - y45853160"] = "y45853160"
		L["Contributors - y45853160 - Description"] = "코드: 베타 버그 수정"
		L["Contributors - lemieszek"] = "lemieszek"
		L["Contributors - lemieszek - Description"] = "코드: 베타 버그 수정"
		L["Contributors - BadBoyBarny"] = "BadBoyBarny"
		L["Contributors - BadBoyBarny - Description"] = "Code — Bug Fix"
		L["Contributors - SyverGiswold"] = "SyverGiswold"
		L["Contributors - SyverGiswold - Description"] = "Code - Feature"
	end
end

NS:Load()
