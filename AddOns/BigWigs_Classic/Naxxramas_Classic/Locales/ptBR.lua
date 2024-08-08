local L = BigWigs:NewBossLocale("Gothik the Harvester", "ptBR")
if not L then return end
if L then
	L.add_death = "Aviso de morte do lacaio"
	L.add_death_desc = "Avisa quando um lacaio morre."

	L.wave = "%d/22: %s"

	L.trainee = "Aprendiz" -- Unrelenting Trainee NPC 16124
	L.deathKnight = "Cavaleiro da Morte" -- Unrelenting Death Knight NPC 16125
	L.rider = "Cavalgante" -- Unrelenting Rider NPC 16126
end

L = BigWigs:NewBossLocale("Grobbulus", "ptBR")
if L then
	L.injection = "Injeção"
end

L = BigWigs:NewBossLocale("Heigan the Unclean", "ptBR")
if L then
	--L.teleport_yell_trigger = "The end is upon you."
end

L = BigWigs:NewBossLocale("The Four Horsemen", "ptBR")
if L then
	L.mark_desc = "Avisa sobre marcas."

	L[16062] = "Mograine" -- Surname of Highlord Mograine
	L[16063] = "Zeliek" -- Surname of Sir Zeliek
	L[16064] = "Korth'azz" -- Surname of Thane Korth'azz
	L[16065] = "Blaumeux" -- Surname of Lady Blaumeux
end

L = BigWigs:NewBossLocale("Kel'Thuzad", "ptBR")
if L then
	L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "Câmara de Kel'Thuzad"

	--L.engage_yell_trigger = "Minions, servants, soldiers of the cold dark! Obey the call of Kel'Thuzad!"
	--L.stage2_yell_trigger1 = "Pray for mercy!"
	--L.stage2_yell_trigger2 = "Scream your dying breath!"
	--L.stage2_yell_trigger3 = "The end is upon you!"
	--L.stage3_yell_trigger = "Master, I require aid!"
	--L.adds_yell_trigger = "Very well. Warriors of the frozen wastes, rise up! I command you to fight, kill and die for your master! Let none survive!"
end

L = BigWigs:NewBossLocale("Noth the Plaguebringer", "ptBR")
if L then
	--L.adds_yell_trigger = "Rise, my soldiers" -- Rise, my soldiers! Rise and fight once more!
end

L = BigWigs:NewBossLocale("Instructor Razuvious", "ptBR")
if L then
	L.understudy = "Cavaleiro da Morte Aspirante"
end

L = BigWigs:NewBossLocale("Thaddius", "ptBR")
if L then
	L[15929] = "Stalagg"
	L[15930] = "Feugen"

	--L.stage2_yell_trigger1 = "Eat... your... bones..."
	--L.stage2_yell_trigger2 = "Break... you!!"
	--L.stage2_yell_trigger3 = "Kill..."

	--L.add_death_emote_trigger = "%s dies."
	--L.overload_emote_trigger = "%s overloads!"
	--L.add_revive_emote_trigger = "%s is jolted back to life!"

	L.polarity_extras = "Avisos adicionais para posicionamento da mudança de polaridade"

	L.custom_off_select_charge_position = "Primeira posição"
	L.custom_off_select_charge_position_desc = "Onde mover-se após a primeira mudança de polaridade."
	L.custom_off_select_charge_position_value1 = "|cffff2020Carga Negativa (-)|r à ESQUERDA, |cff2020ffCarga Positiva (+)|r à DIREITA"
	L.custom_off_select_charge_position_value2 = "|cff2020ffCarga Positiva (+)|r à ESQUERDA, |cffff2020Carga Negativa (-)|r à DIREITA"

	L.custom_off_select_charge_movement = "Movimento"
	L.custom_off_select_charge_movement_desc = "A estratégia de movimento que seu grupo utiliza."
	L.custom_off_select_charge_movement_value1 = "Correr |cff20ff20ATRAVÉS|r do chefe"
	L.custom_off_select_charge_movement_value2 = "Correr no |cff20ff20SENTIDO HORÁRIO|r ao redor do chefe"
	L.custom_off_select_charge_movement_value3 = "Correr no |cff20ff20SENTIDO ANTI-HORÁRIO|r ao redor do chefe"
	L.custom_off_select_charge_movement_value4 = "Quatro grupos 1: Mudança de polaridade à |cff20ff20DIREITA|r, mesma polaridade à |cff20ff20ESQUERDA|r"
	L.custom_off_select_charge_movement_value5 = "Quatro grupos 2: Mudança de polaridade à |cff20ff20ESQUERDA|r, mesma polaridade à |cff20ff20DIREITA|r"

	L.custom_off_charge_graphic = "Seta gráfica"
	L.custom_off_charge_graphic_desc = "Mostra uma seta gráfica."
	L.custom_off_charge_text = "Setas de texto"
	L.custom_off_charge_text_desc = "Mostra uma mensagem adicional."
	L.custom_off_charge_voice = "Alerta de voz"
	L.custom_off_charge_voice_desc = "Reproduz um alerta de voz."

	--Translate these to get locale sound files!
	L.left = "<--- VÁ PARA A ESQUERDA <--- VÁ PARA A ESQUERDA <---"
	L.right = "---> VÁ PARA A DIREITA ---> VÁ PARA A DIREITA --->"
	L.swap = "^^^^ TROQUE DE LADO ^^^^ TROQUE DE LADO ^^^^"
	L.stay = "==== NÃO SE MOVA ==== NÃO SE MOVA ===="

	L.chat_message = "O mod Thaddius suporta mostrar setas direcionais e reproduzir vozes. Abra as opções para configurá-las."
end
