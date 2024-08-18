local L = BigWigs:NewBossLocale("The Fallen Protectors", "esES") or BigWigs:NewBossLocale("The Fallen Protectors", "esMX")
if not L then return end
if L then
L["defile_you"] = "Suelo mancillado debajo de ti"
L["defile_you_desc"] = "Advertencia cuando Suelo mancillado esté debajo de ti"
L["inferno_self"] = "Golpe de Infierno en ti"
L["inferno_self_bar"] = "¡Vas a explotar!"
L["inferno_self_desc"] = "Cuenta atrás especial cuando tengas Golpe de Infierno"
L["intermission_desc"] = "Advertir cuando los jefes usen Medidas Desesperadas."
L["no_meditative_field"] = "¡No estás en la burbuja!"

	L.custom_off_bane_marks = "Palabra de las Sombras: terror marcador"
	L.custom_off_bane_marks_desc = "Para ayudar a asignar los dispels, marca inicialmente a la gente que tiene Palabra de las Sombras: terror en ellos con {rt1}{rt2}{rt3}{rt4}{rt5} (en este orden, puede que no se usen todas las marcas), requiere ayudante o líder."
end

L = BigWigs:NewBossLocale("Norushen", "esES") or BigWigs:NewBossLocale("Norushen", "esMX")
if L then
L["big_add"] = "Esbirro grande (%d)"
L["big_add_killed"] = "Esbirro grande muerto (%d)"
L["big_adds"] = "Esbirros grandes"
L["big_adds_desc"] = "Alertas para la aparición de esbirros grandes y sus muertes."
L["warmup_trigger"] = "Muy bien, crearé un campo para mantener aislada vuestra corrupción."
end

L = BigWigs:NewBossLocale("Sha of Pride", "esES") or BigWigs:NewBossLocale("Sha of Pride", "esMX")
if L then
L["projection_green_arrow"] = "FLECHA VERDE"
L["titan_pride"] = "Titán+Orgullo: %s"

	L.custom_off_titan_mark = "Marcador de Ofrenda de los titanes"
	L.custom_off_titan_mark_desc = "Marca la gente que tiene Ofrenda de los titanes con {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}, requiere ayudante o líder.\n|cFFFF0000Solo 1 persona de la raid debería tener activada esta opción para prevenir conflictos con las marcas.|r"

	L.custom_off_fragment_mark = "Marcador de Fragmento corrupto"
	L.custom_off_fragment_mark_desc = "Marca los Fragmentos corruptos con {rt8}{rt7}, requiere ayudante o líder.\n|cFFFF0000Solo 1 persona de la raid deberia tener activada esta opción para prevenir conflictos con las marcas.|r"
end

L = BigWigs:NewBossLocale("Galakras", "esES") or BigWigs:NewBossLocale("Galakras", "esMX")
if L then
L["adds_desc"] = "Temporizadores cuando un nuevo grupo de esbirros entren en el combate."
L["demolisher_message"] = "Demoledor"
L["drakes"] = "Protodracos"
L["north_tower"] = "Torre norte"
L["north_tower_trigger"] = "¡La puerta de la torre norte está abierta!"
L["south_tower"] = "Torre sur"
L["south_tower_trigger"] = "¡La puerta de la torre sur está abierta!"
L["start_trigger_alliance"] = "¡Bien hecho! ¡Grupos de desembarco, formad! ¡Infantería, al frente!"
L["start_trigger_horde"] = "Bien hecho. La primera brigada a tomado tierra."
L["tower_defender"] = "Defensor de la torre"
L["towers"] = "Torres"
L["towers_desc"] = "Advertencia cuando las torres se abran."
L["warlord_zaela"] = "Señora de la guerra Zaela"

	L.custom_off_shaman_marker = "Marcador del Chamán"
	L.custom_off_shaman_marker_desc = "Para ayudar con las interrupciones, marca los Chamanes de mareas Faucedraco con {rt1}{rt2}{rt3}{rt4}{rt5}, requiere ayudante o líder.\n|cFFFF0000Solo 1 persona de la raid debería tener esta opción activada para prevenir conflictos con las marcas.|r\n|cFFADFF2FCONSEJO: Si la raid te ha elegido para que la actives, mover rápidamente el ratón por encima de los chamanes es la manera más rápida de marcarlos.|r"
end

L = BigWigs:NewBossLocale("Iron Juggernaut", "esES") or BigWigs:NewBossLocale("Iron Juggernaut", "esMX")
if L then
	L.custom_off_mine_marks = "Marcador de Minas"
	L.custom_off_mine_marks_desc = "Para ayudar con las asignaciones de las minas, marca las Minas reptadoras con {rt1}{rt2}{rt3}, requiere ayudante o líder.\n|cFFFF0000Solo 1 persona de la raid debería tener activada esta opción para prevenir coflictos con las marcas.|r\n|cFFADFF2FCONSEJO: Si la raid te ha elegido para que la actives, mover rápidamente el ratón por encima de todas las minas es la manera más rápida de marcarlas.|r"
end

L = BigWigs:NewBossLocale("Kor'kron Dark Shaman", "esES") or BigWigs:NewBossLocale("Kor'kron Dark Shaman", "esMX")
if L then
L["blobs"] = "Burbujas"

	L.custom_off_mist_marks = "Marcador de Niebla tóxica"
	L.custom_off_mist_marks_desc = "Para ayudar con las tareas de sanación, marca la gente que tiene Niebla tóxica con {rt1}{rt2}{rt3}{rt4}{rt5}, requiere ayudante o líder.\n|cFFFF0000Solo 1 persona de la raid debería tener activada esta opción para prevenir conflictos con las marcas.|r"
end

L = BigWigs:NewBossLocale("General Nazgrim", "esES") or BigWigs:NewBossLocale("General Nazgrim", "esMX")
if L then
	L.custom_off_bonecracker_marks = "Marcador de Partehuesos"
	L.custom_off_bonecracker_marks_desc = "Para ayudar en las tareas de sanación, marca la gente que tiene Partehuesos con {rt1}{rt2}{rt3}{rt4}{rt5}, requiere ayudante o líder.\n|cFFFF0000Solo 1 persona de la raid debería tener activada esta opción para prevenir conflictos con las marcas.|r"

	L.stance_bar = "%s(AHORA:%s)"
	-- shorten stances so they fit on the bars
	L.battle = "Batalla"
	L.berserker = "Rabiosa"
	L.defensive = "Defensiva"

	L.adds_trigger1 = "¡Defended la puerta!"
	L.adds_trigger2 = "¡Reunid a las tropas!"
	L.adds_trigger3 = "¡Siguiente escuadrón, al frente!"
	L.adds_trigger4 = "¡Guerreros, paso ligero!"
	L.adds_trigger5 = "¡Kor'kron, conmigo!"
	L.adds_trigger_extra_wave = "¡Todos los Kor'kron a mi comando, mátenlos ya!"
	L.extra_adds = "Adds extra"
	L.final_wave = "Oleada final"
	L.add_wave = "%s (%s): %s"

	L.chain_heal_message = "¡Tu foco está casteando Sanación en cadena!"

	L.arcane_shock_message = "¡Tu foco está casteando Choque Arcano!"
end

L = BigWigs:NewBossLocale("Malkorok", "esES") or BigWigs:NewBossLocale("Malkorok", "esMX")
if L then
	L.custom_off_energy_marks = "Marcador de Energía desplazada"
	L.custom_off_energy_marks_desc = "Para ayudar a dispelear, marca la gente que tiene Energía desplazada en ellos con {rt1}{rt2}{rt3}{rt4}, requiere ayudante o líder.\n|cFFFF0000SSólo 1 persona en la raid debería tener activada esta opción para evitar conflictos con las marcas.|r"
end

L = BigWigs:NewBossLocale("Spoils of Pandaria", "esES") or BigWigs:NewBossLocale("Spoils of Pandaria", "esMX")
if L then
L["enable_zone"] = "Depósito de Artefactos"
L["start_trigger"] = "¿Estamos grabando?"
L["win_trigger"] = "Reiniciando sistema. No lo apague si no quiere que el artefacto explote."

	L.crates = "Cajas"
	L.crates_desc = "Mensajes para saber cuanto poder necesitas y cuantas cajas grandes/medianas/pequeñas necesitarás para lograrlo."
	L.full_power = "¡Poder máximo!"
	L.power_left = "%d restantes! (%d/%d/%d)"
end

L = BigWigs:NewBossLocale("Thok the Bloodthirsty", "esES") or BigWigs:NewBossLocale("Thok the Bloodthirsty", "esMX")
if L then
L["adds_desc"] = "Alarmas para cuando el Yeti o los murciélagos se unan al combate."
L["cage_opened"] = "Jaula abierta"
L["npc_akolik"] = "Akolik"
L["npc_waterspeaker_gorai"] = "Orador del agua Gorai"
end

L = BigWigs:NewBossLocale("Siegecrafter Blackfuse", "esES") or BigWigs:NewBossLocale("Siegecrafter Blackfuse", "esMX")
if L then
L["assembly_line_items"] = "Objetos (%d): %s"
L["assembly_line_message"] = "Armas sin terminar (%d)"
L["assembly_line_trigger"] = "La cadena de montaje empieza a sacar armas sin terminar."
L["disabled"] = "Desactivado"
L["item_deathdealer"] = "Mortífero"
L["item_laser"] = "Laser"
L["item_magnet"] = "Imán"
L["item_mines"] = "Minas"
L["item_missile"] = "Misiles"
L["laser_on_you"] = "¡Laser en ti PEW PEW!"
L["overcharged_crawler_mine"] = "Mina reptadora sobrecargada."
L["shockwave_missile_trigger"] = "¡He aquí la hermosa torreta de misiles de ondas de choque ST-03!"
L["shredder_engage_trigger"] = "¡Una trituradora automática se acerca!"

	L.custom_off_mine_marker = "Marcador de minas"
	L.custom_off_mine_marker_desc = "Marca las minas para asignar aturdimientos. (Se usan todas las marcas)"
end

L = BigWigs:NewBossLocale("Paragons of the Klaxxi", "esES") or BigWigs:NewBossLocale("Paragons of the Klaxxi", "esMX")
if L then
	L.catalyst_match = "Catalizador: |c%sTE CORRESPONDE|r" -- might not be best for colorblind?
	L.you_ate = "Te comiste un Parásito (%d restantes)"
	L.other_ate = "%s se comió un %sParásito (%d restantes)"
	L.parasites_up = "%d |4Parásito activo:Parásitos activos;"
	L.dance = "%s, Baile"
	L.prey_message = "Usa Depredar en parásito"
	L.injection_over_soon = "¡Inyección acabará pronto (%s)!"

	L.one = "¡Iyyokuk elige: Uno!"
	L.two = "¡Iyyokuk elige: Dos!"
	L.three = "¡Iyyokuk elige: Tres!"
	L.four = "¡Iyyokuk elige: Cuatro!"
	L.five = "¡Iyyokuk elige: Cinco!"

	L.custom_off_edge_marks = "Marcador del límite"
	L.custom_off_edge_marks_desc = "Marca los jugadores que serán los límites según los cálculos con {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}{rt8}, requiere ayudante o líder.\n|cFFFF0000Solo 1 persona de la raid debería tener activa esta opción para prevenir conflictos con las marcas.|r"
	L.edge_message = "¡Estás en el límite!"

	L.custom_off_parasite_marks = "Marcador de Parásito"
	L.custom_off_parasite_marks_desc = "Marca los parásitos para controlar y asignar víctimas con {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}, requiere ayudante o líder.\n|cFFFF0000Solo 1 persona de la raid debería tener activa esta opción para prevenir conflictos con las marcas.|r"

	L.injection_tank = "Inyección (casteo)"
	L.injection_tank_desc = "Barra de tiempo para cuando Inyección es casteada por su tanque actual."
end

L = BigWigs:NewBossLocale("Garrosh Hellscream", "esES") or BigWigs:NewBossLocale("Garrosh Hellscream", "esMX")
if L then
L["bombardment"] = "Bombardeo"
L["bombardment_desc"] = "Bombardea Ventormenta, dejando manchas de fuego en el suelo. La Estrella de hierro Kor'kron solo puede aparecer durante el bombardeo."
L["chain_heal_bar"] = "Foco: Sanación en cadena"
L["chain_heal_desc"] = "{focus}Cura un objetivo amistoso el 40% de su vida máxima, extendiéndose a los objetivos amistosos cercanos."
L["chain_heal_message"] = "¡Tu foco está casteando Sanación en cadena!"
L["clump_check_desc"] = "Comprueba cada 3 segundos durante el bombardeo los jugadores agrupados, si un grupo es encontrado por una Estrella de hierro Kor'kron aparecerá."
L["clump_check_warning"] = "Grupo encontrado, Estrella pronto"
L["empowered_message"] = "¡%s está potenciado!"
L["farseer_trigger"] = "¡Clarividentes, sanad nuestras heridas!"
L["ironstar_impact_desc"] = "Un temporizador para cuando la Estrella de hierro choque con la pared en el otro lado."
L["ironstar_rolling"] = "¡Estrella de hierro rodando!"
L["manifest_rage"] = "Manifiesto de ira"
L["manifest_rage_desc"] = "Cuando Garrosh alcanza 100 de energia el pre-casteará Manifiesto de Ira durante 2 segundos, entonces lo canalizará. Mientras es canalizado invocará adds grandes. Pon la Estrella de hierro en Garrosh para stunearlo y así interrumpir su casteo."
L["phase_3_end_trigger"] = "¿Creéis que habéis ganado?"

	L.custom_off_shaman_marker = "Marcador de Clarividentes"
	L.custom_off_shaman_marker_desc = "Para ayudar con las interrupciones, marca los Clarividente jinete de lobos con {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}, requiere ayudante o líder.\n|cFFFF0000Solo 1 persona de la raid debería tener activa esta opción para prevenir conflictos con las marcas.|r\n|cFFADFF2FCONSEJO: Si la raid te elige para que la actives, mover rápidamente el ratón por encima de los clarividentes es la manera más rápida de marcarlos.|r"

	L.custom_off_minion_marker = "Marcador de esbirros"
	L.custom_off_minion_marker_desc = "Para ayudar a separarse de los adds del Torbellino de corrupción potenciado, márcalos con {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}, requiere ayudante o líder."

	--L.warmup_yell_chat_trigger1 = "It is not too late, Garrosh" -- It is not too late, Garrosh. Lay down the mantle of Warchief. We can end this here, now, with no more bloodshed."
	--L.warmup_yell_chat_trigger2 = "Do you remember nothing of Honor" -- Ha! Do you remember nothing of Honor? Of glory on the battlefield?  You who would parlay with the humans, who allowed warlocks to practice their dark magics right under our feet.  You are weak.
end

