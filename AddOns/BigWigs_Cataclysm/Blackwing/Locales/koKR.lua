
local L = BigWigs:NewBossLocale("Magmaw", "koKR")
if not L then return end
if L then
	L.stage2_yell_trigger = "이러다간 내 용암" -- 이런 곤란할 데가! 이러다간 내 용암 벌레가 정말 질 수도 있겠군! 그럼... 내가 상황을 좀 바꿔 볼까?

	L.slump = "슬럼프"
	L.slump_desc = "슬럼프 상태를 알립니다."
	L.slump_bar = "로데오"
	L.slump_message = "올라타세요~!"
end

L = BigWigs:NewBossLocale("Omnotron Defense System", "koKR")
if L then
	L.nef = "군주 빅터 네파리우스"
	L.nef_desc = "군주 빅터 네파리우스의 기술을 알립니다."

	L.pool_explosion = "바닥 웅덩이 폭발"
	L.incinerate = "소각"
	L.flamethrower = "화염방사기"
	L.lightning = "번개"
	L.infusion = "주입"
end

L = BigWigs:NewBossLocale("Atramedes", "koKR")
if L then
	L.obnoxious_fiend = "불쾌한 마귀" -- NPC ID 49740
	--L.circles = "Circles"
end

L = BigWigs:NewBossLocale("Maloriak", "koKR")
if L then
	L.flames = "불꽃"
end

L = BigWigs:NewBossLocale("Nefarian", "koKR")
if L then
	L.discharge = "번개 방출"
	L.stage3_yell_trigger = "버리겠어" -- 품위 있는 집주인답게 행동하려 했건만, 네놈들이 도무지 죽질 않는군! 겉치레는 이제 집어치우자고. 그냥 모두 없애 버리겠어!
	--L.too_close = "Dragons are too close"
end
