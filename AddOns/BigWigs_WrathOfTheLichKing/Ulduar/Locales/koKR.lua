local L = BigWigs:NewBossLocale("Auriaya", "koKR")
if not L then return end
if L then
	L.swarm_message = "수호자의 무리"

	L.defender = "수호 야수"
	L.defender_desc = "수호 야수의 남은 생명 횟수를 알립니다."
	L.defender_message = "수호 야수 (생명: %d/9)!"
end

L = BigWigs:NewBossLocale("Freya", "koKR")
if L then
	L.wave = "웨이브"
	L.wave_desc = "웨이브에 대해 알립니다."
	L.wave_bar = "다음 웨이브"
	L.conservator_trigger = "이오나여, 당신의 종이 도움을 청합니다!"
	L.detonate_trigger = "정령의 무리가 너희를 덮치리라!"
	L.elementals_trigger = "얘들아, 날 도와라!"
	L.tree_trigger = "|cFF00FFFF생명의 어머니의 선물|r이 자라기 시작합니다!"
	L.conservator_message = "수호자 소환"
	L.detonate_message = "폭발 덩굴손 소환"
	L.elementals_message = "정령 3 소환"

	L.tree = "이오나의 선물"
	L.tree_desc = "프레이야의 이오나의 선물 소환을 알립니다."
	L.tree_message = "이오나의 선물 소환"

	L.fury_message = "격노"

	L.tremor_warning = "곧 지진!"
	L.tremor_bar = "~다음 지진"
	L.energy_message = "당신은 불안정한 힘!"
	L.sunbeam_message = "태양 광선!"
	L.sunbeam_bar = "~다음 태양 광선"
end

L = BigWigs:NewBossLocale("Hodir", "koKR")
if L then
	L.hardmode = "도전 모드 시간"
	L.hardmode_desc = "도전 모드의 시간을 표시합니다."
end

L = BigWigs:NewBossLocale("Ignis the Furnace Master", "koKR")
if L then
	L.brittle_message = "피조물 부서지는 몸!"
end

L = BigWigs:NewBossLocale("The Iron Council", "koKR")
if L then
	L.stormcaller_brundir = "폭풍소환사 브룬디르"
	L.steelbreaker = "강철파괴자"
	L.runemaster_molgeim = "룬술사 몰가임"

	L.summoning_message = "소환의 룬 - 곧 정령 등장!"

	L.chased_other = "%s 추적 중!"
	L.chased_you = "당신을 추적 중!"
end

L = BigWigs:NewBossLocale("Kologarn", "koKR")
if L then
	L.arm = "팔 죽음"
	L.arm_desc = "왼팔 & 오른팔의 죽음을 알립니다."
	L.left_dies = "왼팔 죽음"
	L.right_dies = "오른팔 죽음"
	L.left_wipe_bar = "왼팔 재생성"
	L.right_wipe_bar = "오른팔 재생성"

	L.eyebeam = "안광 집중"
	L.eyebeam_desc = "안광 집중의 대상이된 플레이어를 알립니다."
end

L = BigWigs:NewBossLocale("Mimiron", "koKR")
if L then
	L.phase = "단계"
	L.phase_desc = "단계 변화를 알립니다."
	L.engage_warning = "1 단계"
	L.engage_trigger = "^시간이 없어, 친구들!"
	L.phase2_warning = "곧 2 단계"
	L.phase2_trigger = "^멋지군!"
	L.phase3_warning = "곧 3 단계"
	L.phase3_trigger = "^고맙다, 친구들!"
	L.phase4_warning = "곧 4 단계"
	L.phase4_trigger = "^예비 시험은 이걸로 끝이다"
	L.phase_bar = "%d 단계"

	L.hardmode_trigger = "^아니, 대체 왜 그런 짓을 한 게지?"

	L.plasma_warning = "플라스마 폭발 시전!"
	L.plasma_soon = "곧 플라스마!"
	L.plasma_bar = "다음 플라스마"

	L.shock_next = "다음 충격파"

	L.laser_soon = "회전 가속!"
	L.laser_bar = "레이저 탄막"

	L.magnetic_message = "공중 지휘기! 극딜!"

	L.suppressant_warning = "곧 화염 억제!"

	L.fbomb_bar = "다음 서리 폭탄"

	L.bomb_message = "폭발로봇 소환!"
end

L = BigWigs:NewBossLocale("Razorscale", "koKR")
if L then
	L.ground_trigger = "움직이세요! 오래 붙잡아둘 순 없을 겁니다!"
	L.ground_message = "칼날비늘 묶임!"
	L.air_message = "이륙!"

	L.harpoon = "작살 포탑"
	L.harpoon_desc = "작살 포탑의 준비를 알립니다."
	L.harpoon_message = "작살 포탑 (%d)"
	L.harpoon_trigger = "작살 포탑이 준비되었습니다!"
	L.harpoon_nextbar = "다음 작살 (%d)"
end

L = BigWigs:NewBossLocale("Thorim", "koKR")
if L then
	L.phase2_trigger = "침입자라니! 감히 내 취미 생활을 방해하는 놈들은 쓴맛을 단단히... 잠깐... 너는..."
	L.phase3_trigger = "건방진 젖먹이 같으니... 감히 여기까지 기어올라와 내게 도전해? 내 손으로 쓸어버리겠다!"

	L.hardmode = "도전 모드 시간"
	L.hardmode_desc = "도전 모드의 시간을 표시합니다."
	L.hardmode_warning = "도전 모드 종료"

	L.barrier_message = "거인 - 룬문자 방벽!"

	L.charge_message = "충전 (%d)!"
	L.charge_bar = "충전 (%d)"
end

L = BigWigs:NewBossLocale("General Vezax", "koKR")
if L then
	L.surge_bar = "쇄도 %d"

	L.animus = "사로나이트 원혼"
	L.animus_desc = "사로나이트 원혼 소환을 알립니다."
	L.animus_trigger = "사로나이트 증기가 한 덩어리가 되어 맹렬하게 소용돌이치며, 무시무시한 형상으로 변화합니다!"
	L.animus_message = "원혼 소환!"

	L.vapor = "사로나이트 증기"
	L.vapor_desc = "사로나이트 증기 소환을 알립니다."
	L.vapor_message = "사로나이트 증기 (%d)!"
	L.vapor_bar = "다음 증기"
	L.vapor_trigger = "가까운 사로나이트 증기 구름이 합쳐집니다!"

	L.vaporstack = "증기 중첩"
	L.vaporstack_desc = "사로나이트 증기 5중첩이상을 알립니다."
	L.vaporstack_message = "증기 x%d 중첩!"

	L.crash_say = "어둠 붕괴요"

	L.mark_message = "징표"
end

L = BigWigs:NewBossLocale("XT-002 Deconstructor", "koKR")
if L then
	L.lightbomb_other = "타오르는 빛"
end

L = BigWigs:NewBossLocale("Yogg-Saron", "koKR")
if L then
	L.engage_trigger = "^짐승의 대장을 칠 때가 곧 다가올 거예요"
	L.phase2_trigger = "^나는, 살아 있는 꿈이다"
	L.phase3_trigger = "^죽음의 진정한 얼굴을 보아라"

	L.portal = "차원문"
	L.portal_desc = "차원문을 알립니다."
	L.portal_message = "차원문 열림!"
	L.portal_bar = "다음 차원문"

	L.fervor_message = "사라의 열정: %s!"

	L.sanity_message = "당신의 이성 위험!"

	L.weakened = "기절"
	L.weakened_desc = "기절 상태를 알립니다."
	L.weakened_message = "%s 기절!"

	L.madness_warning = "10초 후 광기 유발!"

	L.malady_message = "병든 정신" -- short for Malady of the Mind (63830)

	L.tentacle = "촉수 소환"
	L.tentacle_desc = "촉수 소환을 알립니다."
	L.tentacle_message = "분쇄의 촉수(%d)"

	--L.small_tentacles = "Small Tentacles"
	--L.small_tentacles_desc = "Warn for Corruptor Tentacle and Constrictor Tentacle spawns."

	L.link_warning = "당신은 두뇌의 고리!"

	L.guardian_message = "수호자 소환 %d!"

	L.roar_warning = "5초 후 포효!"
	L.roar_bar = "다음 포효"
end
