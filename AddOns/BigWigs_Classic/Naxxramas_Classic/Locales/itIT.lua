local L = BigWigs:NewBossLocale("Gothik the Harvester", "itIT")
if not L then return end
if L then
	--L.add_death = "Add Death Alert"
	--L.add_death_desc = "Alerts when an add dies."

	--L.wave = "%d/22: %s"

	L.trainee = "Allievo" -- Unrelenting Trainee NPC 16124
	L.deathKnight = "Cavaliere della Morte" -- Unrelenting Death Knight NPC 16125
	L.rider = "Cavaliere" -- Unrelenting Rider NPC 16126
end

L = BigWigs:NewBossLocale("Grobbulus", "itIT")
if L then
	L.injection = "Iniezione"
end

L = BigWigs:NewBossLocale("Heigan the Unclean", "itIT")
if L then
	--L.teleport_yell_trigger = "The end is upon you."
end

L = BigWigs:NewBossLocale("The Four Horsemen", "itIT")
if L then
	--L.mark_desc = "Warn for marks."

	L[16062] = "Mograine" -- Surname of Highlord Mograine
	L[16063] = "Zeliek" -- Surname of Sir Zeliek
	L[16064] = "Korth'azz" -- Surname of Thane Korth'azz
	L[16065] = "Blaumeux" -- Surname of Lady Blaumeux
end

L = BigWigs:NewBossLocale("Kel'Thuzad", "itIT")
if L then
	L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "Sala di Kel'Thuzad"

	--L.engage_yell_trigger = "Minions, servants, soldiers of the cold dark! Obey the call of Kel'Thuzad!"
	--L.stage2_yell_trigger1 = "Pray for mercy!"
	--L.stage2_yell_trigger2 = "Scream your dying breath!"
	--L.stage2_yell_trigger3 = "The end is upon you!"
	--L.stage3_yell_trigger = "Master, I require aid!"
	--L.adds_yell_trigger = "Very well. Warriors of the frozen wastes, rise up! I command you to fight, kill and die for your master! Let none survive!"
end

L = BigWigs:NewBossLocale("Noth the Plaguebringer", "itIT")
if L then
	--L.adds_yell_trigger = "Rise, my soldiers" -- Rise, my soldiers! Rise and fight once more!
end

L = BigWigs:NewBossLocale("Instructor Razuvious", "itIT")
if L then
	L.understudy = "Deathknight Understudy"
end

L = BigWigs:NewBossLocale("Thaddius", "itIT")
if L then
	L[15929] = "Stalagg"
	L[15930] = "Feugen"

	--L.stage2_yell_trigger1 = "Eat... your... bones..."
	--L.stage2_yell_trigger2 = "Break... you!!"
	--L.stage2_yell_trigger3 = "Kill..."

	--L.add_death_emote_trigger = "%s dies."
	--L.overload_emote_trigger = "%s overloads!"
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
