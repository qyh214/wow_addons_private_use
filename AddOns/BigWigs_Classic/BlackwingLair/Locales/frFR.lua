local L = BigWigs:NewBossLocale("Razorgore the Untamed", "frFR")
if not L then return end
if L then
	L.start_trigger = "Sonnez l'alarme"

	L.eggs = "Comptage des œufs"
	L.eggs_desc = "Compte le nombre d'œufs détruits."
	L.eggs_message = "%d/30 œufs détruits"
end

L = BigWigs:NewBossLocale("Vaelastrasz the Corrupt", "frFR")
if L then
	L.warmup_trigger = "Trop tard, mes amis"
	L.tank_bomb = "Bombe de tank"
end

L = BigWigs:NewBossLocale("Chromaggus", "frFR")
if L then
	L.breath = "Souffles"
	L.breath_desc = "Préviens de l'arrivée des souffles."

	L.debuffs_message = "3/5 affaiblissements, prudence !"
	L.debuffs_warning = "4/5 affaiblissements, %s sur le 5ème !"
	L.bronze = "Bronze"

	L.vulnerability = "Changement de vulnérabilité"
	L.vulnerability_desc = "Préviens quand la vulnérabilité change."
	L.vulnerability_message = "Vulnérabilité : %s"
	L.detect_magic_missing = "Détection de la magie est absente de Chromaggus"
	L.detect_magic_warning = "Un Mage doit incanter \124cff71d5ff\124Hspell:2855:0\124h[Détection de la magie]\124h\124r sur Chromaggus pour que les avertissements de vulnérabilité fonctionnent."
end

L = BigWigs:NewBossLocale("Nefarian Classic", "frFR")
if L then
	L.engage_yell_trigger = "Que les jeux commencent"
	L.stage3_yell_trigger = "C'est impossible"

	L.shaman_class_call_yell_trigger = "Chamans, montrez moi"
	L.deathknight_class_call_yell_trigger = "Chevalier de la mort"
	--L.monk_class_call_yell_trigger = "Monks"
	L.hunter_class_call_yell_trigger = "Ah, les chasseurs et les stupides"

	L.warnshaman = "Chamans - Totems posés !"
	L.warndruid = "Druides - Coincés en forme de félin !"
	L.warnwarlock = "Démonistes - Arrivée d'infernaux !"
	L.warnpriest = "Prêtre - Soins blessants !"
	L.warnhunter = "Chasseurs - Arcs/Fusils cassés !"
	L.warnwarrior = "Guerriers - Coincés en posture berseker !"
	L.warnrogue = "Voleurs - Téléportés et immobilisés !"
	L.warnpaladin = "Paladins - Bénédiction de protection !"
	L.warnmage = "Mages - Arrivée des métamorphoses !"
	--L.warndeathknight = "Death Knights - Death Grip"
	--L.warnmonk = "Monks - Stuck Rolling"
	--L.warndemonhunter = "Demon Hunters - Blinded"

	L.classcall = "Appel de classe"
	L.classcall_desc = "Préviens de l'arrivée des appels de classe."

	L.add = "Morts de drakônides"
	L.add_desc = "Annoncer le nombre de serviteurs tués en phase 1 avant l'atterrissage de Nefarian"
end

L = BigWigs:NewBossLocale("Blackwing Lair Trash", "frFR")
if L then
	L.wyrmguard_overseer = "Garde wyrm Griffemort / Surveillant Griffemort" -- NPC 12460 / 12461
	L.sandstorm = "Tempête de sable"

	L.target_vulnerability = "Avertissements de vulnérabilité de la cible"
	L.target_vulnerability_desc = "Lorsque votre cible est un Garde wyrm Griffemort ou un Surveillant Griffemort, affichez un avertissement pour indiquer sa vulnérabilité."
	L.target_vulnerability_message = "Vulnérabilité de la cible: %s"
	L.detect_magic_missing_message = "Détection de la magie est absente de votre cible"
	L.detect_magic_warning = "Un mage doit incanter \124cff71d5ff\124Hspell:2855:0\124h[Détection de la magie]\124h\124r sur votre cible pour que les avertissements de vulnérabilité fonctionnent."

	L.warlock = "Démoniste de l'Aile noire" -- NPC 12459
end
