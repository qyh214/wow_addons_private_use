local L = BigWigs:NewBossLocale("Razorgore the Untamed", "ptBR")
if not L then return end
if L then
	L.start_trigger = "Invasores violaram a incubadora!"

	L.eggs = "Contar ovos"
	L.eggs_desc = "Conta os ovos destruídos."
	L.eggs_message = "%d/30 ovos destruídos"
end

L = BigWigs:NewBossLocale("Vaelastrasz the Corrupt", "ptBR")
if L then
	L.warmup_trigger = "É tarde demais, meus amigos!"
	L.tank_bomb = "Bomba de Tanque"
end


L = BigWigs:NewBossLocale("Chromaggus", "ptBR")
if L then
	L.breath = "Respirações"
	L.breath_desc = "Avisar sobre as respirações."

	L.debuffs_message = "3/5 penalidades, cuidado!"
	L.debuffs_warning = "4/5 penalidades, %s na 5ª!"
	L.bronze = "Bronze"

	L.vulnerability = "Mudanças de vulnerabilidade"
	L.vulnerability_desc = "Aviso para mudanças de vulnerabilidade."
	L.vulnerability_message = "Vulnerabilidade: %s"
	L.detect_magic_missing = "Detectar Magia está ausente de Chromaggus"
	L.detect_magic_warning = "Um mago precisa lançar \124cff71d5ff\124Hspell:2855:0\124h[Detectar Magia]\124h\124r em Chromaggus para que os avisos de vulnerabilidade funcionem."
end

L = BigWigs:NewBossLocale("Nefarian Classic", "ptBR")
if L then
	L.engage_yell_trigger = "Que comecem os jogos!"
	L.stage3_yell_trigger = "Impossível! Ergam-se, meus lacaios!"

	L.shaman_class_call_yell_trigger = "Xamãs"
	--L.deathknight_class_call_yell_trigger = "Death Knights"
	--L.monk_class_call_yell_trigger = "Monks"
	L.hunter_class_call_yell_trigger = "Caçadores"

	L.warnshaman = "Xamãs - Totens aparecendo!"
	L.warndruid = "Druidas - Presos na forma de felino!"
	L.warnwarlock = "Bruxos - Infernais chegando!"
	L.warnpriest = "Sacerdotes - Curas causando dano!"
	L.warnhunter = "Caçadores - Arcos/Armas de fogo quebrados!"
	L.warnwarrior = "Guerreiros - Presos na Postura de Berserker!"
	L.warnrogue = "Ladinos - Teleportados e enraizados!"
	L.warnpaladin = "Paladinos - Bênção de Proteção!"
	L.warnmage = "Magos - Polimorfias chegando!"
	--L.warndeathknight = "Death Knights - Death Grip"
	--L.warnmonk = "Monks - Stuck Rolling"
	--L.warndemonhunter = "Demon Hunters - Blinded"

	L.classcall = "Chamada de classe"
	L.classcall_desc = "Aviso para chamadas de classe."

	L.add = "Mortes de draconídeo"
	L.add_desc = "Anunciar o número de draconídeos mortos na fase 1 antes de Nefarian aterrissar."
end

L = BigWigs:NewBossLocale("Blackwing Lair Trash", "ptBR")
if L then
	L.wyrmguard_overseer = "Serpeguarda Garra da Morte / Feitor Garra da Morte" -- NPC 12460 / 12461
	L.sandstorm = "Tempestade de Areia"

	L.target_vulnerability = "Avisos de vulnerabilidade do alvo"
	L.target_vulnerability_desc = "Quando o seu alvo é um Serpeguarda Garra da Morte ou um Feitor Garra da Morte, mostra um aviso sobre qual vulnerabilidade ele possui."
	L.target_vulnerability_message = "Vulnerabilidade do alvo: %s"
	L.detect_magic_missing_message = "Detectar Magia está ausente do seu alvo"
	L.detect_magic_warning = "Um mago precisa lançar \124cff71d5ff\124Hspell:2855:0\124h[Detectar Magia]\124h\124r no seu alvo para que os avisos de vulnerabilidade funcionem."

	L.warlock = "Bruxo Asa Negra" -- NPC 12459
end
