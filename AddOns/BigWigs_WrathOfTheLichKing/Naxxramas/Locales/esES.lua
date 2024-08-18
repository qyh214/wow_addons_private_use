local L = BigWigs:NewBossLocale("Anub'Rekhan", "esES")
if not L then return end
if L then
	L.add = "Guardia de la cripta"
	L.locust = "Langosta"
end

L = BigWigs:NewBossLocale("Grand Widow Faerlina", "esES")
if L then
	--L.silencewarn = "Silenced!"
	--L.silencewarn5sec = "Silence ends in 5 sec"
	L.silence = "Silencio"
end

L = BigWigs:NewBossLocale("Gothik the Harvester", "esES")
if L then
	--L.phase1_trigger1 = "Foolishly you have sought your own demise."
	--L.phase1_trigger2 = "Teamanare shi rikk mannor rikk lok karkun" -- Curse of Tongues
	--L.phase2_trigger = "I have waited long enough. Now you face the harvester of souls."

	--L.add = "Add Warnings"
	--L.add_desc = "Warnings for add waves."

	--L.add_death = "Add Death Alert"
	--L.add_death_desc = "Alerts when an add dies."

	--L.riderdiewarn = "Rider dead!"
	--L.dkdiewarn = "Death Knight dead!"

	--L.wave = "%d/23: %s"

	--L.trawarn = "Trainees in 3 sec"
	--L.dkwarn = "Death Knights in 3 sec"
	--L.riderwarn = "Rider in 3 sec"

	--L.trabar = "Trainee (%d)"
	--L.dkbar = "Death Knight (%d)"
	--L.riderbar = "Rider (%d)"

	--L.gate = "Gate Open!"
	--L.gatebar = "Gate opens"

	--L.phase_soon = "Gothik Incoming in 10 sec"

	--L.engage_message = "Gothik the Harvester engaged!"
end

L = BigWigs:NewBossLocale("Grobbulus", "esES")
if L then
	--L.injection = "Injection"
end

L = BigWigs:NewBossLocale("Heigan the Unclean", "esES")
if L then
	--L.teleport_yell_trigger = "The end is upon you."
end

L = BigWigs:NewBossLocale("The Four Horsemen", "esES")
if L then
	--L.mark = "Mark"
	--L.mark_desc = "Warn for marks."

	--L.engage_message = "The Four Horsemen engaged!"
end

L = BigWigs:NewBossLocale("Kel'Thuzad Naxxramas", "esES")
if L then
	--L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "Kel'Thuzad's Chamber"

	--L.phase1_trigger = "Minions, servants, soldiers of the cold dark! Obey the call of Kel'Thuzad!"
	--L.phase2_trigger1 = "Pray for mercy!"
	--L.phase2_trigger2 = "Scream your dying breath!"
	--L.phase2_trigger3 = "The end is upon you!"
	--L.phase3_trigger = "Master, I require aid!"
	--L.guardians_trigger = "Very well. Warriors of the frozen wastes, rise up! I command you to fight, kill and die for your master! Let none survive!"

	--L.phase2_warning = "Phase 2 - Kel'Thuzad Incoming!"
	--L.phase2_bar = "Kel'Thuzad active"

	--L.phase3_warning = "Stage 3 - Guardians in ~15 sec!"

	--L.guardians = "Guardian Spawns"
	--L.guardians_desc = "Warn for incoming Icecrown Guardians in phase 3."
	--L.guardians_icon = "inv_trinket_naxxramas04"
	--L.guardians_warning = "Guardians incoming in ~10sec!"
	--L.guardians_bar = "Guardians incoming!"

	--L.engage_message = "Kel'Thuzad encounter started!"
end

L = BigWigs:NewBossLocale("Loatheb", "esES")
if L then
	--L.doomtime_bar = "Doom every 15 sec"
	--L.doomtime_now = "Doom now happens every 15 sec!"

	--L.spore_warn = "Spore (%d)"
end

L = BigWigs:NewBossLocale("Maexxna", "esES")
if L then
	--L.webspraywarn30sec = "Cocoons in 10 sec"
	--L.webspraywarn20sec = "Cocoons! Spiders in 10 sec!"
	--L.webspraywarn10sec = "Spiders! Spray in 10 sec!"
	--L.webspraywarn5sec = "WEB SPRAY in 5 seconds!"

	--L.enragewarn = "Frenzy - SQUISH SQUISH SQUISH!"
	--L.enragesoonwarn = "Frenzy Soon - Bugsquatters out!"

	--L.cocoons = "Cocoons"
	--L.spiders = "Spiders"
end

L = BigWigs:NewBossLocale("Noth the Plaguebringer", "esES")
if L then
	L.adds_yell_trigger = "¡Levantaos, soldados míos!" -- Rise, my soldiers! Rise and fight once more!
end

L = BigWigs:NewBossLocale("Instructor Razuvious", "esES")
if L then
	L.understudy = "Suplente Caballero de la Muerte"

	--L.shout_warning = "Disrupting Shout in 5 sec!"
	--L.taunt_warning = "Taunt ready in 5 sec!"
	--L.shieldwall_warning = "Barrier gone in 5 sec!"
end

L = BigWigs:NewBossLocale("Sapphiron", "esES")
if L then
	--L.airphase_trigger = "Sapphiron lifts off into the air!"
	--L.deepbreath_trigger = "%s takes a deep breath."

	--L.air_phase = "Air Phase"
	--L.ground_phase = "Ground Phase"

	--L.ice_bomb = "Ice Bomb"
	--L.ice_bomb_warning = "Ice Bomb Incoming!"
	--L.ice_bomb_bar = "Ice Bomb Lands!"

	--L.icebolt_say = "I'm a Block!"
end

L = BigWigs:NewBossLocale("Thaddius", "esES")
if L then
	L[15929] = "Stalagg"
	L[15930] = "Feugen"

	L.stage1_yell_trigger1 = "¡Stalagg aplasta!"
	--L.stage1_yell_trigger2 = "Feed you to master!"

	--L.stage2_yell_trigger1 = "Eat... your... bones..."
	--L.stage2_yell_trigger2 = "Break... you!!"
	--L.stage2_yell_trigger3 = "Kill..."

	--L.add_death_emote_trigger = "%s dies."
	L.overload_emote_trigger = "¡%s se sobrecarga!"
	--L.add_revive_emote_trigger = "%s is jolted back to life!"

	L.polarity_extras = "Avisos adicionales para el posicionamiento del cambio de polaridad"

	L.custom_off_select_charge_position = "Primera posición"
	L.custom_off_select_charge_position_desc = "Posicionamiento después del primer cambio de polaridad."
	L.custom_off_select_charge_position_value1 = "|cffff2020Carga negativa (-)|r a la IZQUIERDA, |cff2020ffCarga positiva (+)|r a la DERECHA"
	L.custom_off_select_charge_position_value2 = "|cff2020ffCarga positiva (+)|r a la IZQUIERDA, |cffff2020Carga negativa (-)|r a la DERECHA"

	L.custom_off_select_charge_movement = "Movimiento"
	L.custom_off_select_charge_movement_desc = "La estrategia de movimiento que se utiliza tu grupo."
	L.custom_off_select_charge_movement_value1 = "Corre |cff20ff20A TRAVÉS|r del jefe"
	L.custom_off_select_charge_movement_value2 = "Corre |cff20ff20EN SENTIDO HORARIO|r alrededor del jefe."
	L.custom_off_select_charge_movement_value3 = "Corre |cff20ff20EN SENTIDO ANTIHORARIO|r alrededor del jefe."
	L.custom_off_select_charge_movement_value4 = "Cuatro grupos 1: Cambio de polaridad hacia la |cff20ff20DERECHA|r, misma polaridad hacia la |cff20ff20IZQUIERDA|r."
	L.custom_off_select_charge_movement_value5 = "Cuatro grupos 2: Cambio de polaridad hacia la |cff20ff20IZQUIERDA|r, misma polaridad hacia la |cff20ff20DERECHA|r."

	L.custom_off_charge_graphic = "Flecha gráfica"
	L.custom_off_charge_graphic_desc = "Muestra una flecha gráfica."
	L.custom_off_charge_text = "Flecha de texto"
	L.custom_off_charge_text_desc = "Muestra un mensaje adicional."
	L.custom_off_charge_voice = "Alerta de voz"
	L.custom_off_charge_voice_desc = "Reproduce una alerta de voz."

	--Translate these to get locale sound files!
	L.left = "<--- VE A LA IZQUIERDA <--- VE A LA IZQUIERDA <---"
	L.right = "---> VE A LA DERECHA ---> VE A LA DERECHA --->"
	L.swap = "^^^^ CAMBIA DE LADO ^^^^ CAMBIA DE LADO ^^^^"
	L.stay = "==== NO TE MUEVES ==== NO TE MUEVES ===="

	L.chat_message = "El módulo de Thaddius admite mostrar flechas direccionales y reproducir voces. Abre las opciones para configurarlas."
end
