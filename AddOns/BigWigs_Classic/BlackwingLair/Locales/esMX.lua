local L = BigWigs:NewBossLocale("Razorgore the Untamed", "esMX")
if not L then return end
if L then
	L.start_trigger = "¡Los invasores han penetrado en El Criadero!"

	L.eggs = "Contar huevos"
	L.eggs_desc = "Cuenta los huevos destruídos."
	L.eggs_message = "%d/30 huevos destruídos"
end

L = BigWigs:NewBossLocale("Vaelastrasz the Corrupt", "esMX")
if L then
	L.warmup_trigger = "¡Demasiado tarde, amigos!"
	L.tank_bomb = "Bomba de tanque"
end

L = BigWigs:NewBossLocale("Chromaggus", "esMX")
if L then
	L.breath = "Alientos"
	L.breath_desc = "Anuncia los alientos."

	L.debuffs_message = "¡3/5 perjuicios, ten cuidado!"
	L.debuffs_warning = "¡4/5 perjuicios, %s al 5to!"
	L.bronze = "Bronce"

	L.vulnerability = "Cambio de vulnerabilidad"
	L.vulnerability_desc = "Anuncia cambios de vulnerabilidad."
	L.vulnerability_message = "Vulnerabilidad: %s"
	L.detect_magic_missing = "Falta Detectar magia en Chromaggus"
	L.detect_magic_warning = "Un mago debe lanzar \124cff71d5ff\124Hspell:2855:0\124h[Detectar magia]\124h\124r en Chromaggus para que funcionen los anuncios de vulnerabilidad."
end

L = BigWigs:NewBossLocale("Nefarian Classic", "esMX")
if L then
	L.engage_yell_trigger = "¡Que comiencen los juegos!"
	L.stage3_yell_trigger = "¡Imposible! ¡Levántense, mis esbirros!"

	L.shaman_class_call_yell_trigger = "Chamanes"
	L.deathknight_class_call_yell_trigger = "Caballeros de la Muerte"
	L.monk_class_call_yell_trigger = "Monjes"
	L.hunter_class_call_yell_trigger = "Cazadores"

	L.warnshaman = "¡Chamanes - aparecen tótems!"
	L.warndruid = "¡Druidas - atrapado en forma felina!"
	L.warnwarlock = "¡Brujos - infernales entrantes!"
	L.warnpriest = "¡Sacerdotes - sanaciones hacen daño!"
	L.warnhunter = "¡Cazadores - armas están rotos!"
	L.warnwarrior = "¡Guerreros - atrapado en actitud rabiosa!"
	L.warnrogue = "¡Pícaros - teletransportado y enredado!"
	L.warnpaladin = "¡Paladines - bendición de protección!"
	L.warnmage = "¡Magos - polimorfias entrantes!"
	--L.warndeathknight = "Death Knights - Death Grip"
	--L.warnmonk = "Monks - Stuck Rolling"
	--L.warndemonhunter = "Demon Hunters - Blinded"

	L.classcall = "Llamada de clase"
	L.classcall_desc = "Anucia las llamadas de clase."

	L.add = "Muertes de dracónidos"
	L.add_desc = "Anuncia el número de dracónidos muertos en fase 1 antes del aterrizaje de Nefarian."
end

L = BigWigs:NewBossLocale("Blackwing Lair Trash", "esMX")
if L then
	L.wyrmguard_overseer = "Vermiguardia Garramortal / Sobrestante Garramortal" -- NPC 12460 / 12461
	L.sandstorm = "Tormenta de arena"

	L.target_vulnerability = "Anuncios de vulnerabilidad de objetivo"
	L.target_vulnerability_desc = "Cuando tu objetivo es un Vermiguardia Garramortal o un Sobrestante Garramortal, muestra un anuncio sobre qué vulnerabilidad tiene."
	L.target_vulnerability_message = "Vulnerabilidad de objetivo: %s"
	L.detect_magic_missing_message = "Falta Detectar magia en tu objetivo"
	L.detect_magic_warning = "Un mago debe lanzar \124cff71d5ff\124Hspell:2855:0\124h[Detectar magia]\124h\124r en tu objetivo para que funcionen los anuncios de vulnerabilidad."

	L.warlock = "Brujo Alanegra" -- NPC 12459
end
