local L = BigWigs:NewBossLocale("Auriaya", "ruRU")
if not L then return end
if L then
	L.swarm_message = "Cтража"

	L.defender = "Дикий защитник"
	L.defender_desc = "Сообщать о жизни Дикого защитника."
	L.defender_message = "Защитник (%d/9)!"
end

L = BigWigs:NewBossLocale("Freya", "ruRU")
if L then
	L.wave = "Волны"
	L.wave_desc = "Сообщать о волнах."
	L.wave_bar = "Следующая волна"
	L.conservator_trigger = "Эонар, твоей прислужнице нужна помощь!"
	L.detonate_trigger = "Вас захлестнет сила стихий!"
	L.elementals_trigger = "Помогите мне, дети мои!"
	L.tree_trigger = "|cFF00FFFFДар Хранительницы жизни|r начинает расти!"
	L.conservator_message = "Древний опекун!"
	L.detonate_message = "Взрывные плеточники!"
	L.elementals_message = "Элементали!"

	L.tree = "Дар Эонара"
	L.tree_desc = "Сообщать когда Фрейа призывает Дар Эонара."
	L.tree_message = "Появление Дара Эонара!"

	L.fury_message = "Гнев"

	L.tremor_warning = "Скоро Дрожание земли!"
	L.tremor_bar = "~Дрожание земли"
	L.energy_message = "Нестабильная энергия на ВАС!"
	L.sunbeam_message = "Луч солнца!"
	L.sunbeam_bar = "~следующий Луч солнца"
end

L = BigWigs:NewBossLocale("Hodir", "ruRU")
if L then
	L.hardmode = "Сложный режим"
	L.hardmode_desc = "Отображать таймер сложного режима."
end

L = BigWigs:NewBossLocale("Ignis the Furnace Master", "ruRU")
if L then
	L.brittle_message = "Создание подверглось Ломкости!"
end

L = BigWigs:NewBossLocale("The Iron Council", "ruRU")
if L then
	L.stormcaller_brundir = "Буревестник Брундир"
	L.steelbreaker = "Сталелом"
	L.runemaster_molgeim = "Мастер рун Молгейм"

	L.summoning_message = "Руна призыва - приход Элементалей!"

	L.chased_other = "Преследует |3-3(%s)!"
	L.chased_you = "ВАС преследуют!"
end

L = BigWigs:NewBossLocale("Kologarn", "ruRU")
if L then
	L.arm = "Уничтожение рук"
	L.arm_desc = "Сообщать о смерти левой и правой руки."
	L.left_dies = "Левая рука уничтожена"
	L.right_dies = "Правая рука уничтожена"
	L.left_wipe_bar = "Восcтaновление левой руки"
	L.right_wipe_bar = "Восcтaновление правой руки"

	L.eyebeam = "Сосредоточенный взгляд"
	L.eyebeam_desc = "Сообщать кто попал под воздействие Сосредоточенный взгляд."
end

L = BigWigs:NewBossLocale("Mimiron", "ruRU")
if L then
	L.phase = "Фазы"
	L.phase_desc = "Сообщать о смене фаз."
	L.engage_warning = "1ая фаза"
	L.engage_trigger = "^У нас мало времени, друзья!"
	L.phase2_warning = "Наступает 2-ая фаза"
	L.phase2_trigger = "^ПРЕВОСХОДНО! Просто восхитительный результат!"
	L.phase3_warning = "Наступает 3-ая фаза"
	L.phase3_trigger = "^Спасибо, друзья!"
	L.phase4_warning = "Наступает 4-ая фаза"
	L.phase4_trigger = "^Фаза предварительной проверки завершена."
	L.phase_bar = "%d фаза"

	L.hardmode_trigger = "^Так, зачем вы это сделали?"

	L.plasma_warning = "Применяется Взрыв плазмы!"
	L.plasma_soon = "Скоро Взрыв плазмы!"
	L.plasma_bar = "Взрыв плазмы"

	L.shock_next = "Следующий Шоковый удар!"

	L.laser_soon = "Вращение!"
	L.laser_bar = "Обстрел"

	L.magnetic_message = "Магнитное ядро! БОМБИТЕ!"

	L.suppressant_warning = "Подавитель пламени!"

	L.fbomb_bar = "~Ледяная бомба"

	L.bomb_message = "Появился Бомбот!"
end

L = BigWigs:NewBossLocale("Razorscale", "ruRU")
if L then
	L.ground_trigger = "Быстрее! Сейчас она снова взлетит!"
	L.ground_message = "Острокрылая на привязи!"
	L.air_message = "Взлет!"

	L.harpoon = "Гарпунная Пушка"
	L.harpoon_desc = "Объявлять Гарпунные Пушки."
	L.harpoon_message = "Пушка (%d) готова!"
	L.harpoon_trigger = "Гарпунная пушка готова!"
	L.harpoon_nextbar = "Гарпун (%d)"
end

L = BigWigs:NewBossLocale("Thorim", "ruRU")
if L then
	L.phase2_trigger = "Незваные гости! Вы заплатите за то, что посмели вмешаться... Погодите, вы..."
	L.phase3_trigger = "Бесстыжие выскочки, вы решили бросить вызов мне лично? Я сокрушу вас всех!"

	L.hardmode = "Таймеры сложного режима"
	L.hardmode_desc = "Отображения таймера для сложного режима."
	L.hardmode_warning = "Завершение сложного режима"

	L.barrier_message = "Колосс под Рунической преградой!"

	L.charge_message = "Разряд: x%d"
	L.charge_bar = "Разряд %d"
end

L = BigWigs:NewBossLocale("General Vezax", "ruRU")
if L then
	L.surge_bar = "Наплыв %d"

	L.animus = "Саронитовый враг"
	L.animus_desc = "Сообщать о появлении саронитового врага."
	L.animus_trigger = "Саронитовые испарения яростно клубятся и струятся, принимая пугающую форму!"
	L.animus_message = "Появился саронитовый враг!"

	L.vapor = "Саронитовые пары"
	L.vapor_desc = "Сообщать о появлении саронитовых паров."
	L.vapor_message = "Саронитовые пары (%d)!"
	L.vapor_bar = "Пары"
	L.vapor_trigger = "Поблизости начинают возникать саронитовые испарения!"

	L.vaporstack = "Стаки испарения"
	L.vaporstack_desc = "Сообщать, когда у вас уже 5 стаков саронитового испарения."
	L.vaporstack_message = "Испарения x%d!"

	L.crash_say = "Сокрушение"

	L.mark_message = "Метка"
end

L = BigWigs:NewBossLocale("XT-002 Deconstructor", "ruRU")
if L then
	L.lightbomb_other = "Взрыв"
end

L = BigWigs:NewBossLocale("Yogg-Saron", "ruRU")
if L then
	L.engage_trigger = "^Скоро мы сразимся с главарем этих извергов!"
	L.phase2_trigger = "^Я – это сон наяву"
	L.phase3_trigger = "^Взгляните в истинное лицо"

	L.portal = "Портал"
	L.portal_desc = "Сообщать о портале."
	L.portal_message = "Порталы открыты!"
	L.portal_bar = "Следующий портал"

	L.fervor_message = "Рвение на |3-5(%s)!"

	L.sanity_message = "Вы теряете рассудок!"

	L.weakened = "Оглушение"
	L.weakened_desc = "Сообщать, когда Йогг-Сарон производит оглушение."
	L.weakened_message = "%s оглушен!"

	L.madness_warning = "Помешательство через 10 сек!"
	L.malady_message = "Болезнь" -- short for Malady of the Mind (63830)

	L.tentacle = "Тяжелое щупальце"
	L.tentacle_desc = "Сообщать о появлении тяжелого щупальца."
	L.tentacle_message = "Щупальце %d!"

	--L.small_tentacles = "Small Tentacles"
	--L.small_tentacles_desc = "Warn for Corruptor Tentacle and Constrictor Tentacle spawns."

	L.link_warning = "У вас схожее мышление!"

	L.guardian_message = "Страж %d!"

	L.roar_warning = "Крик через 5 сек!"
	L.roar_bar = "Следущий крик"
end
