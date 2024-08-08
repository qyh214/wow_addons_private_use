local L = BigWigs:NewBossLocale("Gothik the Harvester", "deDE")
if not L then return end
if L then
	L.add_death = "Tod eines Adds"
	L.add_death_desc = "Warnt, wenn ein Add stirbt."

	L.wave = "%d/22: %s"

	L.trainee = "Lehrling" -- Unrelenting Trainee NPC 16124
	L.deathKnight = "Todesritter" -- Unrelenting Death Knight NPC 16125
	L.rider = "Reiter" -- Unrelenting Rider NPC 16126
end

L = BigWigs:NewBossLocale("Grobbulus", "deDE")
if L then
	L.injection = "Injektion"
end

L = BigWigs:NewBossLocale("Heigan the Unclean", "deDE")
if L then
	L.teleport_yell_trigger = "Euer Ende naht."
end

L = BigWigs:NewBossLocale("The Four Horsemen", "deDE")
if L then
	L.mark_desc = "Warnungen und Timer für die Male."

	L[16062] = "Mograine" -- Surname of Highlord Mograine
	L[16063] = "Zeliek" -- Surname of Sir Zeliek
	L[16064] = "Korth'azz" -- Surname of Thane Korth'azz
	L[16065] = "Blaumeux" -- Surname of Lady Blaumeux
end

L = BigWigs:NewBossLocale("Kel'Thuzad", "deDE")
if L then
	L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "Kel'Thuzads Gemächer"

	L.engage_yell_trigger = "Lakaien, Diener, Soldaten der eisigen Finsternis! Folgt dem Ruf von Kel'Thuzad!"
	L.stage2_yell_trigger1 = "Betet um Gnade!"
	L.stage2_yell_trigger2 = "Schreiend werdet ihr diese Welt verlassen!"
	L.stage2_yell_trigger3 = "Euer Ende ist gekommen!"
	L.stage3_yell_trigger = "Meister, ich benötige Beistand."
	L.adds_yell_trigger = "Wohlan, Krieger der Eisigen Weiten, erhebt euch! Ich befehle euch für euren Meister zu kämpfen, zu töten und zu sterben! Keiner darf überleben!"
end

L = BigWigs:NewBossLocale("Noth the Plaguebringer", "deDE")
if L then
	L.adds_yell_trigger = "Erhebt euch, Soldaten" -- Erhebt euch, Soldaten! Erhebt euch und kämpft erneut!
end

L = BigWigs:NewBossLocale("Instructor Razuvious", "deDE")
if L then
	L.understudy = "Reservist der Todesritter"
end

L = BigWigs:NewBossLocale("Thaddius", "deDE")
if L then
	L[15929] = "Stalagg"
	L[15930] = "Feugen"

	L.stage2_yell_trigger1 = "Eure... Knochen... zermalmen..."
	L.stage2_yell_trigger2 = "Euch... zerquetschen!"
	L.stage2_yell_trigger3 = "Töten..."

	L.add_death_emote_trigger = "%s stirbt."
	L.overload_emote_trigger = "%s überlädt!"
	--L.add_revive_emote_trigger = "%s is jolted back to life!"

	L.polarity_extras = "Zusätzliche Warnungen für Polaritätsveränderung-Positionierung"

	L.custom_off_select_charge_position = "Erste Position"
	L.custom_off_select_charge_position_desc = "Einzunehmende Position nach erster Polaritätsveränderung."
	L.custom_off_select_charge_position_value1 = "|cffff2020Negative (-)|r sind LINKS, |cff2020ffPositive (+)|r sind RECHTS"
	L.custom_off_select_charge_position_value2 = "|cff2020ffPositive (+)|r sind LINKS, |cffff2020Negative (-)|r sind RECHTS"

	L.custom_off_select_charge_movement = "Bewegung"
	L.custom_off_select_charge_movement_desc = "Die Bewegungsstrategie, welche die Gruppe nutzt."
	L.custom_off_select_charge_movement_value1 = "Laufe |cff20ff20DURCH|r den Boss"
	L.custom_off_select_charge_movement_value2 = "Laufe |cff20ff20IM UHRZEIGERSINN|r um den Boss"
	L.custom_off_select_charge_movement_value3 = "Laufe |cff20ff20GEGEN UHRZEIGERSINN|r um den Boss"
	L.custom_off_select_charge_movement_value4 = "Vier Camps 1: Geänderte Polarität läuft |cff20ff20RECHTS|r, gleiche Polaritäte läuft |cff20ff20LINKS|r"
	L.custom_off_select_charge_movement_value5 = "Vier Camps 2: Geänderte Polarität läuft |cff20ff20LINKS|r, gleiche Polaritäte läuft |cff20ff20RECHTS|r"

	L.custom_off_charge_graphic = "Grafischer Pfeil"
	L.custom_off_charge_graphic_desc = "Zeigt eine Pfeilgrafik an."
	L.custom_off_charge_text = "Textpfeile"
	L.custom_off_charge_text_desc = "Zeigt eine zusätzliche Nachricht."
	L.custom_off_charge_voice = "Sprachwarnung"
	L.custom_off_charge_voice_desc = "Spielt eine Sprachwarnung ab."

	L.left = "<--- Nach Links <--- Nach Links <---"
	L.right = "---> Nach Rechts ---> Nach Rechts --->"
	L.swap = "^^^^ Seitenwechseln ^^^^ Seitenwechseln ^^^^"
	L.stay = "==== Nicht Bewegen ==== Nicht Bewegen ===="

	--L.chat_message = "The Thaddius mod supports showing you directional arrows and playing voices. Open the options to configure them."
end
