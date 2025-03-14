local L = BigWigs:NewBossLocale("Razorgore the Untamed", "ruRU")
if not L then return end
if L then
	L.start_trigger = "Злоумышленники проломились"

	L.eggs = "Считать яйца"
	L.eggs_desc = "Пересчитывать уничтоженные яйца."
	L.eggs_message = "%d/30 яиц уничтожено"
end

L = BigWigs:NewBossLocale("Vaelastrasz the Corrupt", "ruRU")
if L then
	--L.warmup_trigger = "Too late, friends!"
	--L.tank_bomb = "Tank Bomb"
end

L = BigWigs:NewBossLocale("Chromaggus", "ruRU")
if L then
	L.breath = "Дыхание"
	L.breath_desc = "Сообщать о дыхании."

	--L.debuffs_message = "3/5 debuffs, carefull!"
	--L.debuffs_warning = "4/5 debuffs, %s on 5th!"
	L.bronze = "Бронзовое"

	L.vulnerability = "Изменение уязвимости"
	L.vulnerability_desc = "Сообщать когда уязвимость изменяется."
	L.vulnerability_message = "Уязвимость: %s"
	L.detect_magic_missing = "Распознавание магии is missing from Chromaggus"
	L.detect_magic_warning = "A Mage must cast \124cff71d5ff\124Hspell:2855:0\124h[Распознавание магии]\124h\124r on Chromaggus for vulnerability warnings to work."
end

L = BigWigs:NewBossLocale("Nefarian Classic", "ruRU")
if L then
	--L.engage_yell_trigger = "Let the games begin"
	L.stage3_yell_trigger = "Невозможно!"

	L.shaman_class_call_yell_trigger = "Шаманы! Покажитесь мне!"
	L.deathknight_class_call_yell_trigger = "Рыцари смерти! Сюда!"
	--L.monk_class_call_yell_trigger = "Monks"
	L.hunter_class_call_yell_trigger = "Охотники и ваше раздражение"

	L.warnshaman = "Шаманы - ставьте тотемы!"
	L.warndruid = "Друиды - пробудите в себе зверя!"
	L.warnwarlock = "Чернокнижники - вызывайте инферналов!"
	L.warnpriest = "Жрецы - исцеляйте повреждения!"
	L.warnhunter = "Охотники - доставайте свои луки!"
	L.warnwarrior = "Войны - становитесь в атакующие стойки!"
	L.warnrogue = "Разбойники - точите свои клинки!"
	L.warnpaladin = "Паладины - улучшайте защиту!"
	L.warnmage = "Маги - используйте превращение!"
	--L.warndeathknight = "Death Knights - Death Grip"
	--L.warnmonk = "Monks - Stuck Rolling"
	--L.warndemonhunter = "Demon Hunters - Blinded"

	L.classcall = "Классовый вызов"
	L.classcall_desc = "Предупреждать о классовом вызове."

	--L.add = "Drakonid deaths"
	--L.add_desc = "Announce the number of adds killed in stage 1 before Nefarian lands."
end

L = BigWigs:NewBossLocale("Blackwing Lair Trash", "ruRU")
if L then
	L.wyrmguard_overseer = "Змеестраж Когтя Смерти / Надзиратель Когтя Смерти" -- NPC 12460 / 12461
	L.sandstorm = "Песчаная буря"

	--L.target_vulnerability = "Target Vulnerability Warnings"
	--L.target_vulnerability_desc = "When your target is a Death Talon Wyrmguard or a Death Talon Overseer, show a warning for what vulnerability it has."
	--L.target_vulnerability_message = "Target Vulnerability: %s"
	L.detect_magic_missing_message = "Распознавание магии is missing from your target"
	L.detect_magic_warning = "A Mage must cast \124cff71d5ff\124Hspell:2855:0\124h[Распознавание магии]\124h\124r on your target for vulnerability warnings to work."

	L.warlock = "Чернокнижник Крыла Тьмы" -- NPC 12459
end
