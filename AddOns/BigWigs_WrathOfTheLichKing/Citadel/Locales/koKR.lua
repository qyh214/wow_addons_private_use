local L = BigWigs:NewBossLocale("Lord Marrowgar", "koKR")
if not L then return end
if L then
	L.bone_spike = "뼈 가시" -- NPC ID 36619
end

L = BigWigs:NewBossLocale("Lady Deathwhisper", "koKR")
if L then
	L.touch = "손길"
	L.deformed_fanatic = "변형된 광신자" -- NPC ID 38135
	L.empowered_adherent = "강화된 신봉자" -- NPC ID 38136
end

L = BigWigs:NewBossLocale("Icecrown Gunship Battle", "koKR")
if L then
	L.adds_trigger_alliance = "약탈자, 하사관, 공격하라!"
	L.adds_trigger_horde = "해병, 하사관, 공격하라!"

	L.mage = "마법사"
	L.mage_desc = "마법사 소환과 대포가 얼었을때 알립니다."
	-- Alliance: We're taking hull damage, get a battle-mage out here to shut down those cannons!
	-- Horde: We're taking hull damage, get a sorcerer out here to shut down those cannons!
	--L.mage_yell_trigger = "taking hull damage"

	L.warmup_trigger_alliance = "속도를 올려라"
	L.warmup_trigger_horde = "호드의 아들딸이여"

	L.disable_trigger_alliance = "형제자매여, 전진"
	L.disable_trigger_horde = "리치 왕을 향해 전진하라"
end

L = BigWigs:NewBossLocale("Deathbringer Saurfang", "koKR")
if L then
	L.blood_beast = "피의 괴물" --  NPC ID 38508

	L.warmup_alliance = "그러면 이동하자! 이동..."
	L.warmup_horde = "코르크론, 출발하라! 용사들이여, 뒤를 조심하게. 스컬지는..."
end

L = BigWigs:NewBossLocale("Blood Prince Council", "koKR")
if L then
	L.switch_message = "대상 변경: %s"
	L.switch_bar = "~다음 대상 변경"

	L.empowered_flames = "강력한 불꽃"

	L.empowered_shock_message = "충격의 소용돌이 시전!"
	L.regular_shock_message = "충격 지역"
	L.shock_bar = "~다음 충격"

	L.iconprince = "활성화된 왕자 해골"
	L.iconprince_desc = "활성화된 왕자에게 해골 징표를 표시합니다 (승급된 사람만 가능)."

	L.prison_message = "어둠의 감옥 x%d!"
end

L = BigWigs:NewBossLocale("Festergut", "koKR")
if L then
	L.engage_trigger = "노는... 거야?"

	L.inhale_bar = "들이마시기 %d"
	L.blight_warning = "약 5초 후 파멸의 역병!"
	L.ball_message = "탱탱볼!"
end

L = BigWigs:NewBossLocale("Professor Putricide", "koKR")
if L then
	L.engage_trigger = "좋은 소식이에요, 여러분!"

	L.phase = "단계"
	L.phase_desc = "단계 변화를 알립니다."
	L.phase_warning = "곧 %d 단계!"
	L.phase_bar = "다음 단계"

	L.ball_bar = "다음 끈적이"
	L.ball_say = "곧 통통 끈적이!"

	L.experiment_message = "곧 수액 추가!"
	L.experiment_heroic_message = "수액들 추가!"
	L.experiment_bar = "다음 수액 추가"
	L.blight_message = "붉은 수액"
	L.violation_message = "녹색 수액"

	L.gasbomb_bar = "다음 노란 가스탄"
	L.gasbomb_message = "숨막히는 가스탄!"
end

L = BigWigs:NewBossLocale("Rotface", "koKR")
if L then
	L.engage_trigger = "우와아아아아아!"

	L.infection_message = "돌연변이 전염병"

	L.ooze = "불안정한 수액괴물"
	L.ooze_desc = "불안정한 수액괴물을 알립니다."
	L.ooze_message = "불안정한 수액괴물 %dx"

	L.spray_bar = "다음 독액 뿌리기"
end

L = BigWigs:NewBossLocale("Sindragosa", "koKR")
if L then
	L.engage_trigger = "여기까지 오다니 너무나 어리석구나. 노스렌드의 얼음 바람이 영혼까지 삼키리라!"

	L.phase2 = "2 단계"
	L.phase2_desc = "2 단계 변화를 알립니다."
	L.phase2_trigger = "자, 주인님의 무한한 힘을 느끼고 절망에 빠져보아라!"
	L.phase2_message = "2 단계!"

	L.airphase = "비행 단계"
	L.airphase_desc = "신드라고사의 착지 & 비행에 대한 단계를 알립니다."
	L.airphase_trigger = "여기가 끝이다! 아무도 살아남지 못하리라!"
	L.airphase_message = "비행 단계!"
	L.airphase_bar = "비행 단계"

	L.boom_message = "폭발!"
	L.boom_bar = "폭발"

	L.instability_message = "불안정 x%d!"
	L.chilled_message = "사무치는 한기 x%d!"
	L.buffet_message = "신비한 강타 x%d!"
	L.buffet_cd = "다음 신비한 강타"
end

L = BigWigs:NewBossLocale("Valithria Dreamwalker", "koKR")
if L then
	L.engage_trigger = "영웅들이여, 나를 도와다오. 더는... 더는 저들을 붙들어 둘 수 없다. 이 상처를 치유해다오!"

	L.portal = "악몽의 차원문"
	L.portal_desc = "악몽의 차원문을 알립니다."
	L.portal_message = "차원문 생성!"
	L.portal_bar = "차원문 생성"
	L.portalcd_message = "14초 후 차원문 %d 생성!"
	L.portalcd_bar = "다음 차원문 %d"
	L.portal_trigger = "에메랄드의 꿈으로 가는 차원문을 열어두었다. 너희의 구원은 그 안에 있다..."

	L.suppresser = "억제자 소환"
	L.suppresser_desc = "억제자 소환을 알립니다."
	L.suppresser_message = "~억제자"

	L.blazing = "타오르는 해골"
	L.blazing_desc = "타오르는 해골의 |cffff0000추정|r되는 재생성 타이머 입니다. 이 타이머는 도적에게만 효용있게 만들어져 있습니다."
	L.blazing_warning = "곧 타오르는 해골!"
end

L = BigWigs:NewBossLocale("Blood-Queen Lana'thel", "koKR")
if L then
	L.engage_trigger = "정말... 현명하지 못한... 결정을 했군."

	L.shadow = "어둠이 쌓이더니"
	L.shadow_message = "모여드는 어둠"
	L.shadow_bar = "다음 어둠"

	L.feed_message = "피의 갈증"

	L.pact_message = "암흑사도의 계약"
	L.pact_bar = "다음 계약"

	L.phase_message = "곧 공중 단계!"
	L.phase1_bar = "착지"
	L.phase2_bar = "공중 단계"
end

L = BigWigs:NewBossLocale("The Lich King", "koKR")
if L then
	L.warmup_trigger = "그러니까 성스러운 빛이 자랑하던 정의가 마침내 왔다 이건가?"
	L.engage_trigger = "폴드링, 너는 살려서 최후를 지켜보게 하겠다."

	L.horror_message = "휘청거리는 괴물"
	L.horror_bar = "~다음 휘청 괴물"

	L.valkyr_message = "발키르"
	L.valkyr_bar = "다음 발키르"
	L.valkyrhug_message = "발키르 붙음"

	L.cave_phase = "동굴 단계"
	L.last_phase_bar = "마지막 단계"

	L.frenzy_bar = "%s 광기!"
	L.frenzy_survive_message = "%s 역병 후 살아남음"
	L.frenzy_message = "격노 추가!"
	L.frenzy_soon_message = "5초 후 격노!"

	--L.custom_on_valkyr_marker = "Val'kyr marker"
	--L.custom_on_valkyr_marker_desc = "Mark the Val'kyr with {rt8}{rt7}{rt6}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r\n|cFFADFF2FTIP: If the raid has chosen you to turn this on, quickly mousing over the Val'kyr is the fastest way to mark them.|r"
end

L = BigWigs:NewBossLocale("Icecrown Citadel Trash", "koKR")
if L then
	L.deathbound_ward = "죽음에 속박된 감시자"
	L.deathspeaker_high_priest = "죽음예언자 대사제" -- NPC ID 36829
	L.putricide_dogs = "예삐 & 구리구리"
end
