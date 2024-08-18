local L = BigWigs:NewBossLocale("Anub'Rekhan", "frFR")
if not L then return end
if L then
	L.add = "Gardien des cryptes"
	L.locust = "Locuste"
end

L = BigWigs:NewBossLocale("Grand Widow Faerlina", "frFR")
if L then
	L.silencewarn = "Réduite au silence !"
	L.silencewarn5sec = "Fin du silence dans 5 sec."
	L.silence = "Silence"
end

L = BigWigs:NewBossLocale("Gothik the Harvester", "frFR")
if L then
	L.phase1_trigger1 = "Dans votre folie, vous avez provoqué votre propre mort."
	L.phase1_trigger2 = "Teamanare shi rikk mannor rikk lok karkun" -- Curse of Tongues
	L.phase2_trigger = "J'ai attendu assez longtemps. Maintenant, vous affrontez le moissonneur d'âmes."

	L.add = "Arrivée des renforts"
	L.add_desc = "Prévient quand des renforts se joignent au combat."

	L.add_death = "Mort des renforts"
	L.add_death_desc = "Prévient quand un des renforts meurt."

	L.riderdiewarn = "Cavalier éliminé !"
	L.dkdiewarn = "Chevalier éliminé !"

	L.wave = "%d/23 : %s"

	L.trawarn = "Jeune recrue dans 3 sec."
	L.dkwarn = "Chevalier de la mort dans 3 sec."
	L.riderwarn = "Cavalier dans 3 sec."

	L.trabar = "Jeune recrue (%d)"
	L.dkbar = "Chevalier de la mort (%d)"
	L.riderbar = "Cavalier (%d)"

	--L.gate = "Gate Open!"
	--L.gatebar = "Gate opens"

	L.phase_soon = "Arrivée de Gothik dans 10 sec."

	L.engage_message = "Gothik le moissonneur engagé !"
end

L = BigWigs:NewBossLocale("Grobbulus", "frFR")
if L then
	L.injection = "Injection"
end

L = BigWigs:NewBossLocale("Heigan the Unclean", "frFR")
if L then
	L.teleport_yell_trigger = "Votre fin est venue."
end

L = BigWigs:NewBossLocale("The Four Horsemen", "frFR")
if L then
	L.mark = "Marque"
	L.mark_desc = "Prévient de l'arrivée des marques."

	L.engage_message = "Les 4 cavaliers engagés !"
end

L = BigWigs:NewBossLocale("Kel'Thuzad Naxxramas", "frFR")
if L then
	L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "Appartements de Kel'Thuzad"

	L.phase1_trigger = "Serviteurs, valets et soldats des ténèbres glaciales ! Répondez à l'appel de Kel'Thuzad !"
	L.phase2_trigger1 = "Faites vos prières !"
	L.phase2_trigger2 = "Hurlez et expirez !"
	L.phase2_trigger3 = "Votre fin est proche !"
	L.phase3_trigger = "Maître, j'ai besoin d'aide !"
	L.guardians_trigger = "Très bien. Guerriers des terres gelées, relevez-vous ! Je vous ordonne de combattre, de tuer et de mourir pour votre maître ! N'épargnez personne !"

	L.phase2_warning = "Phase 2 - Arrivée de Kel'Thuzad !"
	L.phase2_bar = "Kel'Thuzad actif !"

	L.phase3_warning = "Phase 3 - Gardiens dans ~15 sec. !"

	L.guardians = "Apparition des gardiens"
	L.guardians_desc = "Prévient de l'arrivée des gardiens en phase 3."
	L.guardians_warning = "Arrivée des gardiens dans ~10 sec. !"
	L.guardians_bar = "Arrivée des gardiens !"

	L.engage_message = "Kel'Thuzad engagé !"
end

L = BigWigs:NewBossLocale("Loatheb", "frFR")
if L then
	L.doomtime_bar = "Malé. toutes les 15 sec."
	L.doomtime_now = "La Malédiction inévitable arrive désormais toutes les 15 sec. !"

	L.spore_warn = "Spore (%d)"
end

L = BigWigs:NewBossLocale("Noth the Plaguebringer", "frFR")
if L then
	L.adds_yell_trigger = "Levez-vous, soldats" -- Levez-vous, soldats ! Levez-vous et combattez une fois encore !
end

L = BigWigs:NewBossLocale("Maexxna", "frFR")
if L then
	L.webspraywarn30sec = "Entoilage dans 10 sec."
	L.webspraywarn20sec = "Entoilage ! 10 sec. avant les araignées !"
	L.webspraywarn10sec = "Araignées ! 10 sec. avant le Jet de rets !"
	L.webspraywarn5sec = "Jet de rets dans 5 sec. !"

	L.enragewarn = "Frénésie !"
	L.enragesoonwarn = "Frénésie imminente !"

	L.cocoons = "Entoilage"
	L.spiders = "Araignées"
end

L = BigWigs:NewBossLocale("Sapphiron", "frFR")
if L then
	L.airphase_trigger = "Saphiron s'envole !"
	L.deepbreath_trigger = "%s inspire profondément."

	--L.air_phase = "Air Phase"
	--L.ground_phase = "Ground Phase"

	L.ice_bomb = "Bombe de glace"
	L.ice_bomb_warning = "Arrivée d'une Bombe de glace !"
	L.ice_bomb_bar = "Impact Bombe de glace "

	L.icebolt_say = "Je suis un bloc !"
end

L = BigWigs:NewBossLocale("Instructor Razuvious", "frFR")
if L then
	L.understudy = "Doublure de chevalier de la mort"

	L.shout_warning = "Cri perturbant dans 5 sec. !"
	L.taunt_warning = "Provocation prête dans 5 sec. !"
	L.shieldwall_warning = "Barrière d'os terminée dans 5 sec. !"
end

L = BigWigs:NewBossLocale("Thaddius", "frFR")
if L then
	L[15929] = "Stalagg"
	L[15930] = "Feugen"

	L.stage1_yell_trigger1 = "Stalagg écraser toi !"
	L.stage1_yell_trigger2 = "À manger pour maître !"

	L.stage2_yell_trigger1 = "Manger… tes… os…"
	L.stage2_yell_trigger2 = "Casser... toi !"
	L.stage2_yell_trigger3 = "Tuer…"

	L.add_death_emote_trigger = "%s meurt."
	L.overload_emote_trigger = "%s entre en surcharge !"
	--L.add_revive_emote_trigger = "%s is jolted back to life!"

	L.polarity_extras = "Alertes supplémentaires pour le positionnement du changement de polarité"

	L.custom_off_select_charge_position = "Première position"
	L.custom_off_select_charge_position_desc = "Où se déplacer après le premier changement de polarité."
	L.custom_off_select_charge_position_value1 = "|cffff2020Charge négative (-)|r à GAUCHE, |cff2020ffCharge positive (+)|r à DROITE"
	L.custom_off_select_charge_position_value2 = "|cff2020ffCharge positive (+)|r à GAUCHE, |cffff2020Charge négative (-)|r à DROITE"

	L.custom_off_select_charge_movement = "Déplacement"
	L.custom_off_select_charge_movement_desc = "La stratégie de déplacement que votre groupe utilise."
	L.custom_off_select_charge_movement_value1 = "Courir |cff20ff20À TRAVERS|r le boss"
	L.custom_off_select_charge_movement_value2 = "Courir |cff20ff20DANS LE SENS DES AIGUILLES D'UNE MONTRE|r autour du boss"
	L.custom_off_select_charge_movement_value3 = "Courir |cff20ff20DANS LE SENS INVERSE DES AIGUILLES D'UNE MONTRE|r autour du boss"
	L.custom_off_select_charge_movement_value4 = "Quatre groupes 1 : Changement de polarité à |cff20ff20DROITE|r, même polarité à |cff20ff20GAUCHE|r"
	L.custom_off_select_charge_movement_value5 = "Quatre groupes 2 : Changement de polarité à |cff20ff20GAUCHE|r, même polarité à |cff20ff20DROITE|r"

	L.custom_off_charge_graphic = "Flèche graphique"
	L.custom_off_charge_graphic_desc = "Affiche une flèche graphique."
	L.custom_off_charge_text = "Flèches de texte"
	L.custom_off_charge_text_desc = "Affiche un message supplémentaire."
	L.custom_off_charge_voice = "Alerte vocale"
	L.custom_off_charge_voice_desc = "Joue un alerte vocale."

	--Translate these to get locale sound files!
	L.left = "<--- ALLEZ À GAUCHE <--- ALLEZ À GAUCHE <---"
	L.right = "---> ALLEZ À DROITE ---> ALLEZ À DROITE --->"
	L.swap = "^^^^ CHANGER DE CÔTÉS ^^^^ CHANGER DE CÔTÉS ^^^^"
	L.stay = "==== NE BOUGEZ PAS ==== NE BOUGEZ PAS ===="

	L.chat_message = "Le mod Thaddius prend en charge l'affichage de flèches directionnelles et la lecture de voix. Ouvrez les options pour les configurer."
end
