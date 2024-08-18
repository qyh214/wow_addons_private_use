local L = BigWigs:NewBossLocale("Anub'Rekhan", "deDE")
if not L then return end
if L then
	L.add = "Gruftwache"
	L.locust = "Heuschrecke"
end

L = BigWigs:NewBossLocale("Grand Widow Faerlina", "deDE")
if L then
	L.silencewarn = "Stille! Raserei verzögert!"
	L.silencewarn5sec = "Stille endet in 5 sek!"
	L.silence = "Stille"
end

L = BigWigs:NewBossLocale("Gothik the Harvester", "deDE")
if L then
	L.phase1_trigger1 = "Ihr Narren habt euren eigenen Untergang heraufbeschworen."
	L.phase1_trigger2 = "Maz Azgala veni kamil toralar Naztheros zennshinagas." -- Curse of Tongues
	L.phase2_trigger = "Ich habe lange genug gewartet. Stellt euch dem Seelenjäger."

	L.add = "Adds"
	L.add_desc = "Warnungen und Timer für die Adds."

	L.add_death = "Tod eines Adds"
	L.add_death_desc = "Warnt, wenn ein Add stirbt."

	L.riderdiewarn = "Reiter tot!"
	L.dkdiewarn = "Todesritter tot!"

	L.wave = "%d/23: %s"

	L.trawarn = "Lehrlinge in 3 sek!"
	L.dkwarn = "Todesritter in 3 sek!"
	L.riderwarn = "Reiter in 3 sek!"

	L.trabar = "Lehrling (%d)"
	L.dkbar = "Todesritter (%d)"
	L.riderbar = "Reiter (%d)"

	--L.gate = "Gate Open!"
	--L.gatebar = "Gate opens"

	L.phase_soon = "Gothik im Raum in 10 sek!"

	L.engage_message = "Gothik der Ernter angegriffen!"
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
	L.mark = "Male"
	L.mark_desc = "Warnungen und Timer für die Male."

	L.engage_message = "Die Vier Reiter angegriffen!"
end

L = BigWigs:NewBossLocale("Kel'Thuzad Naxxramas", "deDE")
if L then
	L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "Kel'Thuzads Gemach"

	L.phase1_trigger = "Lakaien, Diener, Soldaten der eisigen Finsternis! Folgt dem Ruf von Kel'Thuzad!"
	L.phase2_trigger1 = "Betet um Gnade!"
	L.phase2_trigger2 = "Schreiend werdet ihr diese Welt verlassen!"
	L.phase2_trigger3 = "Euer Ende ist gekommen!"
	L.phase3_trigger = "Meister, ich benötige Beistand."
	L.guardians_trigger = "Wohlan, Krieger der Eisigen Weiten, erhebt euch! Ich befehle euch für euren Meister zu kämpfen, zu töten und zu sterben! Keiner darf überleben!"

	L.phase2_warning = "Phase 2 - Kel'Thuzad kommt!"
	L.phase2_bar = "Kel'Thuzad aktiv"

	L.phase3_warning = "Phase 3 - Wächter in ~15 sek!"

	L.guardians = "Wächter"
	L.guardians_desc = "Warnt vor den Wächtern von Eiskrone in Phase 3."
	L.guardians_warning = "Wächter in ~10 sek!"
	L.guardians_bar = "Wächter kommen"

	L.engage_message = "Kel'Thuzad gestartet!"
end

L = BigWigs:NewBossLocale("Loatheb", "deDE")
if L then
	L.doomtime_bar = "Schicksal alle 15 sek"
	L.doomtime_now = "Unausweichliches Schicksal nun alle 15 sek!"

	L.spore_warn = "Spore (%d)"
end

L = BigWigs:NewBossLocale("Noth the Plaguebringer", "deDE")
if L then
	L.adds_yell_trigger = "Erhebt euch, Soldaten" -- Erhebt euch, Soldaten! Erhebt euch und kämpft erneut!
end

L = BigWigs:NewBossLocale("Maexxna", "deDE")
if L then
	L.webspraywarn30sec = "Fangnetz in 10 sek!"
	L.webspraywarn20sec = "Fangnetz! Spinnen in 10 sek!"
	L.webspraywarn10sec = "Spinnen! Gespinstschauer in 10 sek!"
	L.webspraywarn5sec = "GESPINSTSCHAUER in 5 sek!"

	L.enragewarn = "Raserei!"
	L.enragesoonwarn = "Raserei bald!"

	L.cocoons = "Fangnetz"
	L.spiders = "Spinnen"
end

L = BigWigs:NewBossLocale("Sapphiron", "deDE")
if L then
	L.airphase_trigger = "Saphiron erhebt sich in die Lüfte!"
	L.deepbreath_trigger = "%s holt tief Luft."

	--L.air_phase = "Air Phase"
	--L.ground_phase = "Ground Phase"

	L.ice_bomb = "Frostatem"
	L.ice_bomb_warning = "Frostatem kommt!"
	L.ice_bomb_bar = "Frostatem landet!"

	L.icebolt_say = "Ich bin ein Eisblock!"
end

L = BigWigs:NewBossLocale("Instructor Razuvious", "deDE")
if L then
	L.understudy = "Reservist der Todesritter"

	L.shout_warning = "Unterbrechender Schrei in 5 sek!"
	L.taunt_warning = "Spott bereit in 5 sek!"
	L.shieldwall_warning = "Knochenbarriere weg in 5 sek!"
end

L = BigWigs:NewBossLocale("Thaddius", "deDE")
if L then
	L[15929] = "Stalagg"
	L[15930] = "Feugen"

	L.stage1_yell_trigger1 = "Stalagg zerquetschen!"
	L.stage1_yell_trigger2 = "Verfüttere euch an Meister!"

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
