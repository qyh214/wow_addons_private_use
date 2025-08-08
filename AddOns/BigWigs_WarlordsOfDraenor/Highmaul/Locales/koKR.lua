local L = BigWigs:NewBossLocale("Kargath Bladefist", "koKR")
if not L then return end
if L then
  L.blade_dance_bar = "칼춤 중"

  L.arena_sweeper_desc = "사슬 던지기로 던져진 이후 높은망치 난동꾼이 쫓아낼 때까지의 타이머입니다."
end

L = BigWigs:NewBossLocale("The Butcher", "koKR")
if L then
  L.adds_multiple = "추가 몹 x%d"

  L.tank_proximity = "방어 전담 근접 표시"
  L.tank_proximity_desc = "잔인무도 능력을 같이 맞도록 다른 방어 전담을 보여주는 5미터 근접 표시창을 엽니다."
end

L = BigWigs:NewBossLocale("Tectus", "koKR")
if L then
  L.adds_desc = "새로운 추가 몹이 전투에 참여하는 타이머입니다."

  L.custom_off_barrage_marker = "수정 포화 징표 표시"
  L.custom_off_barrage_marker_desc = "수정 포화의 대상을 {rt1}{rt2}{rt3}{rt4}{rt5} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

  L.custom_on_shard_marker = "텍터스의 조각 징표 표시"
  L.custom_on_shard_marker_desc = "생성된 두 텍터스의 조각을 {rt8}{rt7} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."

  L.shard = "조각"
  L.motes = "자갈"
end

L = BigWigs:NewBossLocale("Brackenspore", "koKR")
if L then
  L.mythic_ability = "특수 능력"
  L.mythic_ability_desc = "다음 해일의 부름이나 곰팡이 폭발의 타이머 바를 표시합니다."
  L.mythic_ability_wave = "파도 오는 중!"

  L.custom_off_spore_shooter_marker = "포자 식물 징표 표시"
  L.custom_off_spore_shooter_marker_desc = "포자 식물을 {rt1}{rt2}{rt3}{rt4} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r\n|cFFADFF2F팁: 공격대에서 자신이 이 기능을 켰다면 빠르게 몹에 마우스 오버하는게 징표를 지정하는 가장 빠른 방법입니다.|r"

  L.creeping_moss_boss_heal = "우두머리 밑에 이끼 (치유 중)"
  L.creeping_moss_add_heal = "큰 쫄 밑에 이끼 (치유 중)"
end

L = BigWigs:NewBossLocale("Twin Ogron", "koKR")
if L then
  L.volatility_self_desc = "당신에게 불안정한 비전 약화 효과가 걸렸을 때를 위한 옵션입니다."

  L.custom_off_volatility_marker = "불안정한 비전 징표 표시"
  L.custom_off_volatility_marker_desc = "불안정한 비전의 대상을 {rt1}{rt2}{rt3}{rt4} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."
end

L = BigWigs:NewBossLocale("Ko'ragh", "koKR")
if L then
  L.fire_bar = "모두 폭발!"
  L.overwhelming_energy_bar = "구체 적중 (%d)"
  L.dominating_power_bar = "정신 지배 구체 적중 (%d)"

  L.custom_off_fel_marker = "마법 방출: 악마 징표 표시"
  L.custom_off_fel_marker_desc = "마법 방출: 악마 대상을 {rt1}{rt2}{rt3} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r"
end

L = BigWigs:NewBossLocale("Imperator Mar'gok", "koKR")
if L then
  L.branded_say = "%s (%d) %d미터"
  L.add_death_soon = "곧 추가 몹 죽음!"
  L.slow_fixate = "감속+시선 집중"

  L.adds = "뒤틀린 밤의 신봉자"
  L.adds_desc = "뒤틀린 밤의 신봉자가 전투에 참여하는 타이머입니다."

  L.custom_off_fixate_marker = "시선 집중 징표 표시"
  L.custom_off_fixate_marker_desc = "고리안 전투마법사의 시선 집중 대상을 {rt1}{rt2} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r"

  L.custom_off_branded_marker = "낙인 징표 표시"
  L.custom_off_branded_marker_desc = "낙인 대상을 {rt3}{rt4} 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다."
end

L = BigWigs:NewBossLocale("Highmaul Trash", "koKR")
if L then
  L.oro = "오로"
  L.runemaster = "고리안 룬술사"
  L.arcanist = "고리안 비전술사"
  L.ritualist = "파괴자 의식술사"
end

