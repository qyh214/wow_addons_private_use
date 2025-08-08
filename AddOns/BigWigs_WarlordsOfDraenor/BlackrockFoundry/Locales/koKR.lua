local L = BigWigs:NewBossLocale("Gruul", "koKR")
if not L then return end
if L then
	L.first_ability = "내려치기 강타 또는 석화의 강타"
end

L = BigWigs:NewBossLocale("Oregorger", "koKR")
if L then
	L.roll_message = "구르기 %d - %d 광물!"
end

L = BigWigs:NewBossLocale("The Blast Furnace", "koKR")
if L then
	L.custom_on_shieldsdown_marker = "보호막 소멸 징표 표시"
	L.custom_on_shieldsdown_marker_desc = "취약해진 원시의 정령술사를 {rt8}로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

	L.custom_off_firecaller_marker = "불꽃소환사 징표 표시"
	L.custom_off_firecaller_marker_desc = "화염소환사를 {rt7}{rt6} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r\n|cFFADFF2F팁: 공격대에서 자신이 이 기능을 켰다면 빠르게 몹에 마우스 오버하는게 징표를 지정하는 가장 빠른 방법입니다.|r"

	L.heat_increased_message = "열기 증가! %s초마다 폭파"

	L.bombs_dropped = "폭탄 떨굼! (%d)"
	L.bombs_dropped_p2 = "기술자 죽음, 폭탄 떨굼!"

	L.operator = "풀무 조작기사 생성"
	L.operator_desc = "1단계 진행 중 방의 양 쪽에 1씩, 2의 풀무 조작기사가 반복해서 생성됩니다."

	L.engineer = "가열로 기술자 생성"
	L.engineer_desc = "1단계 진행 중 방의 양 쪽에 1씩, 2의 가열로 기술자가 반복해서 생성됩니다."

	L.guard = "보안 경비병 생성"
	L.guard_desc = "1단계 진행 중 방의 양 쪽에 1씩, 2의 보안 경비병이 반복해서 생성됩니다. 2단계 진행 중 방의 입구에 1의 보안 경비병이 반복해서 생성됩니다."

	L.firecaller = "불꽃소환사 생성"
	L.firecaller_desc = "2단계 진행 중 방의 양 쪽에 1씩, 2의 불꽃소환사가 반복해서 생성됩니다."
end

L = BigWigs:NewBossLocale("Flamebender Ka'graz", "koKR")
if L then
	L.molten_torrent_self = "당신에게 녹아내린 격류"
	L.molten_torrent_self_desc = "녹아내린 격류가 당신에게 걸렸을 때 특별한 초읽기를 합니다."
	L.molten_torrent_self_bar = "폭발합니다!"

	L.custom_off_wolves_marker = "잿불늑대 징표 표시"
	L.custom_off_wolves_marker_desc = "잿불늑대를 {rt3}{rt4}{rt5}{rt6} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."
end

L = BigWigs:NewBossLocale("Kromog", "koKR")
if L then
	L.custom_off_hands_marker = "휘감는 대지의 룬 방어 전담 징표 표시"
	L.custom_off_hands_marker_desc = "방어 전담 플레이어를 움켜쥔 휘감는 대지의 룬을 {rt7}{rt8} 징표로 표시합니다. 부공격대장 이상의 권한이 필요합니다."

	L.prox = "방어 전담 근접 표시"
	L.prox_desc = "바위 주먹 능력을 다른 방어 전담과 같이 맞을 수 있게 도와주는 15미터 근접 표시창을 엽니다."

	L.destroy_pillars = "기둥 파괴"
end

L = BigWigs:NewBossLocale("Beastlord Darmac", "koKR")
if L then
	L.next_mount = "곧 탑승!"

	L.custom_off_pinned_marker = "봉쇄 징표 표시"
	L.custom_off_pinned_marker_desc = "땅에 꽂힌 창을 {rt8}{rt7}{rt6}{rt5}{rt4}의 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r\n|cFFADFF2F팁: 공격대에서 자신이 이 기능을 켰다면 빠르게 몹에 마우스 오버하는게 징표를 지정하는 가장 빠른 방법입니다.|r"

	L.custom_off_conflag_marker = "거대한 불길 징표 표시"
	L.custom_off_conflag_marker_desc = "거대한 불길의 대상을 {rt1}{rt2}{rt3}의 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r"
end

L = BigWigs:NewBossLocale("Operator Thogar", "koKR")
if L then
	L.custom_on_firemender_marker = "그롬카르 화염치유사 징표 표시"
	L.custom_on_firemender_marker_desc = "그롬카르 화염치유사를 {rt7}의 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

	L.custom_on_manatarms_marker = "그롬카르 무장병 징표 표시"
	L.custom_on_manatarms_marker_desc = "그롬카르 무장병을 {rt8}의 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

	L.trains = "기차 경고"
	L.trains_desc = "각 선로마다 다음 기차가 언제 들어오는 지 타이머와 메시지를 표시합니다. 선로를 우두머리부터 입구까지 순서화됩니다, 예 우두머리 1 2 3 4 입구."

	L.lane = "%s 선로: %s"
	L.train = "기차"
	L.adds_train = "쫄 기차"
	L.big_add_train = "큰 쫄 기차"
	L.cannon_train = "대포 기차"
	L.deforester = "삼림방화포" -- /dump (C_EncounterJournal.GetSectionInfo(10329)).title
	L.random = "무작위 기차"

	L.train_you = "현재 선로에 기차! (%d)"
end

L = BigWigs:NewBossLocale("The Iron Maidens", "koKR")
if L then
	L.ship_trigger = "무쌍호 주 대포를 쏠 준비를 합니다!"

	L.ship = "배에 올라타기" -- XXX Check if 137266 is translated in wowNext

	L.custom_off_heartseeker_marker = "피에 젖은 심장추적자 징표 표시"
	L.custom_off_heartseeker_marker_desc = "피에 젖은 심장추적자의 대상을 {rt1}{rt2}{rt3}의 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

	L.power_message = "강철 분노 %d!"
end

L = BigWigs:NewBossLocale("Blackhand", "koKR")
if L then
	L.custom_off_markedfordeath_marker = "죽음의 표적 징표 표시"
	L.custom_off_markedfordeath_marker_desc = "죽음의 징표의 대상을 {rt1}{rt2}{rt3}의 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

	L.custom_off_massivesmash_marker = "거대 분쇄의 강타 표시"
	L.custom_off_massivesmash_marker_desc = "거대 분쇄의 강타 대상에게 {rt6}의 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."
end

L = BigWigs:NewBossLocale("Blackrock Foundry Trash", "koKR")
if L then
	L.guardian = "작업장 수호병"
	L.hauler = "오그론 운반자"
	L.beasttender = "천둥군주 야수치유사"
	L.brute = "잿가루 작업장 투사"
	L.gronnling = "그론링 노동자"
	L.gnasher = "어둠파편 갈갈이"
	L.enforcer = "검은바위 집행자"
	L.taskmaster = "강철 감독관"
	L.furnace = "열기 조절 장치"
	L.earthbinder = "강철 대지결속사"
	L.mistress = "제련여제 플레임핸드"

	L.furnace_msg1 = "흠, 누군가 해야하지 않겠어?"
	L.furnace_msg2 = "마시멜로우 타임!"
	L.furnace_msg3 = "이건 좋지 않은데..."
end
