local L = BigWigs:NewBossLocale("Anub'Rekhan", "koKR")
if not L then return end
if L then
	L.add = "지하마귀 수호병"
	L.locust = "무리바퀴"
end

L = BigWigs:NewBossLocale("Grand Widow Faerlina", "koKR")
if L then
	L.silencewarn = "침묵!"
	L.silencewarn5sec = "5초 후 침묵 종료!"
	L.silence = "침묵"
end

L = BigWigs:NewBossLocale("Gothik the Harvester", "koKR")
if L then
	L.phase1_trigger1 = "어리석은 것들, 스스로 죽음을 자초하다니!"
	--L.phase1_trigger2 = "Teamanare shi rikk mannor rikk lok karkun" -- Curse of Tongues
	L.phase2_trigger = "오랫동안 기다렸다. 이제 영혼 착취자를 만날 차례다."

	L.add = "추가 몹 알림"
	L.add_desc = "추가 몹을 알립니다."

	L.add_death = "추가 몹 죽음 알림"
	L.add_death_desc = "추가된 몹 죽음을 알립니다."

	L.riderdiewarn = "기병 죽음!"
	L.dkdiewarn = "죽음의 기사 죽음!"

	L.wave = "%d/23: %s"

	L.trawarn = "수습생 3초 후 등장"
	L.dkwarn = "죽음의 기사 3초 후 등장"
	L.riderwarn = "기병 3초 후 등장"

	L.trabar = "수습생 (%d)"
	L.dkbar = "죽음의 기사 (%d)"
	L.riderbar = "기병 (%d)"

	--L.gate = "Gate Open!"
	--L.gatebar = "Gate opens"

	L.phase_soon = "고딕 등장 10초 전"

	L.engage_message = "영혼 착취자 고딕 전투 시작!"
end

L = BigWigs:NewBossLocale("Grobbulus", "koKR")
if L then
	L.injection = "돌연변이 유발"
end

L = BigWigs:NewBossLocale("Heigan the Unclean", "koKR")
if L then
	L.teleport_yell_trigger = "여기가 너희 무덤이 되리라."
end

L = BigWigs:NewBossLocale("The Four Horsemen", "koKR")
if L then
	L.mark = "징표"
	L.mark_desc = "징표를 알립니다."

	L.engage_message = "4인의 기병대 전투 시작!"
end

L = BigWigs:NewBossLocale("Kel'Thuzad Naxxramas", "koKR")
if L then
	L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "켈투자드의 방"

	L.phase1_trigger = "어둠의 문지기와 하수인, 그리고 병사들이여! 나 켈투자드가 부르니 명을 받들라!"
	L.phase2_trigger1 = "자비를 구하라!" -- CHECK
	L.phase2_trigger2 = "마지막 숨이나 쉬어라!"
	L.phase2_trigger3 = "최후를 맞이하라!"
	L.phase3_trigger = "주인님, 도와주소서!"
	L.guardians_trigger = "좋다. 얼어붙은 땅의 전사들이여, 일어나라! 너희에게 싸울 것을 명하노라. 날 위해 죽고, 날 위해 죽여라! 한 놈도 살려두지 마라!"

	L.phase2_warning = "2 단계 - 켈투자드!"
	L.phase2_bar = "켈투자드 활동!"

	L.phase3_warning = "3 단계 - 약 15초 이내 수호자 등장!"

	L.guardians = "수호자 생성"
	L.guardians_desc = "3 단계의 수호자 소환을 알립니다."
	L.guardians_warning = "10초 이내 수호자 등장!"
	L.guardians_bar = "수호자 등장!"

	L.engage_message = "켈투자드 전투 시작! 약 3분 30초 후 활동!"
end

L = BigWigs:NewBossLocale("Loatheb", "koKR")
if L then
	L.doomtime_bar = "파멸 - 매 15초"
	L.doomtime_now = "피할 수 없는 파멸! 지금부터 매 15초마다."

	L.spore_warn = "포자 (%d)"
end

L = BigWigs:NewBossLocale("Noth the Plaguebringer", "koKR")
if L then
	L.adds_yell_trigger = "일어나라,병사들이여" -- 일어나라,병사들이여! 다시 일어나 싸워라!
end

L = BigWigs:NewBossLocale("Maexxna", "koKR")
if L then
	L.webspraywarn30sec = "10초 이내 거미줄 감싸기"
	L.webspraywarn20sec = "거미줄 감싸기. 10초 후 거미 소환!"
	L.webspraywarn10sec = "거미 소환. 10초 후 거미줄 뿌리기!"
	L.webspraywarn5sec = "5초 후 거미줄 뿌리기!"

	L.enragewarn = "광기!"
	L.enragesoonwarn = "잠시 후 광기!"

	L.cocoons = "거미줄 감싸기"
	L.spiders = "거미 소환"
end

L = BigWigs:NewBossLocale("Sapphiron", "koKR")
if L then
	L.airphase_trigger = "사피론이 공중으로 떠오릅니다!"
	L.deepbreath_trigger = "%s|1이;가; 숨을 깊게 들이마십니다."

	-- L.air_phase = "Air Phase"
	-- L.ground_phase = "Ground Phase"

	L.ice_bomb = "얼음 폭탄"
	L.ice_bomb_warning = "잠시 후 얼음 폭탄!"
	L.ice_bomb_bar = "얼음 폭탄 떨어짐!"

	L.icebolt_say = "저 방패에요!"
end

L = BigWigs:NewBossLocale("Instructor Razuvious", "koKR")
if L then
	L.understudy = "죽음의 기사 수습생"

	L.shout_warning = "5초 후 분열의 외침!"
	L.taunt_warning = "5초 후 도발 종료!"
	L.shieldwall_warning = "5초 후 방패의 벽 종료!"
end

L = BigWigs:NewBossLocale("Thaddius", "koKR")
if L then
	L[15929] = "스탈라그"
	L[15930] = "퓨진"

	L.stage1_yell_trigger1 = "스탈라그, 박살낸다!"
	L.stage1_yell_trigger2 = "너 주인님께 바칠꺼야!"

	L.stage2_yell_trigger1 = "잡아... 먹어주마..."
	L.stage2_yell_trigger2 = "박살을 내주겠다!"
	L.stage2_yell_trigger3 = "죽여주마..."

	L.add_death_emote_trigger = "%s|1이;가; 죽습니다."
	L.overload_emote_trigger = "%s|1이;가; 과부하 상태가 됩니다."
	--L.add_revive_emote_trigger = "%s is jolted back to life!"

	--L.polarity_extras = "Additional alerts for Polarity Shift positioning"

	--L.custom_off_select_charge_position = "First position"
	--L.custom_off_select_charge_position_desc = "Where to move to after the first Polarity Shift."
	--L.custom_off_select_charge_position_value1 = "|cffff2020Negative (-)|r are LEFT, |cff2020ffPositive (+)|r are RIGHT"
	--L.custom_off_select_charge_position_value2 = "|cff2020ffPositive (+)|r are LEFT, |cffff2020Negative (-)|r are RIGHT"

	--L.custom_off_select_charge_movement = "Movement"
	--L.custom_off_select_charge_movement_desc = "The movement strategy your group uses."
	--L.custom_off_select_charge_movement_value1 = "Run |cff20ff20THROUGH|r the boss"
	--L.custom_off_select_charge_movement_value2 = "Run |cff20ff20CLOCKWISE|r around the boss"
	--L.custom_off_select_charge_movement_value3 = "Run |cff20ff20COUNTER-CLOCKWISE|r around the boss"
	--L.custom_off_select_charge_movement_value4 = "Four camps 1: Polarity changed moves |cff20ff20RIGHT|r, same polarity moves |cff20ff20LEFT|r"
	--L.custom_off_select_charge_movement_value5 = "Four camps 2: Polarity changed moves |cff20ff20LEFT|r, same polarity moves |cff20ff20RIGHT|r"

	--L.custom_off_charge_graphic = "Graphical arrow"
	--L.custom_off_charge_graphic_desc = "Show an arrow graphic."
	--L.custom_off_charge_text = "Text arrows"
	--L.custom_off_charge_text_desc = "Show an additional message."
	--L.custom_off_charge_voice = "Voice alert"
	--L.custom_off_charge_voice_desc = "Play a voice alert."

	L.left = "<--- 왼쪽으로 <--- 왼쪽으로 <---"
	L.right = "---> 오른쪽으로 ---> 오른쪽으로 --->"
	L.swap = "^^^^ 방향 전환 ^^^^ 방향 전환 ^^^^"
	L.stay = "==== 움직 이지마 ==== 움직 이지마 ===="

	--L.chat_message = "The Thaddius mod supports showing you directional arrows and playing voices. Open the options to configure them."
end
