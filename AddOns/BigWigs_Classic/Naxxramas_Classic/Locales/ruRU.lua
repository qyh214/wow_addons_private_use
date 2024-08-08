local L = BigWigs:NewBossLocale("Gothik the Harvester", "ruRU")
if not L then return end
if L then
	L.add_death = "Оповещать смерть помощников"
	L.add_death_desc = "Сообщать о смерти помощников."

	L.wave = "%d/22: %s"

	L.trainee = "Новобранец" -- Unrelenting Trainee NPC 16124
	L.deathKnight = "Рыцарь Смерти" -- Unrelenting Death Knight NPC 16125
	L.rider = "Всадник" -- Unrelenting Rider NPC 16126
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
	L.mark_desc = "Предупреждать о знаках."

	L[16062] = "Могрейн" -- Surname of Highlord Mograine
	L[16063] = "Зелиек" -- Surname of Sir Zeliek
	L[16064] = "Кортазз" -- Surname of Thane Korth'azz
	L[16065] = "Бломе" -- Surname of Lady Blaumeux
end

L = BigWigs:NewBossLocale("Kel'Thuzad", "ruRU")
if L then
	L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "Зал Кел'Тузада"

	L.engage_yell_trigger = "Соратники слуги солдаты холодной тьмы! Повинуйтесь зову Кел'Тузада!"
	L.stage2_yell_trigger1 = "Молите о пощаде!"
	L.stage2_yell_trigger2 = "Кричите! Кричите изо всех сил!"
	L.stage2_yell_trigger3 = "Вы уже мертвы!"
	L.stage3_yell_trigger = "Господин мне нужна помощь!"
	L.adds_yell_trigger = "Хорошо. Воины ледяных пустошей восстаньте! Повелеваю вам сражаться убивать и умирать во имя своего повелителя! Не щадить никого!"
end

L = BigWigs:NewBossLocale("Noth the Plaguebringer", "ruRU")
if L then
	L.adds_yell_trigger = "Встаньте мои воины" -- Встаньте мои воины! Встаньте и сражайтесь вновь!
end

L = BigWigs:NewBossLocale("Instructor Razuvious", "ruRU")
if L then
	L.understudy = "Ученик рыцаря смерти"
end

L = BigWigs:NewBossLocale("Thaddius", "ruRU")
if L then
	L[15929] = "Сталагг"
	L[15930] = "Фойген"

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
