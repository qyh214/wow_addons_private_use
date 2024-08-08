local L = BigWigs:NewBossLocale("Viscidus", "ruRU")
if not L then return end
if L then
	L.freeze = "Замораживающие состояния"
	L.freeze_desc = "Предупреждать о различных замороженных состояниях."

	L.freeze_trigger1 = "%s замедлен!"
	L.freeze_trigger2 = "%s замерзает!"
	L.freeze_trigger3 = "%s заморожен!"
	L.freeze_trigger4 = "%s Начинает трескаться!"
	L.freeze_trigger5 = "%s Скоро разобьётся на части!"

	L.freeze_warn1 = "Первая фаза заморозки!"
	L.freeze_warn2 = "Вторая фаза заморозки!"
	L.freeze_warn3 = "Нечистотон заморожен!"
	L.freeze_warn4 = "Ломается - продолжайте!"
	L.freeze_warn5 = "Ломается - почти готово!"
	L.freeze_warn_melee = "%d атак в ближнем бою - осталось %d"
	L.freeze_warn_frost = "%d морозных атак - осталось еще %d"
end

L = BigWigs:NewBossLocale("Ouro", "ruRU")
if L then
	L.engage_message = "Оуро занят! Возможное погружение через 90 секунд!"
	L.possible_submerge_bar = "Возможное погружение"

	L.emerge_message = "Оуро появился"
	L.emerge_bar = "Появление"

	L.submerge_message = "Оуро погрузился"
	L.submerge_bar = "Погружение"

	L.scarab = "Скарабей исчез"
	L.scarab_desc = "Предупреждать об исчезновении скарабея."
	L.scarab_bar = "Скарабеи исчезли"
end

L = BigWigs:NewBossLocale("C'Thun", "ruRU")
if L then
	L.claw_tentacle = "Когтещупальце"
	L.claw_tentacle_desc = "Таймеры для Когтещупальца."

	L.giant_claw_tentacle = "Гигантское Когтещцпальце"
	L.giant_claw_tentacle_desc = "Таймеры для Гигантского Когтещупальца."

	L.eye_tentacles = "Глазастое щупальце"
	L.eye_tentacles_desc = "Таймеры для 8 Глазастых щупалец."

	L.giant_eye_tentacle = "Огромный глаз"
	L.giant_eye_tentacle_desc = "Таймеры для Огромного глазастого щупальца."

	L.weakened_desc = "Предупреждение об ослаблении."

	--L.dark_glare_message = "%s: %s (Group %s)" -- Dark Glare: PLAYER_NAME (Group 1)
	L.stomach = "Желудок"
	L.tentacle = "Щупальце (%d)"
end

L = BigWigs:NewBossLocale("Ahn'Qiraj Trash", "ruRU")
if L then
	L.sentinel = "Анубисат-часовой" -- NPC 15264
	L.brainwasher = "Киражский опустошитель разума" -- NPC 15247
	L.defender = "Анубисат-защитник" -- NPC 15277
	L.crawler = "Векнисский ядохвост" -- NPC 15240

	L.target_buffs = "Предупреждения о баффах цели"
	L.target_buffs_desc = "Когда ваша цель - Анубисат-часовой, показывать предупреждение о том, какой у него бафф."
	L.target_buffs_message = "Бафф цели: %s"
	L.detect_magic_missing_message = "Распознавание магии у вашей цели отсутствует"
	L.detect_magic_warning = "Маг должен наложить \124cff71d5ff\124Hspell:2855:0\124h[Распознавание магии]\124h\124r на вашу цель, чтобы предупреждения о баффах работали."
end
