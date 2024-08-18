local L = BigWigs:NewBossLocale("Jin'rokh the Breaker", "koKR")
if not L then return end
if L then
	L.storm_duration = "번개 폭풍 지속시간"
	L.storm_duration_desc = "번개 폭풍 시전 지속시간을 분리된 바로 경고합니다."
	L.storm_short = "폭풍"
end

L = BigWigs:NewBossLocale("Horridon", "koKR")
if L then
	L.charge_trigger = "호리돈이 시선을" -- 호리돈이 시선을 PLAYERNAME에게 고정하고 꼬리를 바닥에 쿵쿵 내려칩니다!
	L.door_trigger = "쏟아져 나옵니다!" -- 파락키 부족 문에서 파락키 병력들이 쏟아져 나옵니다!
	L.orb_trigger = "돌진하게 합니다!" -- PLAYERNAME|1이;가; 호리돈을 파락키 문에 돌진하게 합니다!

	L.chain_lightning_desc = "|cffff0000주시 대상 경고만 표시합니다.|r {-7124}"
	L.chain_lightning_message = "당신의 주시 대상이 연쇄 번개를 시전합니다!"
	L.chain_lightning_bar = "주시 대상: 연쇄 번개"

	L.fireball_desc = "|cffff0000주시 대상 경고만 표시합니다.|r {-7122}"
	L.fireball_message = "당신의 주시 대상이 화염구를 시전합니다!"
	L.fireball_bar = "주시 대상: 화염구"

	L.venom_bolt_volley_desc = "|cffff0000주시 대상 경고만 표시합니다.|r {-7112}"
	L.venom_bolt_volley_message = "당신의 주시 대상이 일제 사격을 시전합니다!"
	L.venom_bolt_volley_bar = "주시 대상: 일제 사격"

	L.adds = "추가 몹 생성"
	L.adds_desc = "파락키, 구루바시, 드라카리, 아마니, 전쟁신 잘라크의 생성을 경고합니다."

	L.door_opened = "문 열림!"
	L.door_bar = "다음 문 (%d)"
	L.balcony_adds = "병력 등장"
	L.orb_message = "조종의 구슬 떨어뜨림!"
end

L = BigWigs:NewBossLocale("Council of Elders", "koKR")
if L then
	L.priestess_adds = "영혼 추가"
	L.priestess_adds_desc = "대여사제 말리가 영혼을 추가로 소환할때 경고합니다."
	L.priestess_adds_message = "영혼 추가"

	L.custom_on_markpossessed = "빙의된 우두머리 징표 표시"
	L.custom_on_markpossessed_desc = "빙의된 우두머리를 해골 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

	L.priestess_heal = "%s 치유됨!"
	L.assault_stun = "방어 전담 기절함!"
	L.assault_message = "혹한의 공격"
	L.full_power = "전체 기력"
	L.hp_to_go_power = "%d%% 생명력 이동! (기력: %d)"
	L.hp_to_go_fullpower = "%d%% 생명력 이동! (전체 기력)"
end

L = BigWigs:NewBossLocale("Tortos", "koKR")
if L then
	L.bats_desc = "박쥐 등장. 처리하세요."

	L.kick = "등껍질 차기"
	L.kick_desc = "찰 수 있는 거북이의 수를 추적합니다."
	L.kick_message = "찰 수 있는 거북이: %d"
	L.kicked_message = "%s 찼음! (%d 남음)"

	L.custom_off_turtlemarker = "거북이 징표 표시"
	L.custom_off_turtlemarker_desc = "거북이를 모든 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r\n|cFFADFF2F팁: 공격대에서 자신이 이 기능을 켰다면 빠르게 몹에 마우스 오버하는게 징표를 지정하는 가장 빠른 방법입니다.|r"

	L.no_crystal_shell = "수정 보호막 없음!"
end

L = BigWigs:NewBossLocale("Megaera", "koKR")
if L then
	L.breaths = "숨결"
	L.breaths_desc = "여러 숨결에 대한 경고를 합니다."

	L.arcane_adds = "황천 고룡 추가"
end

L = BigWigs:NewBossLocale("Ji-Kun", "koKR")
if L then
	L.first_lower_hatch_trigger = "아랫둥지에 있는 알들이 부화하기 시작합니다!"
	L.lower_hatch_trigger = "아랫둥지에 있는 알들이 부화하기 시작합니다!"
	L.upper_hatch_trigger = "위쪽 둥지에 있는 알들이 부화하기 시작합니다!"

	L.nest = "둥지"
	L.nest_desc = "둥지와 관련된 경고를 표시합니다.\n|cFFADFF2F팁: 둥지 처리에 지정되지 않았다면 이 경고를 끄세요.|r"

	L.flight_over = "%d초 후 비행 종료!"
	L.upper_nest = "|cff008000위쪽|r 둥지"
	L.lower_nest = "|cffff0000아랫|r둥지"
	L.up = "|cff008000위쪽|r"
	L.down = "|cffff0000아래쪽|r"
	L.add = "추가"
	L.big_add_message = "%s에 둥지 수호자 추가"
end

L = BigWigs:NewBossLocale("Durumu the Forgotten", "koKR")
if L then
	L.red_spawn_trigger = "진흥빛 안개"
	L.blue_spawn_trigger = "하늘빛 안개"
	L.yellow_spawn_trigger = "호박색 안개"

	L.adds = "안개도깨비 추가"
	L.adds_desc = "진홍빛, 호박색, 하늘빛 안개를 드러냈을 때 경고하고, 남은 안개의 수를 경고합니다."

	L.custom_off_ray_controllers = "광선 조종자"
	L.custom_off_ray_controllers_desc = "광선 생성 위치와 이동을 조절하는 사람을 {rt1}{rt7}{rt6} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

	L.custom_off_parasite_marks = "암흑의 기생충 징표 표시"
	L.custom_off_parasite_marks_desc = "치유 할당을 돕기 위해, 암흑의 기생충에 걸린 사람을 {rt3}{rt4}{rt5} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

	L.initial_life_drain = "생명력 흡수 초기 시전"
	L.initial_life_drain_desc = "받는 치유 감소 약화 효과 유지를 돕기 위해 생명력 흡수 초기 시전 메시지를 표시합니다."

	L.life_drain_say = "%dx 흡수"

	L.rays_spawn = "광선 생성"
	L.red_add = "|cffff0000붉은색|r 추가"
	L.blue_add = "|cff0000ff푸른색|r 추가"
	L.yellow_add = "|cffffff00노란색|r 추가"
	L.death_beam = "분해 광선"
	L.red_beam = "|cffff0000적외선|r"
	L.blue_beam = "|cff0000ff청색 광선|r"
	L.yellow_beam = "|cffffff00직사광선|r"
end

L = BigWigs:NewBossLocale("Primordius", "koKR")
if L then
	L.mutations = "변형 |cff008000(%d)|r |cffff0000(%d)|r"
	L.acidic_spines = "산성 가시 (반경 피해)"
end

L = BigWigs:NewBossLocale("Dark Animus", "koKR")
if L then
	L.engage_trigger = "구슬이 폭발합니다!"

	L.matterswap_desc = "물질 바꾸기에 걸린 플레이어는 당신과 멀리 떨어져 있습니다. 해제되면 당신은 대상과 자리를 바꿉니다."
	L.matterswap_message = "물질 바꾸기 대상과 가장 멉니다!"

	L.siphon_power = "령 착취 (%d%%)"
	L.siphon_power_soon = "령 착취 (%d%%) 곧 %s!"
	L.slam_message = "격돌"
end

L = BigWigs:NewBossLocale("Iron Qon", "koKR")
if L then
	L.molten_energy = "타오르는 에너지"

	L.arcing_lightning_cleared = "공격대 휘어진 번개 사라짐"
end

L = BigWigs:NewBossLocale("Twin Consorts", "koKR")
if L then
	L.last_phase_yell_trigger = "그래야 한다면..." -- "<490.4 01:24:30> CHAT_MSG_MONSTER_YELL#Just this once...#Lu'lin###Suen##0#0##0#3273#nil#0#false#false", -- [6]

	L.barrage_fired = "우주의 포화!"
end

L = BigWigs:NewBossLocale("Lei Shen", "koKR")
if L then
	L.custom_off_diffused_marker = "확산된 번개 징표 표시"
	L.custom_off_diffused_marker_desc = "확산된 번개를 모든 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r\n|cFFADFF2F팁: 공격대에서 자신이 이 기능을 켰다면 빠르게 몹에 마우스 오버하는게 징표를 지정하는 가장 빠른 방법입니다.|r"

	L.shock_self = "당신에게 전하 충격"
	L.shock_self_desc = "당신에게 걸린 전하 충격 약화 효과의 지속시간 바를 표시합니다."

	L.overcharged_self = "당신에게 과충전"
	L.overcharged_self_desc = "당신에게 걸린 과충전 약화 효과의 지속시간 바를 표시합니다."

	L.last_inermission_ability = "마지막 도관 작동 능력 사용!"
	L.safe_from_stun = "당신은 아마도 과충전 기절에 안전합니다"
	L.diffusion_add = "확산 추가 몹"
	L.shock = "충격"
	L.static_shock_bar = "<전하 충격 산개>"
	L.overcharge_bar = "<과충전 파동>"
end

L = BigWigs:NewBossLocale("Ra-den", "koKR")
if L then
	L.vita_abilities = "생령 능력"
	L.anima_abilities = "령 능력"
	L.worm = "벌레"
	L.worm_desc = "벌레 소환"
	L.balls = "정수"
	L.balls_desc = "라덴이 획득할 능력을 결정하는 령 (붉은색)과 생령 (푸른색) 정수"
	L.corruptedballs = "타락한 정수"
	L.corruptedballs_desc = "피해 증가 (생령) 또는 최대 생명력 증가 (령)시키는 타락한 생령과 령 정수"
	L.unstablevitajumptarget = "불안정한 생령 대상 이동"
	L.unstablevitajumptarget_desc = "불안정한 생령에 걸린 플레이어와 가장 멀리 있을 때 알려줍니다. 이 경고를 강조하면 불안정한 생령이 당신에게서 옮겨가는 시점에 대한 초읽기를 확인할 수 있습니다."
	L.unstablevitajumptarget_message = "불안정한 생령으로부터 가장 멀리 있습니다"
	L.sensitivityfurthestbad = "민감한 생령 + 가장 멈 = |cffff0000나쁨|r!"
	L.kill_trigger = "잠깐!" -- 잠깐! 난... 난 적이 아니다. 너희는 예전의 그보다도 강하구나. 어쩌면 너희가 옳을지도 모른다, 정말 희망이 있을지도.

	L.assistPrint = "라덴 전투에 도움을 주는 'BigWigs_Ra-denAssist' 플러그인이 배포됐습니다."
end

L = BigWigs:NewBossLocale("Throne of Thunder Trash", "koKR")
if L then
	L.stormcaller = "잔달라 폭풍소환사"
	L.stormbringer = "폭풍인도자 드라즈킬"
	L.monara = "모나라"
	L.rockyhorror = "공포의 바위"
	L.thunderlord_guardian = "천둥 군주 / 번개 수호자"
end
