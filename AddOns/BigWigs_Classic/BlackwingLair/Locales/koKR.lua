local L = BigWigs:NewBossLocale("Razorgore the Untamed", "koKR")
if not L then return end
if L then
	L.start_trigger = "침입자들이 들어왔다! 어떤 희생이 있더라도 알을 반드시 수호하라!"

	L.eggs = "알 개수 알림 미사용"
	L.eggs_desc = "남은 알 개수 알림 미사용."
	L.eggs_message = "%d/30 알을 파괴하였습니다"
end

L = BigWigs:NewBossLocale("Vaelastrasz the Corrupt", "koKR")
if L then
	--L.warmup_trigger = "Too late, friends!"
	--L.tank_bomb = "Tank Bomb"
end

L = BigWigs:NewBossLocale("Chromaggus", "koKR")
if L then
	L.breath = "브레스 경고"
	L.breath_desc = "브레스에 대한 경고"

	--L.debuffs_message = "3/5 debuffs, carefull!"
	--L.debuffs_warning = "4/5 debuffs, %s on 5th!"
	L.bronze = "청동"

	L.vulnerability = "약화 속성 경고"
	L.vulnerability_desc = "약화 속성 변경에 대한 경고."
	L.vulnerability_message = "새로운 취약 속성: %s"
	L.detect_magic_missing = "마법 감지 is missing from Chromaggus"
	L.detect_magic_warning = "A Mage must cast \124cff71d5ff\124Hspell:2855:0\124h[마법 감지]\124h\124r on Chromaggus for vulnerability warnings to work."
end

L = BigWigs:NewBossLocale("Nefarian Classic", "koKR")
if L then
	--L.engage_yell_trigger = "Let the games begin"
	L.stage3_yell_trigger = "말도 안 돼! 일어나라!"

	L.shaman_class_call_yell_trigger = "주술사"
	--L.deathknight_class_call_yell_trigger = "Death Knights"
	--L.monk_class_call_yell_trigger = "Monks"
	L.hunter_class_call_yell_trigger = "그 장난감"

	L.warnshaman = "주술사 - 토템 파괴!"
	L.warndruid = "드루이드 - 강제 표범 변신!"
	L.warnwarlock = "흑마법사 - 지옥불정령 등장!"
	L.warnpriest = "사제 - 치유 주문 금지!"
	L.warnhunter = "사냥꾼 - 원거리 무기 파손!"
	L.warnwarrior = "전사 - 광태 강제 전환!"
	L.warnrogue = "도적 - 강제 소환!"
	L.warnpaladin = "성기사 - 강제 보축 사용!"
	L.warnmage = "마법사 - 변이!"
	--L.warndeathknight = "Death Knights - Death Grip"
	--L.warnmonk = "Monks - Stuck Rolling"
	--L.warndemonhunter = "Demon Hunters - Blinded"

	L.classcall = "직업 지목"
	L.classcall_desc = "직업 지목에 대한 경고"

	--L.add = "Drakonid deaths"
	--L.add_desc = "Announce the number of adds killed in stage 1 before Nefarian lands."
end

L = BigWigs:NewBossLocale("Blackwing Lair Trash", "koKR")
if L then
	L.wyrmguard_overseer = "죽음의발톱 고룡수호병 / 죽음의발톱 감독관" -- NPC 12460 / 12461
	L.sandstorm = "모래폭풍"

	--L.target_vulnerability = "Target Vulnerability Warnings"
	--L.target_vulnerability_desc = "When your target is a Death Talon Wyrmguard or a Death Talon Overseer, show a warning for what vulnerability it has."
	--L.target_vulnerability_message = "Target Vulnerability: %s"
	L.detect_magic_missing_message = "마법 감지 is missing from your target"
	L.detect_magic_warning = "A Mage must cast \124cff71d5ff\124Hspell:2855:0\124h[마법 감지]\124h\124r on your target for vulnerability warnings to work."

	L.warlock = "검은날개 흑마법사" -- NPC 12459
end
