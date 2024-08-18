local L = BigWigs:NewBossLocale("Imperial Vizier Zor'lok", "koKR")
if not L then return end
if L then
	L.engage_yell = "신성하신 분께서 당신의 신성한 뜻을 실현하라고 우리에게 목소리를 주셨다. 우리는 도구일 뿐이다."

	L.force = "{-6427} (광역 음파)"
	L.force_message = "광역 음파"

	L.attenuation = "{-6426} (고리)"
	L.attenuation_bar = "고리... 춤!"
	L.attenuation_message = "%s|1이;가; %s|1으로;로; 춤춥니다"
	L.echo = "|c001cc986메아리|r"
	L.zorlok = "|c00ed1ffa조르로크|r"
	L.left = "|c00008000<- 왼쪽 <-|r"
	L.right = "|c00FF0000-> 오른쪽 ->|r"

	L.platform_emote = "단상으로" -- 황실 장로 조르로크가 단상으로 날아갑니다!
	L.platform_emote_final = "들이마십니다"-- 황실 장로 조르로크가 열광의 페로몬을 들이마십니다!
	L.platform_message = "단상 이동"
end

L = BigWigs:NewBossLocale("Blade Lord Ta'yak", "koKR")
if L then
	L.engage_yell = "무기를 들어라. 나, 칼날군주 타마크가 상대해주마."

	L.unseenstrike_soon = "5-10초 후 일격 (%d)!"
	L.assault_message = "공격"
	L.side_swap = "복도 전환"

	L.custom_off_windstep = "바람 걷기 징표 표시"
	L.custom_off_windstep_desc = "치유 할당을 돕기 위해, 바람 걷기에 걸린 사람을 {rt1}{rt2}{rt3}{rt4}{rt5}{rt6} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."
end

L = BigWigs:NewBossLocale("Garalon", "koKR")
if L then
	L.phase2_trigger = "가랄론의 육중한 장갑이 갈라지면서 쪼개지기 시작합니다!"

	L.removed = "%s 사라짐!"
end

L = BigWigs:NewBossLocale("Wind Lord Mel'jarak", "koKR")
if L then
	L.spear_removed = "당신의 꿰뚫는 창이 제거되었습니다!"

	L.mending_desc = "|cFFFF0000경고: 모든 자르티크 전쟁치유사가 개별적인 치유 재사용 대기시간을 가지므로 당신의 '주시 대상'의 타이머만 표시합니다.|r {-6306}"
	L.mending_warning = "당신의 주시 대상 치유 시전 중!"
	L.mending_bar = "주시 대상: 치유"
end

L = BigWigs:NewBossLocale("Amber-Shaper Un'sok", "koKR")
if L then
	L.explosion_by_other = "괴수/주시 대상의 호박석 폭발 재사용 대기시간 바"
	L.explosion_by_other_desc = "호박석 괴수나 당신의 주시 대상이 시전한 호박석 폭발의 재사용 대기시간 경고와 바입니다."

	L.explosion_casting_by_other = "괴수/주시 대상의 호박석 폭발 시전 바"
	L.explosion_casting_by_other_desc = "호박석 괴수나 당신의 주시 대상이 시작한 호박석 폭발의 시전 경고와 바입니다. 이 경고를 강조하길 권장합니다!"

	L.explosion_by_you = "당신의 호박석 폭발 재사용 대기시간"
	L.explosion_by_you_desc = "자신의 호박석 폭발의 재사용 대기시간을 경고합니다."
	L.explosion_by_you_bar = "당신 시전 시작..."

	L.explosion_casting_by_you = "당신의 호박석 폭발 시전 바"
	L.explosion_casting_by_you_desc = "자신이 시작한 호박석 폭발 시전을 경고합니다. 이 경고를 강조하길 권장합니다!"

	L.willpower = "의지력"
	L.willpower_message = "의지력: %d!"

	L.break_free_message = "생명력: %d%%!"
	L.fling_message = "내던지기!"
	L.parasite = "기생충"

	L.monstrosity_is_casting = "괴수: 폭발"
	L.you_are_casting = "당신 시전 중!"

	L.unsok_short = "우두머리"
	L.monstrosity_short = "괴수"
end

L = BigWigs:NewBossLocale("Grand Empress Shek'zeer", "koKR")
if L then
	L.engage_trigger = "내 제국에 맞서는 모든 이들에게 죽음을!"

	L.phases = "단계"
	L.phases_desc = "단계 전환을 경고합니다."

	L.eyes = "여제의 눈"
	L.eyes_desc = "여제의 눈의 중첩을 세고 지속시간 바를 표시합니다."
	L.eyes_message = "눈"

	L.visions_message = "환영"
	L.visions_dispel = "플레이어 겁에 질림!"
	L.fumes_bar = "당신의 증기 강화 효과"
end
