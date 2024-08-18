local L = BigWigs:NewBossLocale("The Fallen Protectors", "koKR")
if not L then return end
if L then
  L.defile_you = "더럽혀진 땅 - 피하세요"
  L.defile_you_desc = "더렵혀진 땅이 자신의 발 밑에 있을 경우 경고해줍니다."

  L.no_meditative_field = "명상의 장으로 들어가세요!"

  L.intermission_desc = "우두머리가 언제 궁책을 사용하는 지 경고합니다."

  L.inferno_self = "당신에게 지옥불 일격"
  L.inferno_self_desc = "자신이 지옥불 일격에 걸렸을 때 특수 초읽기를 합니다."
  L.inferno_self_bar = "당신 폭발!"

  L.custom_off_bane_marks = "어둠의 권능: 파멸 징표 표시"
  L.custom_off_bane_marks_desc = "해제 할당을 돕기 위해, 첫 어둠의 권능: 파멸에 걸린 사람을 {rt1}{rt2}{rt3}{rt4}{rt5} 징표로 표시합니다 (징표가 순서대로 사용되지 않습니다), 부공격대장 이상의 권한이 필요합니다."
end

L = BigWigs:NewBossLocale("Norushen", "koKR")
if L then
  L.warmup_trigger = "그래, 좋다. 너희 타락을 가두어 둘 공간을 만들겠다."

  L.big_adds = "큰 추가 몹"
  L.big_adds_desc = "큰 추가 몹의 생성과 처치에 대해 경고합니다."
  L.big_add = "큰 추가 몹 (%d)"
  L.big_add_killed = "큰 추가 몹 처치 (%d)"
end

L = BigWigs:NewBossLocale("Sha of Pride", "koKR")
if L then
  L.projection_green_arrow = "녹색 화살표"

  L.titan_pride = "티탄+교만: %s"

  L.custom_off_titan_mark = "티탄의 선물 징표 표시"
  L.custom_off_titan_mark_desc = "티탄의 선물에 걸린 사람을 {rt1}{rt2}{rt3}{rt4}{rt5}{rt6} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r"

  L.custom_off_fragment_mark = "타락한 조각 징표 표시"
  L.custom_off_fragment_mark_desc = "타락한 조각을 {rt8}{rt7} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r"
end

L = BigWigs:NewBossLocale("Galakras", "koKR")
if L then
  L.start_trigger_alliance = "잘했다! 상륙 부대, 정렬! 보병대, 앞으로!"
  L.start_trigger_horde = "잘 했소. 선봉대가 성공적으로 착륙했군."

  L.demolisher_message = "파괴전차"

  L.towers = "탑"
  L.towers_desc = "탑이 파손되면 경고합니다."
  L.south_tower_trigger = "남쪽 탑으로 통하는 문이 뚫렸습니다!"
  L.south_tower = "남쪽 탑"
  L.north_tower_trigger = "북쪽 탑으로 통하는 문이 뚫렸습니다!"
  L.north_tower = "북쪽 탑"
  L.tower_defender = "탑 수호자"

  L.adds_desc = "추가 몹 병력이 전투에 언제 참여하는지 보여주는 타이머입니다."
  L.warlord_zaela = "전쟁군주 잴라"

  L.drakes = "원시비룡"

  L.custom_off_shaman_marker = "주술사 징표 표시"
  L.custom_off_shaman_marker_desc = "시전 방해 할당을 돕기 위해, 용아귀 파도주술사를 {rt8} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r\n|cFFADFF2F팁: 공격대에서 자신이 이 기능을 켰다면 빠르게 몹에 마우스 오버하는게 징표를 지정하는 가장 빠른 방법입니다.|r"
end

L = BigWigs:NewBossLocale("Iron Juggernaut", "koKR")
if L then
  L.custom_off_mine_marks = "지뢰 징표 표시"
  L.custom_off_mine_marks_desc = "임무 할당을 돕기 위해, 거미 지뢰를 {rt1}{rt2}{rt3} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r\n|cFFADFF2F팁: 공격대에서 자신이 이 기능을 켰다면 빠르게 몹에 마우스 오버하는게 징표를 지정하는 가장 빠른 방법입니다.|r"
end

L = BigWigs:NewBossLocale("Kor'kron Dark Shaman", "koKR")
if L then
  L.blobs = "오염된 점액"

  L.custom_off_mist_marks = "독성 안개 징표 표시"
  L.custom_off_mist_marks_desc = "치유 할당을 돕기 위해, 독성 안개에 걸린 사람을 {rt1}{rt2}{rt3}{rt4}{rt5} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다|r"
end

L = BigWigs:NewBossLocale("General Nazgrim", "koKR")
if L then
  L.custom_off_bonecracker_marks = "뼈으깨기 징표 표시"
  L.custom_off_bonecracker_marks_desc = "치유 할당을 돕기 위해, 뼈으깨기에 걸린 사람을 {rt1}{rt2}{rt3}{rt4}{rt5} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r"

  L.stance_bar = "%s(현재:%s)"
  -- shorten stances so they fit on the bars
  L.battle = "전투"
  L.berserker = "광폭"
  L.defensive = "방어"

  L.adds_trigger1 = "놈들을 막아라!"
  L.adds_trigger2 = "병력 집결!"
  L.adds_trigger3 = "다음 분대, 앞으로!"
  L.adds_trigger4 = "전사들이여! 이리로!"
  L.adds_trigger5 = "코르크론! 날 지원하라!"
  L.adds_trigger_extra_wave = "전 코르크론, 내 명령을 따르라. 모두 죽여!"
  L.extra_adds = "추가 병력"
  L.final_wave = "마지막 병력 추가"
  L.add_wave = "%s (%s): %s"

  L.chain_heal_message = "당신의 주시 대상이 연쇄 치유를 시전 중입니다!"

  L.arcane_shock_message = "당신의 주시 대상이 비전 충격을 시전 중입니다!"
end

L = BigWigs:NewBossLocale("Malkorok", "koKR")
if L then
  L.custom_off_energy_marks = "어긋난 힘 징표 표시"
  L.custom_off_energy_marks_desc = "해제 할당을 돕기 위해, 어긋난 힘을 가진 사람을 {rt1}{rt2}{rt3}{rt4} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다|r"
end

L = BigWigs:NewBossLocale("Spoils of Pandaria", "koKR")
if L then
  L.enable_zone = "유물 보관실"
  L.start_trigger = "녹음되고 있는 건가?"
  L.win_trigger = "시스템 초기화 중. 전원을 끄면 폭발할 수 있으니 주의하라고."

  L.crates = "상자"
  L.crates_desc = "필요한 동력의 양과 거대/튼튼/가벼운 상자의 남은 갯수에 대한 메시지를 표시합니다."

  L.full_power = "최대 동력!"
  L.power_left = "%d 남음! (%d/%d/%d)"
end

L = BigWigs:NewBossLocale("Thok the Bloodthirsty", "koKR")
if L then
  L.adds_desc = "설인 또는 박쥐가 언제 전투에 참여하는 지 경고합니다."

  L.cage_opened = "감옥 열림"

  L.npc_akolik = "아콜릭"
  L.npc_waterspeaker_gorai = "물예언자 고라이"
end

L = BigWigs:NewBossLocale("Siegecrafter Blackfuse", "koKR")
if L then
  L.overcharged_crawler_mine = "과충전된 거미 지뢰" -- sadly this is needed since they have same mobId

  L.disabled = "파괴됨"

  L.shredder_engage_trigger = "자동 분쇄기가 다가옵니다!"
  L.laser_on_you = "레이저가 당신에게 꽂힙니다!"

  L.assembly_line_trigger = "생산 설비에서 미완성 무기가 나오기 시작합니다."
  L.assembly_line_message = "미완성 무기 (%d)"
  L.assembly_line_items = "무기 (%d): %s"
  L.item_missile = "미사일"
  L.item_mines = "지뢰"
  L.item_laser = "레이저"
  L.item_magnet = "전자석"
  L.item_deathdealer = "죽음의 선고자"

  L.shockwave_missile_trigger = "내 이쁜이 ST-03 충격파 미사일 포탑을 소개하지!"

  L.custom_off_mine_marker = "지뢰 징표 표시"
  L.custom_off_mine_marker_desc = "특정 기절 할당을 위해 지뢰에 징표를 표시합니다. (모든 징표가 사용됩니다)"
end

L = BigWigs:NewBossLocale("Paragons of the Klaxxi", "koKR")
if L then
  L.catalyst_match = "촉매: |c%s당신과 일치|r" -- might not be best for colorblind?
  L.you_ate = "기생충을 먹었습니다 (%d 남음)"
  L.other_ate = "%s|1이;가; %s기생충을 먹었습니다 (%d 남음)"
  L.parasites_up = "%d 기생충 남음"
  L.dance = "%s, 피하세요!"
  L.prey_message = "기생충에 희생물을 사용하세요"
  L.injection_over_soon = "곧 주입 종료 (%s)!"

  -- for getting all those calculate emotes:
  -- cat Transcriptor.lua | sed "s/\t//g" | grep -E "(CHAT_MSG_RAID_BOSS_EMOTE].*Iyyokuk)" | sed "s/.*EMOTE//" | sed "s/#/\"/" | sed "s/#.*/\"/" | sort | uniq
  L.one = "이요쿠크가 1"
  L.two = "이요쿠크가 2"
  L.three = "이요쿠크가 3"
  L.four = "이요쿠크가 4"
  L.five = "이요쿠크가 5"
  --------------------------------

  -- XXX these marks are not enough
  L.custom_off_edge_marks = "경계 징표 표시"
  L.custom_off_edge_marks_desc = "계산에 기반하여 경계가 될 플레이어를 {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}{rt8} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r"
  L.edge_message = "당신은 경계입니다!"

  L.custom_off_parasite_marks = "기생충 징표 표시"
  L.custom_off_parasite_marks_desc = "군중 제어와 희생물 할당을 위해 기생충을 {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r"

  L.injection_tank = "주입 시전"
  L.injection_tank_desc = "현재 방어 전담에게 주입을 언제 시전할 지 보여주는 타이머 바입니다."
end

L = BigWigs:NewBossLocale("Garrosh Hellscream", "koKR")
if L then
  L.manifest_rage = "명백한 분노"
  L.manifest_rage_desc = "가로쉬의 에너지가 100이 되면 명백한 분노를 2초 간 시전하고, 그 후 정신 집중합니다. 정신 집중하는 동안 큰 추가 몹을 소환합니다. 강철의 별을 가로쉬에게 유도하여 기절시키고 그의 시전을 방해하세요."

  L.phase_3_end_trigger = "네가 이겼다고 생각하나?"

  L.clump_check_desc = "폭격 중 매 3초마다 플레이어들이 뭉쳐있는 지 확인합니다, 뭉쳐있는 게 발견되면 코르크론 강철의 별이 생성됩니다."
  L.clump_check_warning = "뭉침 발견: 별 오는 중!"

  L.bombardment = "폭격"
  L.bombardment_desc = "스톰윈드를 폭격하고, 지면에 불길의 흔적을 남깁니다. 코르크론 강철의 별은 폭격 중에만 생성될 수 있습니다."

  L.empowered_message = "%s|1이;가; 강화되었습니다!"

  L.ironstar_impact_desc = "강철의 별이 다른 쪽 벽에 충돌하는 시점을 보여주는 타이머 바입니다."
  L.ironstar_rolling = "강철의 별 구르는 중!"

  L.chain_heal_desc = "{주시 대상}아군 대상을 치유해 최대 생명력의 40%에 해당하는 생명력을 회복시킨 뒤 주위의 아군 대상을 연쇄적으로 치유합니다."
  L.chain_heal_message = "당신의 주시 대상 연쇄 치유 시전 중!"
  L.chain_heal_bar = "주시 대상: 연쇄 치유"

  L.farseer_trigger = "선견자, 우리를 치료하라!"

  L.custom_off_shaman_marker = "선견자 징표 표시"
  L.custom_off_shaman_marker_desc = "시전 방해 할당을 돕기 위해, 선견자 늑대 기수를 {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r\n|cFFADFF2F팁: 공격대에서 자신이 이 기능을 켰다면 빠르게 몹에 마우스 오버하는게 징표를 지정하는 가장 빠른 방법입니다.|r"

  L.custom_off_minion_marker = "하수인 징표 표시"
  L.custom_off_minion_marker_desc = "강화된 소용돌이치는 타락 추가 몹의 분리를 돕기 위해 {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

	--L.warmup_yell_chat_trigger1 = "It is not too late, Garrosh" -- It is not too late, Garrosh. Lay down the mantle of Warchief. We can end this here, now, with no more bloodshed."
	--L.warmup_yell_chat_trigger2 = "Do you remember nothing of Honor" -- Ha! Do you remember nothing of Honor? Of glory on the battlefield?  You who would parlay with the humans, who allowed warlocks to practice their dark magics right under our feet.  You are weak.
end
