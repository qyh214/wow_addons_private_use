local L = BigWigs:NewBossLocale("ArchimondeHyjal", "koKR")
if not L then return end
if L then
	L.engage_trigger = "아무리 저항해도 소용없다!"
	L.grip_other = "손아귀"
	L.fear_message = "공포, 다음은 약 ~42초 이내!"

	L.killable = "Becomes Killable"
end

L = BigWigs:NewBossLocale("Azgalor", "koKR")
if L then
	L. howl_bar = "~침묵 대기시간"
	L. howl_message = "광역 침묵"
end

L = BigWigs:NewBossLocale("Kaz'rogal", "koKR")
if L then
	L.mark_bar = "다음 징표 (%d)"
	L.mark_warn = "5초 이내 징표!"
end

L = BigWigs:NewBossLocale("Hyjal Summit Trash", "koKR")
if L then
	L.waves = "공격 경고"
	L.waves_desc = "다음 공격에 대한 접근 경고 메세지를 알립니다."

	L.ghoul = "구울"
	L.fiend = "지하마귀"
	L.abom = "누더기골렘"
	L.necro = "어둠의 강령술사"
	L.banshee = "밴시"
	L.garg = "가고일"
	L.wyrm = "서리고룡"
	L.fel = "지옥사냥개"
	L.infernal = "거대한 지옥불정령"
	L.one = "%d번째 공격! %d %s"
	L.two = "%d번째 공격! %d %s, %d %s"
	L.three = "%d번째 공격! %d %s, %d %s, %d %s"
	L.four = "%d번째 공격! %d %s, %d %s, %d %s, %d %s"
	L.five = "%d번째 공격! %d %s, %d %s, %d %s, %d %s, %d %s"
	L.barWave = "%d번째 공격 등장"

	L.waveInc = "%d번째 공격 시작!"
	L.message = "%s 약 %d초 이내!"
	L.waveMessage = "%d번째 공격! 약 %d초 이내"
end
