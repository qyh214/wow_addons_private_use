local L = BigWigs:NewBossLocale("Onyxia", "ruRU")
if not L then return end
if L then
	L.phase1_trigger = "Вот это сюрприз."
	L.phase2_trigger = "Эта бессмысленная возня вгоняет меня в тоску. Я сожгу вас всех!"
	L.phase3_trigger = "Похоже, вам требуется преподать еще один урок, смертные!"

	L.deep_breath = "Глубокий вдох"
end

L = BigWigs:NewBossLocale("Archavon the Stone Watcher", "ruRU")
if L then
	L.stomp_message = "Топот - близится Рывок!"
	L.stomp_warning = "Топот через ~5сек!"

	L.charge = "Рывок"
	L.charge_desc = "Предупреждать о Рывках."
end

L = BigWigs:NewBossLocale("Emalon the Storm Watcher", "ruRU")
if L then
	L.overcharge_message = "Служитель бури перегружен!"
	L.overcharge_bar = "Взрыв Служителя бури"

	L.custom_on_overcharge_mark = "Overcharge marker"
	L.custom_on_overcharge_mark_desc = "Place the {rt8} marker on the overcharged minion, requires promoted or leader."
end

L = BigWigs:NewBossLocale("Koralon the Flame Watcher", "ruRU")
if L then
	L.breath_bar = "Дыхание %d"
	L.breath_message = "Скоро дыхание %d!"
end

L = BigWigs:NewBossLocale("Toravon the Ice Watcher", "ruRU")
if L then
	L.whiteout_bar = "Пурга %d"
	L.whiteout_message = "Скоро пурга %d!"

	L.freeze_message = "Заморозка"
end

L = BigWigs:NewBossLocale("Malygos", "ruRU")
if L then
	L.sparks = "Искра мощи"
	L.sparks_desc = "Предупреждать о появлениях Искры мощи."
	L.sparks_message = "Появилась Искра мощи!"
	L.sparks_warning = "Искра мощи через ~5сек!"

	L.sparkbuff = "Яркая искра на Малигосе"
	L.sparkbuff_desc = "Предупреждать когда Малигос получает Яркую искру."
	L.sparkbuff_message = "Малигос получил Яркую искру!"

	L.vortex = "Воронка"
	L.vortex_desc = "Предупреждать о воронках и отображать полосу."
	L.vortex_message = "Воронка!"
	L.vortex_warning = "Воронка через ~5сек!"
	L.vortex_next = "Перезарядка воронки"

	L.breath = "Глубокое дыхание"
	L.breath_desc = "Оповещать кокда Малигос использует Deep Breath во 2ой фазе."
	L.breath_message = "Глубокое дыхание!"
	L.breath_warning = "Глубокое дыхание через ~5сек!"

	L.surge = "Прилив мощи"
	L.surge_desc = "Предупреждать кто получает Прилив мощи."
	L.surge_you = "На ВАС - Прилив мощи!"
	L.surge_trigger = "%s уставился на вас!"

	L.phase = "Фазы"
	L.phase_desc = "Предупреждать о смене фаз."
	L.phase2_warning = "Скоро 2 фаза!"
	L.phase2_trigger = "Я рассчитывал быстро покончить с вами, однако вы оказались более… более стойкими, чем я рассчитывал"
	L.phase2_message = "2 Фаза - Повелители нексуса и Потомоки вечности!"
	L.phase2_end_trigger = "ХВАТИТ! Если ты намерен вернуть себе магию Азерота, ты ее получишь!"
	L.phase3_warning = "Скоро 3 фаза!"
	L.phase3_trigger = "А-а, вот и твои благодетели!"
	L.phase3_message = "3 Фаза!"
end

L = BigWigs:NewBossLocale("Sartharion", "ruRU")
if L then
	L.engage_trigger = "Моя обязанность – оберегать эти яйца, и вы сгорите, прежде чем хоть пальцем тронете их!"
	L.tsunami_trigger = "Лава вокруг |3-1(%s) начинает бурлить!"
	L.twilight_trigger_vesperon = "В Сумраке появляется ученик Весперона!"
	L.twilight_trigger_shadron = "Ученик Шадрона появляется в Зоне сумерек!"

	L.drakes = "Драконы"
	L.drakes_desc = "Предупреждать когда драконы вступят в бой."

	-- Adds
	L.shadron = "Шадрон"
	L.tenebron = "Тенеброн"
	L.vesperon = "Весперон"
	L.lava_blaze = "Пламя лавы" -- NPC 30643
	L.acolyte_shadron = "Служитель Шадрона" -- NPC 31218
	L.acolyte_vesperon = "Служитель Весперона" -- NPC 31219
end
