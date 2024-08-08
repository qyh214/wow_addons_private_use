
local L = BigWigs:NewBossLocale("Magmaw", "koKR")
if not L then return end
if L then
	L.stage2_yell_trigger = "이런 곤란한 데가! 이러다간 내 용암"

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
	L.air_phase_trigger = "그래, 도망가라! 발을 디딜 때마다 맥박은 빨라지지. 점점 더 크게 울리는구나... 귀청이 터질 것만 같군! 넌 달아날 수 없다!"
	--L.circles = "Circles"
end

L = BigWigs:NewBossLocale("Maloriak", "koKR")
if L then
	L.flames = "불꽃"
end

L = BigWigs:NewBossLocale("Nefarian", "koKR")
if L then
	L.discharge = "번개 방출"
	L.stage3_yell_trigger = "품위있는"
	--L.too_close = "Dragons are too close"
end
