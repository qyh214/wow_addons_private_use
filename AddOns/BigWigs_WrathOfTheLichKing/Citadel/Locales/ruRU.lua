local L = BigWigs:NewBossLocale("Lord Marrowgar", "ruRU")
if not L then return end
if L then
	L.bone_spike = "Костяной шип" -- NPC ID 36619
end

L = BigWigs:NewBossLocale("Lady Deathwhisper", "ruRU")
if L then
	L.touch = "Прикосновение"
	L.deformed_fanatic = "Кособокий фанатик" -- NPC ID 38135
	L.empowered_adherent = "Могущественный последователь" -- NPC ID 38136
end

L = BigWigs:NewBossLocale("Icecrown Gunship Battle", "ruRU")
if L then
	L.adds_trigger_alliance = "Разрушители, сержанты, в бой!"
	L.adds_trigger_horde = "Пехота, сержанты, в бой!"

	L.mage = "Маг"
	L.mage_desc = "Предупредит когда появится маг и заморозит пушки."
	-- Alliance: We're taking hull damage, get a battle-mage out here to shut down those cannons!
	-- Horde: We're taking hull damage, get a sorcerer out here to shut down those cannons!
	--L.mage_yell_trigger = "taking hull damage"

	L.warmup_trigger_alliance = "Запускайте двигатели"
	L.warmup_trigger_horde = "Воспряньте, сыны и дочери Орды"

	L.disable_trigger_alliance = "братья и сестры"
	L.disable_trigger_horde = "Вперед к Королю-Личу"
end

L = BigWigs:NewBossLocale("Deathbringer Saurfang", "ruRU")
if L then
	L.blood_beast = "Кровавое чудовище" --  NPC ID 38508

	L.warmup_alliance = "Тогда выдвигаемся! Быст..."
	L.warmup_horde = "Кор'крон, выдвигайтесь! Герои, будьте начеку. Плеть только что..."
end

L = BigWigs:NewBossLocale("Blood Prince Council", "ruRU")
if L then
	L.switch_message = "Смена цели: %s"
	L.switch_bar = "~Следующая смена цели"

	L.empowered_flames = "Жаркое пламя"

	L.empowered_shock_message = "Могучий вихрь!"
	L.regular_shock_message = "Вихрь"
	L.shock_bar = "~Следующий вихрь"

	L.iconprince = "Помечать активного принца"
	L.iconprince_desc = "Пометить черепом активного принца с полосой здоровья."

	L.prison_message = "Темница Тьмы x%d!"
end

L = BigWigs:NewBossLocale("Blood-Queen Lana'thel", "ruRU")
if L then
	L.engage_trigger = "Это было... неразумное... решение."

	L.shadow = "Тени"
	L.shadow_message = "Тени"
	L.shadow_bar = "~Тени"

	L.feed_message = "Скоро пора кормиться!"

	L.pact_message = "Пакт Омраченных"
	L.pact_bar = "~Пакт Омраченных"

	L.phase_message = "Скоро воздушная фаза!"
	L.phase1_bar = "Возврат на землю"
	L.phase2_bar = "Воздушная фаза"
end

L = BigWigs:NewBossLocale("Festergut", "ruRU")
if L then
	L.engage_trigger = "Повеселимся?"

	L.inhale_bar = "~Следующее вдыхание %d"
	L.blight_warning = "Едкая гниль через ~5сек!"
	L.ball_message = "Скоро комок гадости!"
end

L = BigWigs:NewBossLocale("Professor Putricide", "ruRU")
if L then
	L.engage_trigger = "Отличные новости, народ!"

	L.phase = "Фазы"
	L.phase_desc = "Предупреждает о смене фаз."
	L.phase_warning = "Скоро %d-я фаза!"
	L.phase_bar = "Следующая фаза"

	L.ball_bar = "Следующий бросок вязкой гадости"
	L.ball_say = "Бросок вязкой гадости на МНЕ!"

	L.experiment_message = "Скоро появится слизнюк!"
	L.experiment_heroic_message = "Скоро появятся слизнюки!"
	L.experiment_bar = "Следующий слизнюк"
	L.blight_message = "Газовое облако"
	L.violation_message = "Зеленый слизнюк"

	L.gasbomb_bar = "Следующие желтые газовые бомбы"
	L.gasbomb_message = "Желтые бомбы!"
end

L = BigWigs:NewBossLocale("Rotface", "ruRU")
if L then
	L.engage_trigger = "УУИИИИИИ!"

	L.infection_message = "Инфекция"

	L.ooze = "Сливание слизнюков"
	L.ooze_desc = "Предупреждает когда слизнюки сливаются."
	L.ooze_message = "Нестабильный слизнюк %dx"

	L.spray_bar = "Следующие брызги"
end

L = BigWigs:NewBossLocale("Valithria Dreamwalker", "ruRU")
if L then
	L.engage_trigger = "Чужаки ворвались во внутренние покои. Уничтожьте зеленого дракона!"

	L.portal = "Портал к кошмарам"
	L.portal_desc = "Сообщать когда Валитрия открывает портал."
	L.portal_message = "Портал!"
	L.portal_bar = "Скоро портал"
	L.portalcd_message = "Портал %d, через 14 сек!"
	L.portalcd_bar = "Следующий портал %d"
	L.portal_trigger = "Я открыла портал в Изумрудный Сон. Там вы найдете спасение, герои..."

	L.suppresser = "Появление Подавителей"
	L.suppresser_desc = "Сообщать когда будут появляться Подавители."
	L.suppresser_message = "~Подавители"

	L.blazing = "Исторгающий пламя скелет"
	L.blazing_desc = "|cffff0000Предполагаемый|r таймер появления Исторгающего пламя скелета. Этот таймер может быть неточным, используйте его только в качестве приблизительного ориентира."
	L.blazing_warning = "Скоро Исторгающий пламя скелет!"
end

L = BigWigs:NewBossLocale("Sindragosa", "ruRU")
if L then
	L.engage_trigger = "Глупцы, зачем вы сюда явились!"

	L.phase2 = "Фаза 2"
	L.phase2_desc = "Сообщать, когда Синдрагоса перейдет во вторую фазу на 35% жизней."
	L.phase2_trigger = "А теперь почувствуйте всю мощь господина и погрузитесь в отчаяние!"
	L.phase2_message = "Фаза 2!"

	L.airphase = "Воздушная фаза"
	L.airphase_desc = "Сообщать когда Синдрагоса отрывается от земли."
	L.airphase_trigger = "Здесь ваше вторжение и окончится! Никто не уцелеет."
	L.airphase_message = "Воздушная фаза!"
	L.airphase_bar = "Следующая воздушная фаза."

	L.boom_message = "Взрыв!"
	L.boom_bar = "Взрыв"

	L.instability_message = "Неустойчивость x%d!"
	L.chilled_message = "Обжигающий холод x%d!"
	L.buffet_message = "Таинственная энергия x%d!"
	L.buffet_cd = "~Таинственная энергия"
end

L = BigWigs:NewBossLocale("The Lich King", "ruRU")
if L then
	L.warmup_trigger = "Неужели прибыли наконец хваленые силы Света?"
	L.engage_trigger = "Я оставлю тебя в живых, чтобы ты увидел финал."

	L.horror_message = "Шаркающий ужас"
	L.horror_bar = "~Следующий Ужас"

	L.valkyr_message = "Валь'кира"
	L.valkyr_bar = "Следующая Валь'кира"
	L.valkyrhug_message = "Валь'кира схватила"

	L.cave_phase = "Фаза пещеры"
	L.last_phase_bar = "Последняя фаза"

	--L.frenzy_bar = "%s frenzies!"
	--L.frenzy_survive_message = "%s will survive after plague"
	--L.frenzy_message = "Add frenzied!"
	--L.frenzy_soon_message = "5sec to frenzy!"

	--L.custom_on_valkyr_marker = "Val'kyr marker"
	--L.custom_on_valkyr_marker_desc = "Mark the Val'kyr with {rt8}{rt7}{rt6}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r\n|cFFADFF2FTIP: If the raid has chosen you to turn this on, quickly mousing over the Val'kyr is the fastest way to mark them.|r"
end

L = BigWigs:NewBossLocale("Icecrown Citadel Trash", "ruRU")
if L then
	L.deathbound_ward = "Заклятый страж"
	L.deathspeaker_high_priest = "Вестник смерти - верховный жрец" -- NPC ID 36829
	L.putricide_dogs = "Прелесть & Вонючка"
end
