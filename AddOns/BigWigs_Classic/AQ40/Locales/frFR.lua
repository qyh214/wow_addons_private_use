local L = BigWigs:NewBossLocale("Viscidus", "frFR")
if not L then return end
if L then
	L.freeze = "États de Gel"
	L.freeze_desc = "Annoncer des différents états gelés."

	L.freeze_trigger1 = "%s commence à ralentir !"
	L.freeze_trigger2 = "%s est gelé !"
	L.freeze_trigger3 = "%s est congelé !"
	L.freeze_trigger4 = "%s commence à se briser !"
	L.freeze_trigger5 = "%s semble prêt à se briser !"

	L.freeze_warn1 = "Première phase de gel !"
	L.freeze_warn2 = "Deuxième phase de gel !"
	L.freeze_warn3 = "Viscidus est gelé !"
	L.freeze_warn4 = "Brisement - continuez !"
	L.freeze_warn5 = "Brisement - presque là !"
	L.freeze_warn_melee = "%d attaques en mêlée - %d de plus"
	L.freeze_warn_frost = "%d attaques de givre - %d de plus"
end

L = BigWigs:NewBossLocale("Ouro", "frFR")
if L then
	L.engage_message = "Ouro engagé ! Submersion possible dans 90 secondes !"
	L.possible_submerge_bar = "Submersion possible"

	L.emerge_message = "Ouro a émergé"
	L.emerge_bar = "Émergence"

	L.submerge_message = "Ouro a submergé"
	L.submerge_bar = "Submersion"

	L.scarab = "Disparition des scarabées"
	L.scarab_desc = "Avertissement pour la disparition des scarabées."
	L.scarab_bar = "Scarabées disparaissent"
end

L = BigWigs:NewBossLocale("C'Thun", "frFR")
if L then
	L.claw_tentacle = "Tentacule griffu"
	L.claw_tentacle_desc = "Chronomètres pour le tentacule griffu."

	L.giant_claw_tentacle = "Tentacule griffu géant"
	L.giant_claw_tentacle_desc = "Chronomètres pour le tentacule griffu géant."

	L.eye_tentacles = "Tentacule oculaire"
	L.eye_tentacles_desc = "Chronomètres pour les 8 tentacules oculaires."

	L.giant_eye_tentacle = "Tentacule oculaire géant"
	L.giant_eye_tentacle_desc = "Chronomètres pour le tentacule oculaire géant."

	L.weakened_desc = "Annoncer affaiblissement."

	L.dark_glare_message = "%s: %s (Groupe %s)" -- Dark Glare: PLAYER_NAME (Group 1)
	--L.stomach = "Stomach"
	--L.tentacle = "Tentacle (%d)"
end

L = BigWigs:NewBossLocale("Ahn'Qiraj Trash", "frFR")
if L then
	L.sentinel = "Sentinelle Anubisath" -- NPC 15264
	L.brainwasher = "Lave-cerveaux qiraji" -- NPC 15247
	L.defender = "Défenseur Anubisath" -- NPC 15277
	L.crawler = "Rampant de la ruche vekniss" -- NPC 15240

	L.target_buffs = "Avertissement d'améliorations de la cible"
	L.target_buffs_desc = "Lorsque votre cible est un Sentinelle Anubisath, affiche un avertissement pour indiquer quelle amélioration il possède."
	L.target_buffs_message = "Améliorations de la cible : %s"
	L.detect_magic_missing_message = "La Détection de la magie est manquante sur votre cible"
	L.detect_magic_warning = "Un mage doit incanter \124cff71d5ff\124Hspell:2855:0\124h[Détection de la magie]\124h\124r sur votre cible pour que les avertissements d'améliorations fonctionnent."
end
