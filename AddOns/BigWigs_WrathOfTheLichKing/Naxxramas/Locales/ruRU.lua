local L = BigWigs:NewBossLocale("Anub'Rekhan", "ruRU")
if not L then return end
if L then
	L.add = "Некрорахнид-стражник"
	L.locust = "Саранча"
end

L = BigWigs:NewBossLocale("Grand Widow Faerlina", "ruRU")
if L then
	L.silencewarn = "Безмолвие! Задержка ярости!"
	L.silencewarn5sec = "Безмолвие закончится через 5 секунд"
	L.silence = "Безмолвие"
end

L = BigWigs:NewBossLocale("Gothik the Harvester", "ruRU")
if L then
	L.phase1_trigger1 = "Глупо было искать свою смерть."
	L.phase1_trigger2 = "Я очень долго ждал. Положите свою душу в мой комбайн и будем вам дерево с золотыми монетами." -- Curse of Tongues CHECK THIS
	L.phase2_trigger = "Я ждал слишком долго. Сейчас вы предстанете пред ликом Жнеца душ."

	L.add = "Появление помощников"
	L.add_desc = "Сообщать о появлении помощников"

	L.add_death = "Оповещать смерть помощников"
	L.add_death_desc = "Сообщать о смерти помощников."

	L.riderdiewarn = "Всадник мёртв!"
	L.dkdiewarn = "Рыцарь смерти мёртв!"

	L.wave = "%d/23: %s"

	L.trawarn = "Ученик через 3 секунды"
	L.dkwarn = "Рыцарь Смерти через 3 секунды"
	L.riderwarn = "Всадник через 3 секунды"

	L.trabar = "Ученик (%d)"
	L.dkbar = "Рыцарь Смерти (%d)"
	L.riderbar = "Всадник (%d)"

	--L.gate = "Gate Open!"
	--L.gatebar = "Gate opens"

	L.phase_soon = "Готик появится через 10 секунд"

	L.engage_message = "Готик вступает в бой! 4:30 до входа в комнату."
end

L = BigWigs:NewBossLocale("Grobbulus", "ruRU")
if L then
	L.injection = "Укол"
end

L = BigWigs:NewBossLocale("Heigan the Unclean", "ruRU")
if L then
	L.teleport_yell_trigger = "Вам конец."
end

L = BigWigs:NewBossLocale("The Four Horsemen", "ruRU")
if L then
	L.mark = "Знак"
	L.mark_desc = "Предупреждать о знаках."

	L.engage_message = "Четыре Всадника вступили в бой!"
end

L = BigWigs:NewBossLocale("Kel'Thuzad Naxxramas", "ruRU")
if L then
	L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "Зал Кел'Тузада"

	L.phase1_trigger = "Соратники, слуги, солдаты холодной тьмы! Повинуйтесь зову Кел'Тузада!"
	L.phase2_trigger1 = "Молите о пощаде!"
	L.phase2_trigger2 = "Кричите! Кричите изо всех сил!"
	L.phase2_trigger3 = "Вы уже мертвы!"
	L.phase3_trigger = "Господин, мне нужна помощь!"
	L.guardians_trigger = "Хорошо. Воины ледяных пустошей, восстаньте! Повелеваю вам сражаться, убивать и умирать во имя своего повелителя! Не щадить никого!"

	L.phase2_warning = "Фаза 2 - Кел'Тузад просыпается!"
	L.phase2_bar = "Кел'Тузад активен!"

	L.phase3_warning = "Фаза 3 - защитники через ~15 секунд!"

	L.guardians = "Появление стражей"
	L.guardians_desc = "Сообщать о появлении стражей ледяной короны в третьей фазе."
	L.guardians_warning = "Стражи появятся через 15 секунд!"
	L.guardians_bar = "Появляются стражи!"

	L.engage_message = "Бой с Кел'Тузадом начинается!"
end

L = BigWigs:NewBossLocale("Loatheb", "ruRU")
if L then
	L.doomtime_bar = "Рок каждые 15 секунд"
	L.doomtime_now = "Рок теперь накладывается каждые 15 секунд!"

	L.spore_warn = "Спора (%d)"
end

L = BigWigs:NewBossLocale("Noth the Plaguebringer", "ruRU")
if L then
	L.adds_yell_trigger = "Встаньте мои воины" -- Встаньте мои воины! Встаньте и сражайтесь вновь!
end

L = BigWigs:NewBossLocale("Maexxna", "ruRU")
if L then
	L.webspraywarn30sec = "Паутина через 10 секунд"
	L.webspraywarn20sec = "Паутина! 10 секунд до появления пауков!"
	L.webspraywarn10sec = "Пауки! 10 секунд до паутины!"
	L.webspraywarn5sec = "Паутина через 5 секунд!"

	L.enragewarn = "Бешенство - ХЛЮП ХЛЮП ХЛЮП!"
	L.enragesoonwarn = "Скоро бешенство"

	L.cocoons = "Коконы"
	L.spiders = "Пауки"
end

L = BigWigs:NewBossLocale("Sapphiron", "ruRU")
if L then
	L.airphase_trigger = "%s взмывает в воздух!"
	L.deepbreath_trigger = "%s глубоко вдыхает."

	-- L.air_phase = "Air Phase"
	-- L.ground_phase = "Ground Phase"

	L.ice_bomb = "Ледяная бомба"
	L.ice_bomb_warning = "Появляется ледяная бомба!"
	L.ice_bomb_bar = "Приземляется ледяная бомба!"

	L.icebolt_say = "Я в глыбе!"
end

L = BigWigs:NewBossLocale("Instructor Razuvious", "ruRU")
if L then
	L.understudy = "Ученик рыцаря смерти"

	L.shout_warning = "Разрушительный крик через 5 сек!"
	L.taunt_warning = "Провокация закончится через 5 сек!"
	L.shieldwall_warning = "Преграда из костей закончится через 5 сек!"
end

L = BigWigs:NewBossLocale("Thaddius", "ruRU")
if L then
	L[15929] = "Сталагг"
	L[15930] = "Фойген"

	L.stage1_yell_trigger1 = "Сталагг тебя раздавит!"
	L.stage1_yell_trigger2 = "На корм хозяину!"

	L.stage2_yell_trigger1 = "Отведайте... своих... костей..."
	L.stage2_yell_trigger2 = "Растерзаю!!!"
	L.stage2_yell_trigger3 = "Убей..."

	L.add_death_emote_trigger = "%s умирает."
	L.overload_emote_trigger = "%s перезагружается!"
	--L.add_revive_emote_trigger = "%s is jolted back to life!"

	--L.polarity_extras = "Additional alerts for Polarity Shift positioning"

	--L.custom_off_select_charge_position = "First position"
	--L.custom_off_select_charge_position_desc = "Where to move to after the first Polarity Shift."
	--L.custom_off_select_charge_position_value1 = "|cffff2020Negative (-)|r are LEFT, |cff2020ffPositive (+)|r are RIGHT"
	--L.custom_off_select_charge_position_value2 = "|cff2020ffPositive (+)|r are LEFT, |cffff2020Negative (-)|r are RIGHT"

	--L.custom_off_select_charge_movement = "Movement"
	--L.custom_off_select_charge_movement_desc = "The movement strategy your group uses."
	--L.custom_off_select_charge_movement_value1 = "Run |cff20ff20THROUGH|r the boss"
	--L.custom_off_select_charge_movement_value2 = "Run |cff20ff20CLOCKWISE|r around the boss"
	--L.custom_off_select_charge_movement_value3 = "Run |cff20ff20COUNTER-CLOCKWISE|r around the boss"
	--L.custom_off_select_charge_movement_value4 = "Four camps 1: Polarity changed moves |cff20ff20RIGHT|r, same polarity moves |cff20ff20LEFT|r"
	--L.custom_off_select_charge_movement_value5 = "Four camps 2: Polarity changed moves |cff20ff20LEFT|r, same polarity moves |cff20ff20RIGHT|r"

	--L.custom_off_charge_graphic = "Graphical arrow"
	--L.custom_off_charge_graphic_desc = "Show an arrow graphic."
	--L.custom_off_charge_text = "Text arrows"
	--L.custom_off_charge_text_desc = "Show an additional message."
	--L.custom_off_charge_voice = "Voice alert"
	--L.custom_off_charge_voice_desc = "Play a voice alert."

	--Translate these to get locale sound files!
	--L.left = "<--- GO LEFT <--- GO LEFT <---"
	--L.right = "---> GO RIGHT ---> GO RIGHT --->"
	--L.swap = "^^^^ SWITCH SIDES ^^^^ SWITCH SIDES ^^^^"
	--L.stay = "==== DON'T MOVE ==== DON'T MOVE ===="

	--L.chat_message = "The Thaddius mod supports showing you directional arrows and playing voices. Open the options to configure them."
end
