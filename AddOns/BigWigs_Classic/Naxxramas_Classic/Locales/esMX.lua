local L = BigWigs:NewBossLocale("Gothik the Harvester", "esMX")
if not L then return end
if L then
	L.add_death = "Aviso de muerte de esbirros"
	L.add_death_desc = "Avisa cuando muere un esbirro."

	L.wave = "%d/22: %s"

	L.trainee = "Practicante" -- Unrelenting Trainee NPC 16124
	L.deathKnight = "Caballero de la Muerte" -- Unrelenting Death Knight NPC 16125
	L.rider = "Jinete" -- Unrelenting Rider NPC 16126
end

L = BigWigs:NewBossLocale("Grobbulus", "esMX")
if L then
	L.injection = "Inyección"
end

L = BigWigs:NewBossLocale("Heigan the Unclean", "esMX")
if L then
	--L.teleport_yell_trigger = "The end is upon you."
end

L = BigWigs:NewBossLocale("The Four Horsemen", "esMX")
if L then
	L.mark_desc = "Aviso para marcas."

	L[16062] = "Mograine" -- Surname of Highlord Mograine
	L[16063] = "Zeliek" -- Surname of Sir Zeliek
	L[16064] = "Korth'azz" -- Surname of Thane Korth'azz
	L[16065] = "Blaumeux" -- Surname of Lady Blaumeux
end

L = BigWigs:NewBossLocale("Kel'Thuzad", "esMX")
if L then
	L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "Cámara de Kel'Thuzad"

	--L.engage_yell_trigger = "Minions, servants, soldiers of the cold dark! Obey the call of Kel'Thuzad!"
	--L.stage2_yell_trigger1 = "Pray for mercy!"
	--L.stage2_yell_trigger2 = "Scream your dying breath!"
	--L.stage2_yell_trigger3 = "The end is upon you!"
	--L.stage3_yell_trigger = "Master, I require aid!"
	--L.adds_yell_trigger = "Very well. Warriors of the frozen wastes, rise up! I command you to fight, kill and die for your master! Let none survive!"
end

L = BigWigs:NewBossLocale("Noth the Plaguebringer", "esMX")
if L then
	--L.adds_yell_trigger = "Rise, my soldiers" -- Rise, my soldiers! Rise and fight once more!
end

L = BigWigs:NewBossLocale("Instructor Razuvious", "esMX")
if L then
	L.understudy = "Suplente Caballero de la Muerte"
end

L = BigWigs:NewBossLocale("Thaddius", "esMX")
if L then
	L[15929] = "Stalagg"
	L[15930] = "Feugen"

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
