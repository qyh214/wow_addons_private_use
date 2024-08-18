local L = BigWigs:NewBossLocale("Onyxia", "koKR")
if not L then return end
if L then
	L.phase1_trigger = "오늘은 운이 아주 좋군."
	L.phase2_trigger = "쓸데없이 힘을 쓰는 것도 지루하군. 네 녀석들 머리 위에서 모조리 불살라 주마!"
	L.phase3_trigger = "혼이 더 나야 정신을 차리겠구나!"

	L.deep_breath = "깊은 숨결"
end

L = BigWigs:NewBossLocale("Archavon the Stone Watcher", "koKR")
if L then
	L.stomp_message = "발 구르기 - 곧 돌진!"
	L.stomp_warning = "약 5초 후 발구르기 가능!"

	L.charge = "돌진"
	L.charge_desc = "돌진의 대상인 플레이어를 알립니다."
end

L = BigWigs:NewBossLocale("Emalon the Storm Watcher", "koKR")
if L then
	L.overcharge_message = "하수인 과충전!"
	L.overcharge_bar = "폭발"

	L.custom_on_overcharge_mark = "Overcharge marker"
	L.custom_on_overcharge_mark_desc = "Place the {rt8} marker on the overcharged minion, requires promoted or leader."
end

L = BigWigs:NewBossLocale("Koralon the Flame Watcher", "koKR")
if L then
	L.breath_bar = "숨결 %d"
	L.breath_message = "곧 %d 숨결!"
end

L = BigWigs:NewBossLocale("Toravon the Ice Watcher", "koKR")
if L then
	L.whiteout_bar = "시아상실 %d"
	L.whiteout_message = "곧 시아상실 %d !"

	L.freeze_message = "땅얼리기"
end

L = BigWigs:NewBossLocale("Malygos", "koKR")
if L then
	L.sparks = "불꽃 소환"
	L.sparks_desc = "마력의 불꽃 소환을 알립니다."
	L.sparks_message = "마력의 불꽃 소환!"
	L.sparks_warning = "약 5초 후 마력의 불꽃!"

	L.sparkbuff = "말리고스의 마력의 불꽃"
	L.sparkbuff_desc = "말리고스의 마력의 불꽃 획득을 알립니다."
	L.sparkbuff_message = "말리고스 마력의 불꽃 획득!"

	L.vortex = "회오리"
	L.vortex_desc = "1단계에서 회오리를 알립니다."
	L.vortex_message = "회오리!"
	L.vortex_warning = "약 5초 후 회오리 사용가능!"
	L.vortex_next = "회오리 대기시간"

	L.breath = "깊은 숨결"
	L.breath_desc = "2단계에서 말리고스가 사용하는 깊은 숨결을 알립니다."
	L.breath_message = "깊은 숨결!"
	L.breath_warning = "약 5초 후 깊은 숨결!"

	L.surge = "마력의 쇄도"
	L.surge_desc = "3단계에서 말리고스가 당신에게 마력의 쇄도를 사용시 알립니다."
	L.surge_you = "당신에게 마력의 쇄도!"
	L.surge_trigger = "%s|1이;가; 당신을 주시합니다!"

	L.phase = "단계"
	L.phase_desc = "단계 변화를 알립니다."
	L.phase2_warning = "잠시 후 2 단계!"
	L.phase2_trigger = "되도록 빨리 끝내 주고 싶었다만"
	L.phase2_message = "2 단계 - 마력의 군주 & 영원의 후예!"
	L.phase2_end_trigger = "그만! 아제로스의 마력을 되찾고"
	L.phase3_warning = "잠시 후 3 단계!"
	L.phase3_trigger = "네놈들의 후원자가 나타났구나"
	L.phase3_message = "3 단계!"
end

L = BigWigs:NewBossLocale("Sartharion", "koKR")
if L then
	L.engage_trigger = "내 임무는 알을 보호하는 것. 알에 손대지 못하게 모두 불태워 주마."
	L.tsunami_trigger = "%s|1을;를; 둘러싼 용암이 끓어오릅니다!"
	L.twilight_trigger_vesperon = "베스페론의 신도가 황혼에서 나타납니다!"
	L.twilight_trigger_shadron = "샤드론의 신도가 황혼에서 나타납니다!"

	L.drakes = "비룡 추가"
	L.drakes_desc = "각 비룡이 전투에 추가되는 것을 알립니다."

	-- Adds
	L.shadron = "샤드론"
	L.tenebron = "테네브론"
	L.vesperon = "베스페론"
	L.lava_blaze = "타오르는 용암" -- NPC 30643
	L.acolyte_shadron = "샤드론의 수행사제" -- NPC 31218
	L.acolyte_vesperon = "베스페론의 수행사제" -- NPC 31219
end
