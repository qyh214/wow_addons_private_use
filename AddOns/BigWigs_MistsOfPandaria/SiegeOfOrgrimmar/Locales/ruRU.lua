local L = BigWigs:NewBossLocale("The Fallen Protectors", "ruRU")
if not L then return end
if L then
L["defile_you"] = "Оскверненная земля под тобой"
L["defile_you_desc"] = "Предупреждать, если Оскверненная земля под тобой."
L["inferno_self"] = "Адский удар на тебе"
L["inferno_self_bar"] = "Ты взорвешься!"
L["inferno_self_desc"] = "Особый отсчет, когда Адский удар на тебе."
L["intermission_desc"] = "Предупреждать, когда боссы применяют Крайние меры."
L["no_meditative_field"] = "Ты не в пузыре!"

	L.custom_off_bane_marks = "Маркировка Слово Тьмы: Погибель"
	L.custom_off_bane_marks_desc = "Чтобы помочь с рассеиванием, на людей со Словом Тьмы: Погибель будут поставлены метки {rt1}{rt2}{rt3}{rt4}{rt5} (в этой последовательности, не все метки могут быть использованы), требуется быть помощником или лидером."
end

L = BigWigs:NewBossLocale("Norushen", "ruRU")
if L then
L["big_add"] = "Большой помощник (%d)"
L["big_add_killed"] = "Большой помощник убит (%d)"
L["big_adds"] = "Большие помощники"
L["big_adds_desc"] = "Предупреждать, когда большие помощники появляются или их убивают."
L["warmup_trigger"] = "Хорошо, я создам поле для удерживания порчи."
end

L = BigWigs:NewBossLocale("Sha of Pride", "ruRU")
if L then
L["projection_green_arrow"] = "ЗЕЛЁНАЯ СТРЕЛКА"
L["titan_pride"] = "Титан+Гордыня: %s"

	L.custom_off_titan_mark = "Маркировка Дара титанов"
	L.custom_off_titan_mark_desc = "Отмечать людей с Даром титанов метками {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}, требуется быть помощником или лидером.\n|cFFFF0000Только 1 человек в рейде должен включить эту опцию, чтобы предотвратить конфликты.|r"

	L.custom_off_fragment_mark = "Маркировка Оскверненных осколков"
	L.custom_off_fragment_mark_desc = "На Оскверненные осколки будут поставлены метки {rt8}{rt7}, требуется быть помощником или лидером.\n|cFFFF0000Только 1 человек в рейде должен включить эту опцию, чтобы предотвратить конфликты.|r"
end

L = BigWigs:NewBossLocale("Galakras", "ruRU")
if L then
L["adds_desc"] = "Таймеры, когда новые помощники вступят в бой."
L["demolisher_message"] = "Разрушитель"
L["drakes"] = "Протодраконы"
L["north_tower"] = "Северная башня"
L["north_tower_trigger"] = "Дверь северной башни разбита!"
L["south_tower"] = "Южная башня"
L["south_tower_trigger"] = "Дверь южной башни разбита!"
L["start_trigger_alliance"] = "Отлично! Десант, стройся! Пехота – впереди."
L["start_trigger_horde"] = "Отлично, первый отряд высадился."
L["tower_defender"] = "Защитник башни"
L["towers"] = "Башня"
L["towers_desc"] = "Предупреждать, когда разбиваются двери башен."
L["warlord_zaela"] = "Полководец Зела"

	L.custom_off_shaman_marker = "Маркировка Шаманов"
	L.custom_off_shaman_marker_desc = "Чтобы помочь с распределением прерываний, на Шаманов прилива из клана Драконьей Пасти будут поставлены метки {rt1}{rt2}{rt3}{rt4}{rt5}, требуется быть помощником или лидером.\n|cFFFF0000Только 1 человек в рейде должен включить эту опцию, чтобы предотвратить конфликты.|r\n|cFFADFF2FСОВЕТ: Если вы выбраны для этой задачи, быстро проведите указателем мыши по шаманам, метки сразу же поставятся.|r"
end

L = BigWigs:NewBossLocale("Iron Juggernaut", "ruRU")
if L then
	L.custom_off_mine_marks = "Маркировка мин"
	L.custom_off_mine_marks_desc = "Чтобы помочь с подрывом, на Ползучие мины будут поставлены метки {rt1}{rt2}{rt3}, требуется быть помощником или лидером.\n|cFFFF0000Только 1 человек в рейде должен включить эту опцию, чтобы предотвратить конфликты.|r\n|cFFADFF2FСОВЕТ: Если вы выбраны для этой задачи, быстро проведите указателем мыши по минам, метки сразу же поставятся.|r"
end

L = BigWigs:NewBossLocale("Kor'kron Dark Shaman", "ruRU")
if L then
L["blobs"] = "Капли"

	L.custom_off_mist_marks = "Маркировка Токсичного тумана"
	L.custom_off_mist_marks_desc = "Чтобы помочь лекарям, на людей с Токсичным туманом будут поставлены метки {rt1}{rt2}{rt3}{rt4}{rt5}, требуется быть помощником или лидером.\n|cFFFF0000Только 1 человек в рейде должен включить эту опцию, чтобы предотвратить конфликты.|r"
end

L = BigWigs:NewBossLocale("General Nazgrim", "ruRU")
if L then
	L.custom_off_bonecracker_marks = "Маркировка Костолома"
	L.custom_off_bonecracker_marks_desc = "Чтобы помочь лекарям, на людей с Костоломом будут поставлены метки {rt1}{rt2}{rt3}{rt4}{rt5}, требуется быть помощником или лидером.\n|cFFFF0000Только 1 человек в рейде должен включить эту опцию, чтобы предотвратить конфликты.|r"

	L.stance_bar = "%s(СЕЙЧАС:%s)"
	L.battle = "Бой"
	L.berserker = "Берсерк"
	L.defensive = "Защита"

	L.adds_trigger1 = "Удерживайте врата!"
	L.adds_trigger2 = "Сомкнуть ряды!"
	L.adds_trigger3 = "Следующий отряд, вперед!"
	L.adds_trigger4 = "Воины, бегом!"
	L.adds_trigger5 = "Кор'крон, ко мне!"
	L.adds_trigger_extra_wave = "Кор'кронцы... все, кто со мной! Убейте их!"
	L.extra_adds = "Дополнительный отряд"
	L.final_wave = "Последняя волна"
	L.add_wave = "%s (%s): %s"

	L.chain_heal_message = "Ваш фокус читает Цепное исцеление!"

	L.arcane_shock_message = "Ваш фокус читает Чародейское потрясение!"
end

L = BigWigs:NewBossLocale("Malkorok", "ruRU")
if L then
	L.custom_off_energy_marks = "Маркировка Блуждающей энергии"
	L.custom_off_energy_marks_desc = "Чтобы помочь с рассеиванием, на людей с Блуждающей энергией будут поставлены метки {rt1}{rt2}{rt3}{rt4}, требуется быть помощником или лидером.\n|cFFFF0000Только 1 человек в рейде должен включить эту опцию, чтобы предотвратить конфликты.|r"
end

L = BigWigs:NewBossLocale("Spoils of Pandaria", "ruRU")
if L then
L["enable_zone"] = "Хранилище артефактов"
L["start_trigger"] = "Эй, записываем?"
L["win_trigger"] = "Система перезагружается. Не выключать питание, иначе возможен взрыв."

	L.crates = "Ящики"
	L.crates_desc = "Сообщать, сколько ещё нужно энергии и сколько надо открыть больших/средних/малых ящиков."
	L.full_power = "Полная энергия!"
	L.power_left = "%d осталось! (%d/%d/%d)"
end

L = BigWigs:NewBossLocale("Thok the Bloodthirsty", "ruRU")
if L then
L["adds_desc"] = "Предупреждать, когда йети или летучие мыши вступают в бой."
L["cage_opened"] = "Клетка открыта"
L["npc_akolik"] = "Аколик"
L["npc_waterspeaker_gorai"] = "Говорящий с водой Гожай"
end

L = BigWigs:NewBossLocale("Siegecrafter Blackfuse", "ruRU")
if L then
L["assembly_line_items"] = "Предметы (%d): %s"
L["assembly_line_message"] = "Незаконченное оружие (%d)"
L["assembly_line_trigger"] = "На сборочную линию начинает поступать незаконченное оружие."
L["disabled"] = "Отключено"
L["item_deathdealer"] = "Смертоносная"
L["item_laser"] = "Лазер"
L["item_magnet"] = "Магнит"
L["item_mines"] = "Мины"
L["item_missile"] = "Ракета"
L["laser_on_you"] = "Лазер на тебе ПИУ-ПИУ!"
L["overcharged_crawler_mine"] = "Перегретая ползучая мина"
L["shockwave_missile_trigger"] = "Представляю вам прекрасную ударно-волновую турель УТ-03!"
L["shredder_engage_trigger"] = "Приближается автоматический крошшер!"

	L.custom_off_mine_marker = "Маркировка мин"
	L.custom_off_mine_marker_desc = "Ставить метки на мины, для распределения оглушений. (Все метки используются)"
end

L = BigWigs:NewBossLocale("Paragons of the Klaxxi", "ruRU")
if L then
	L.catalyst_match = "Катализатор: |c%sСОВПАДЕНИЕ|r"
	L.you_ate = "Тебя ест Паразит (%d осталось)"
	L.other_ate = "%s ест %sПаразит (%d осталось)"
	L.parasites_up = "%d |4Паразит жив:Паразита живы:Паразитов живы;"
	L.dance = "%s, Танцуем"
	L.prey_message = "Используй Охоту на паразита"
	L.injection_over_soon = "Инъекция заканчивается (%s)!"

	L.one = "Выбор Ийокука: один!"
	L.two = "Выбор Ийокука: два!"
	L.three = "Выбор Ийокука: три!"
	L.four = "Выбор Ийокука: четыре!"
	L.five = "Выбор Ийокука: пять!"

	L.custom_off_edge_marks = "Маркировка луча"
	L.custom_off_edge_marks_desc = "Люди, которые станут лучами на основе расчетов, будут отмечены {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}{rt8}, требуется быть помощником или лидером.\n|cFFFF0000Только 1 человек в рейде должен включить эту опцию, чтобы предотвратить конфликты.|r"
	L.edge_message = "Ты в луче"

	L.custom_off_parasite_marks = "Маркировка Паразита"
	L.custom_off_parasite_marks_desc = "Чтобы помочь с распределением контроля и Охоты, на паразитов будут поставлены метки {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}, требуется быть помощником или лидером.\n|cFFFF0000Только 1 человек в рейде должен включить эту опцию, чтобы предотвратить конфликты.|r"

	L.injection_tank = "Чтение Инъекции"
	L.injection_tank_desc = "Таймер, когда идет чтение Инъекции на текущего танка."
end

L = BigWigs:NewBossLocale("Garrosh Hellscream", "ruRU")
if L then
L["bombardment"] = "Бомбардировка"
L["bombardment_desc"] = "Бомбардировка города и появление горящих луж. Кор'кронская железная звезда появляется только в это время."
L["chain_heal_bar"] = "Фокус: Цепное исцеление"
L["chain_heal_desc"] = "{focus}Лечит союзника, восстанавливая определенный процент от его максимального запаса здоровья, переходя на находящиеся поблизости дружественные цели."
L["chain_heal_message"] = "Ваш фокус читает Цепное исцеление!"
L["clump_check_desc"] = "Каждые 3 секунды, во время Бомбардировки, будет проверяться проходимость, если она обнаружена, появится Кор'кронская железная звезда."
L["clump_check_warning"] = "Проход найден, Звезда на подходе"
L["empowered_message"] = "%s теперь усилено!"
L["farseer_trigger"] = "Исцелите наши раны!"
L["ironstar_impact_desc"] = "Таймер, когда Железная звезда ударится о противоположную стену."
L["ironstar_rolling"] = "Железная звезда катится!"
L["manifest_rage"] = "Проявить ярость"
L["manifest_rage_desc"] = "Когда Гаррош накапливает 100 энергии, он 2 секунды готовится к Проявлению ярости и зачем начинает поддерживать это заклинание. В это время вызываются большие помощники. Прикатите Железную звезду в Гарроша, чтобы прервать чтение."
L["phase_3_end_trigger"] = "Я раскрою вам глаза!"

	L.custom_off_shaman_marker = "Маркировка Предсказателей"
	L.custom_off_shaman_marker_desc = "Чтобы помочь с распределением прерываний, на 'Предсказателей - всадников на волках' будет поставлены метки {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}, требуется быть помощником или лидером.\n|cFFFF0000Только 1 человек в рейде должен включить эту опцию, чтобы предотвратить конфликты.|r\n|cFFADFF2FСОВЕТ: Если вы выбраны для этой задачи, быстро проведите указателем мыши по минам, метки сразу же поставятся.|r"

	L.custom_off_minion_marker = "Маркировка прислужников"
	L.custom_off_minion_marker_desc = "Чтобы помочь отделить прислужников из Усиленного вихря скверны, на них будут поставлены метки {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}, требуется быть помощником или лидером."

	--L.warmup_yell_chat_trigger1 = "It is not too late, Garrosh" -- It is not too late, Garrosh. Lay down the mantle of Warchief. We can end this here, now, with no more bloodshed."
	--L.warmup_yell_chat_trigger2 = "Do you remember nothing of Honor" -- Ha! Do you remember nothing of Honor? Of glory on the battlefield?  You who would parlay with the humans, who allowed warlocks to practice their dark magics right under our feet.  You are weak.
end

