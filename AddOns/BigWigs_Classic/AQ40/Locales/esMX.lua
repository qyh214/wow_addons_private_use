local L = BigWigs:NewBossLocale("Viscidus", "esMX")
if not L then return end
if L then
	L.freeze = "Estados de congelación"
	L.freeze_desc = "Anunciar los diferentes estados de congelación."

	L.freeze_trigger1 = "%s comienza a ir más despacio!"
	L.freeze_trigger2 = "%s se está congelando!"
	L.freeze_trigger3 = "%s no se puede mover!"
	L.freeze_trigger4 = "%s comienza a desmoronarse!"
	L.freeze_trigger5 = "%s parece a punto de hacerse añicos!"

	L.freeze_warn1 = "¡Primera fase de congelación!"
	L.freeze_warn2 = "¡Segunda fase de congelación!"
	L.freeze_warn3 = "¡Viscidus está congelado!"
	L.freeze_warn4 = "¡Desmoronándose - sigue adelante!"
	L.freeze_warn5 = "¡Desmoronándose - casi allí!"
	L.freeze_warn_melee = "%d ataques cuerpo a cuerpo - faltan %d"
	L.freeze_warn_frost = "%d ataques de escarcha - faltan %d"
end

L = BigWigs:NewBossLocale("Ouro", "esMX")
if L then
	L.engage_message = "¡Entrando en combate con Ouro! ¡Sumersión posible en 90 segundos!"
	L.possible_submerge_bar = "Sumersión posible"

	L.emerge_message = "Ouro se ha emergido"
	L.emerge_bar = "Emersión"

	L.submerge_message = "Ouro se ha sumergido"
	L.submerge_bar = "Sumersión"

	L.scarab = "Desaparición de escarabajo"
	L.scarab_desc = "Anuncio para desaparición de escarabajo."
	L.scarab_bar = "Escarabajos desaparecen"
end

L = BigWigs:NewBossLocale("C'Thun", "esMX")
if L then
	L.claw_tentacle = "Tentáculo Garral"
	L.claw_tentacle_desc = "Temporizadores para Tentáculo Garral."

	L.giant_claw_tentacle = "Tentáculo garral gigante"
	L.giant_claw_tentacle_desc = "Temporizadores para Tentáculo garral gigante."

	L.eye_tentacles = "Tentáculo ocular"
	L.eye_tentacles_desc = "Temporizadores para los 8 Tentáculos oculares."

	L.giant_eye_tentacle = "Tentáculo ocular gigante"
	L.giant_eye_tentacle_desc = "Temporizadores para Tentáculo ocular gigante."

	L.weakened_desc = "Anunciar debilidad."

	L.dark_glare_message = "%s: %s (Grupo %s)" -- Dark Glare: PLAYER_NAME (Group 1)
	--L.stomach = "Stomach"
	--L.tentacle = "Tentacle (%d)"
end

L = BigWigs:NewBossLocale("Ahn'Qiraj Trash", "esMX")
if L then
	L.sentinel = "Centinela Anubisath" -- NPC 15264
	L.brainwasher = "Lavacerebros qiraji" -- NPC 15247
	L.defender = "Defensor Anubisath" -- NPC 15277
	L.crawler = "Reptador de la colmena Vekniss" -- NPC 15240

	L.target_buffs = "Anuncios de beneficios de objetivo"
	L.target_buffs_desc = "Cuando tu objetivo es un Centinela Anubisath, muestra un anuncio sobre qué beneficio tiene"
	L.target_buffs_message = "Beneficios de objetivo: %s"
	L.detect_magic_missing_message = "Falta Detectar magia en tu objetivo"
	L.detect_magic_warning = "Un mago debe lanzar \124cff71d5ff\124Hspell:2855:0\124h[Detectar magia]\124h\124r en tu objetivo para que funcionen los anuncios de beneficios."
end
