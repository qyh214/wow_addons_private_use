local L = BigWigs:NewBossLocale("Hellfire Assault", "koKR")
if not L then return end
if L then
	L.left = "왼쪽: %s"
	L.middle = "가운데: %s"
	L.right = "오른쪽: %s"
end

L = BigWigs:NewBossLocale("Kilrogg Deadeye", "koKR")
if L then
	L.add_warnings = "추가 몹 생성 경고"
end

L = BigWigs:NewBossLocale("Gorefiend", "koKR")
if L then
	L.fate_root_you = "이어진 운명 - 당신 이동 불가!"
	L.fate_you = "당신에게 이어진 운명! - %s 이동 불가"
end

L = BigWigs:NewBossLocale("Shadow-Lord Iskar", "koKR")
if L then
	L.custom_off_wind_marker = "실체 없는 바람 징표 표시"
	L.custom_off_wind_marker_desc = "실체 없는 바람의 대상을 {rt1}{rt2}{rt3}{rt4}{rt5} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r"

	L.bindings_removed = "결속 제거 (%d/3)"
	L.custom_off_binding_marker = "어둠의 결속 징표 표시"
	L.custom_off_binding_marker_desc = "어둠의 결속의 대상을 {rt1}{rt2}{rt3}{rt4}{rt5}{rt6} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r"
end

L = BigWigs:NewBossLocale("Socrethar the Eternal", "koKR")
if L then
	L.dominator_desc = "살게레이 통솔자가 생성되면 경고합니다."

	L.portals = "차원문 이동"
	L.portals_desc = "2단계 중 차원문의 위치 변경 타이머입니다."
	L.portals_msg = "차원문 이동!"
end

L = BigWigs:NewBossLocale("Fel Lord Zakuun", "koKR")
if L then
	L.seed = "씨앗"

	L.custom_off_seed_marker = "파괴의 씨앗 징표 표시"
	L.custom_off_seed_marker_desc = "파괴의 씨앗의 대상을 {rt1}{rt2}{rt3}{rt4}{rt5} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

	L.tank_proximity = "방어 전담 근접 표시"
	L.tank_proximity_desc = "잔인무도 & 중무장 능력을 같이 맞을 수 있게 다른 방어 전담을 표시하는 5미터 근접 표시창을 엽니다."
end

L = BigWigs:NewBossLocale("Tyrant Velhari", "koKR")
if L then
	L.font_removed_soon = "당신의 샘 곧 종료!"
end

L = BigWigs:NewBossLocale("Mannoroth", "koKR")
if L then
	L["185147"] = "파멸의 군주 차원문 닫힘!"
	L["185175"] = "임프 차원문 닫힘!"
	L["182212"] = "지옥불정령 차원문 닫힘!"

	L.gaze = "응시 (%d)"
	L.felseeker_message = "%s (%d) %d미터" -- same as Margok's branded_say

	L.custom_off_gaze_marker = "만노로스의 응시 징표 표시"
	L.custom_off_gaze_marker_desc = "만노로스의 응시의 대상을 {rt1}{rt2}{rt3} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

	L.custom_off_doom_marker = "파멸의 징표 징표 표시"
	L.custom_off_doom_marker_desc = "신화 난이도에서 파멸의 징표의 대상을 {rt1}{rt2}{rt3} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

	L.custom_off_wrath_marker = "굴단의 분노 징표 표시"
	L.custom_off_wrath_marker_desc = "굴단의 분노의 대상을 {rt8}{rt7}{rt6}{rt5}{rt4} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."
end

L = BigWigs:NewBossLocale("Archimonde", "koKR")
if L then
	L.torment_removed = "고통 제거됨 (%d/%d)"
	L.chaos_bar = "%s -> %s"
	L.chaos_from = "%2$s -> %1$s"
	L.chaos_to = "%s -> %s"
	L.infernal_count = "%s (%d/%d)"

	L.custom_off_torment_marker = "구속된 고통 징표 표시"
	L.custom_off_torment_marker_desc = "구속된 고통의 대상을 {rt1}{rt2}{rt3} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

	L.markofthelegion_self = "당신에게 군단의 징표"
	L.markofthelegion_self_desc = "당신에게 군단의 징표가 걸리면 특별한 초읽기를 합니다."
	L.markofthelegion_self_bar = "당신 폭발!"

	L.custom_off_legion_marker = "군단의 징표 징표 표시"
	L.custom_off_legion_marker_desc = "군단의 징표의 대상을 {rt1}{rt2}{rt3}{rt4} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

	L.custom_off_infernal_marker = "지옥불 멸망의 인도자 징표 표시"
	L.custom_off_infernal_marker_desc = "혼돈의 비로 생성된 지옥불 멸망의 인도자를 {rt1}{rt2}{rt3}{rt4}{rt5} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

	L.chaos_helper_message = "당신의 혼돈 숫자: %d"
end

L = BigWigs:NewBossLocale("Hellfire Citadel Trash", "koKR")
if L then
	L.orb = "파괴의 보주"
	L.enkindler = "불타는 점화술사"
	L.graggra = "그락그라"
	L.darkcaster = "피눈물 암흑술사"
	L.bloodthirster = "피에 굶주린 괴물"
	L.talonpriest = "타락한 갈퀴사제"
	L.peacekeeper = "피조물 평화감시단"
	L.eloah = "결속사 엘로아"
	L.faithbreaker = "에레다르 신념파괴자"
	L.kuroh = "수하 쿠로"
	L.daggorath = "다그고라스"
	L.burster = "그림자 광견"
	L.weaponlord = "무기군주 멜키오르"
	L.azgalor = "아즈갈로"
	L.kazrogal = "카즈로갈"
	L.anetheron = "아네테론"
end

