local L = BigWigs:NewBossLocale("Viscidus", "ptBR")
if not L then return end
if L then
	L.freeze = "Estados de congelamento"
	L.freeze_desc = "Aviso para os diferentes estados de congelamento."

	L.freeze_trigger1 = "%s começa a ficar lento!"
	L.freeze_trigger2 = "%s está congelando!"
	L.freeze_trigger3 = "%s está totalmente congelado!"
	L.freeze_trigger4 = "%s começa a rachar!"
	L.freeze_trigger5 = "%s parece estar a ponto de se estilhaçar!"

	L.freeze_warn1 = "Primeira fase de congelamento!"
	L.freeze_warn2 = "Segunda fase de congelamento!"
	L.freeze_warn3 = "Viscidus está congelado!"
	L.freeze_warn4 = "Rachando - continue!"
	L.freeze_warn5 = "Rachando - quase lá!"
	L.freeze_warn_melee = "%d ataques corpo a corpo - mais %d para ir"
	L.freeze_warn_frost = "%d ataques de gelo - mais %d para ir"
end

L = BigWigs:NewBossLocale("Ouro", "ptBR")
if L then
	L.engage_message = "Ouro engajado! Submersão possível em 90 segundos!"
	L.possible_submerge_bar = "Submersão possível"

	L.emerge_message = "Ouro emergiu"
	L.emerge_bar = "Emersão"

	L.submerge_message = "Ouro submergiu"
	L.submerge_bar = "Submersão"

	L.scarab = "Desaparecimento de escaravelho"
	L.scarab_desc = "Aviso para desaparecimento de escaravelho."
	L.scarab_bar = "Escaravelhos desaparecem"
end

L = BigWigs:NewBossLocale("C'Thun", "ptBR")
if L then
	L.claw_tentacle = "Tentáculo de Garra"
	L.claw_tentacle_desc = "Cronômetros para o tentáculo de garra."

	L.giant_claw_tentacle = "Tentáculo de Garra Gigante"
	L.giant_claw_tentacle_desc = "Cronômetros para o tentáculo de garra gigante."

	L.eye_tentacles = "Tentóculo"
	L.eye_tentacles_desc = "Cronômetros para os 8 tentóculos."

	L.giant_eye_tentacle = "Tentóculo Gigante"
	L.giant_eye_tentacle_desc = "Cronômetros para o tentóculo gigante."

	L.weakened_desc = "Aviso para estado enfraquecido."

	L.dark_glare_message = "%s: %s (Grupo %s)" -- Dark Glare: PLAYER_NAME (Group 1)
	--L.stomach = "Stomach"
	--L.tentacle = "Tentacle (%d)"
end

L = BigWigs:NewBossLocale("Ahn'Qiraj Trash", "ptBR")
if L then
	L.sentinel = "Sentinela Anubisath" -- NPC 15264
	L.brainwasher = "Lavamentes Qiraji" -- NPC 15247
	L.defender = "Defensor Anubisath" -- NPC 15277
	L.crawler = "Rastejante de Colmeia Vekniss" -- NPC 15240

	L.target_buffs = "Avisos de bônus do alvo"
	L.target_buffs_desc = "Quando o seu alvo é um Sentinela Anubisath, mostra um aviso sobre qual bônus ele possui."
	L.target_buffs_message = "Bônus do alvo: %s"
	L.detect_magic_missing_message = "Detectar Magia está ausente do seu alvo"
	L.detect_magic_warning = "Um mago deve lançar \124cff71d5ff\124Hspell:2855:0\124h[Detectar Magia]\124h\124r no seu alvo para que os avisos de bônus funcionem."
end
