
local L = BigWigs:NewBossLocale("Protectors of the Endless", "koKR")
if not L then return end
if L then
  L.under = "%s 밑에 %s!"
  L.heal = "%s 치유"
end

L = BigWigs:NewBossLocale("Tsulong", "koKR")
if L then
  L.engage_yell = "여긴 너희가 있을 곳이 아니다! 이 물은 보호해야 해... 물러서지 않겠다면 처치해주마!"
  L.kill_yell = "고맙다, 이방인이여. 날 자유롭게 해줘서."

  L.phases = "단계"
  L.phases_desc = "단계 변경을 경고합니다."

  L.sunbeam_spawn = "새로운 태양 광선!"
end

L = BigWigs:NewBossLocale("Lei Shi", "koKR")
if L then
  L.hp_to_go = "%d%% 남음"

  L.special = "다음 특수 능력"
  L.special_desc = "다음 특수 능력에 대한 경고입니다."

  L.custom_off_addmarker = "수호병 징표 표시"
  L.custom_off_addmarker_desc = "레이 스의 보호 단계 중 살아난 수호병을 징표로 표시합니다, 부공격대장 이상의 권한이 필요합니다.\n|cFFFF0000공격대에서 1명만 이 기능을 사용하여 징표 지정 충돌을 방지해야 합니다.|r\n|cFFADFF2F팁: 공격대에서 자신이 이 기능을 켰다면 빠르게 몹에 마우스 오버하는게 징표를 지정하는 가장 빠른 방법입니다.|r"
end

L = BigWigs:NewBossLocale("Sha of Fear", "koKR")
if L then
  L.fading_soon = "곧 %s 사라짐"

  L.swing = "자동 공격"
  L.swing_desc = "난타 이전의 자동 공격 횟수를 셉니다."

  L.throw = "던지기!"
  L.ball_dropped = "빛 떨굼!"
  L.ball_you = "당신이 빛을 가졌습니다!"
  L.ball = "빛"

  L.cooldown_reset = "당신의 재사용 대기시간 초기화!"

  L.ability_cd = "능력 재사용 대기시간 바"
  L.ability_cd_desc = "다음 가능한 능력이나 능력들을 표시합니다."

  L.strike_or_spout = "일격 또는 용오름"
  L.huddle_or_spout_or_strike = "혼비백산 또는 용오름 또는 일격"

  L.custom_off_huddle = "혼비백산 징표 표시"
  L.custom_off_huddle_desc = "치유 할당을 돕기 위해, 혼비백산을 가진 사람을 {rt1}{rt2}{rt3}{rt4}{rt5}{rt6} 징표로 표시합니다, 부공격대장 이상의 권한의 필요합니다."
end

