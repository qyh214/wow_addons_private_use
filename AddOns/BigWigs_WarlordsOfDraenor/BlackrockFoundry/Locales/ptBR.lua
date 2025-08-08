local L = BigWigs:NewBossLocale("Blackhand", "ptBR")
if L then
	L.custom_off_markedfordeath_marker = "Marcador de Marcado para Morrer"
	L.custom_off_markedfordeath_marker_desc = "Marque alvos de Marcado para Morrer com {rt1}{rt2}{rt3}, requer assistente ou líder."

	L.custom_off_massivesmash_marker = "Marcador de Esmagamento Estilhaçador"
	L.custom_off_massivesmash_marker_desc = "Marque o tanque que será acertado por Esmagamento Estilhaçador com {rt6}, requer assistente ou líder."
end

L = BigWigs:NewBossLocale("Beastlord Darmac", "ptBR")
if L then
	L.next_mount = "Montaria em breve!"

	L.custom_off_pinned_marker = "Marcador de Prender"
	L.custom_off_pinned_marker_desc = "Marcar jogadores presos com {rt8}{rt7}{rt6}{rt5}{rt4}, requer assistente ou líder.\n|cFFFF0000Apenas 1 pessoa na raide deve ter esta opção ativada para evitar conflitos de marcação.|r\n|cFFADFF2FDICA: Se a raide escolheu você para ativar esta opção, rapidamente passar o mouse sobre as lanças é a maneira mais rápida de marcá-las.|r"

	L.custom_off_conflag_marker = "Marcador de Conflagração"
	L.custom_off_conflag_marker_desc = "Marcar alvos de Conflagração com {rt1}{rt2}{rt3}, requer assistente ou líder.\n|cFFFF0000Apenas 1 pessoa na raide deve ter esta opção ativada para evitar conflitos de marcação.|r"
end

L = BigWigs:NewBossLocale("Gruul", "ptBR")
if not L then return end
if L then
	L.first_ability = "Pancada ou Batida"
end

L = BigWigs:NewBossLocale("Flamebender Ka'graz", "ptBR")
if L then
	L.molten_torrent_self = "Torrente Derretida em você"
	L.molten_torrent_self_desc = "Contador especial quando Torrente Derretida está em você."
	L.molten_torrent_self_bar = "Você explode!"

	L.custom_off_wolves_marker = "Marcador de Lobos Brasa"
	L.custom_off_wolves_marker_desc = "Marca Lobos Brasa com {rt3}{rt4}{rt5}{rt6}, requer assitente ou líder."
end

L = BigWigs:NewBossLocale("Kromog", "ptBR")
if L then
	L.custom_off_hands_marker = "Marcador de Garra da Terra no tanque"
	L.custom_off_hands_marker_desc = "Marca as Garras da Terra que pegam os tanques com {rt7}{rt8}, requer assistente ou líder."

	L.prox = "Proximidade do tanque"
	L.prox_desc = "Abre uma janela de proximidade de 15 metros mostrando o outro tanque para ajudar ele com a habilidade Punhos de Pedra."

	L.destroy_pillars = "Destrua os Pilares"
end

L = BigWigs:NewBossLocale("Oregorger", "ptBR")
if L then
	L.roll_message = "Rolagem %d - %d minério faltando!"
end

L = BigWigs:NewBossLocale("The Blast Furnace", "ptBR")
if L then
	L.custom_on_shieldsdown_marker = "Marcador de Escudo ao chão"
	L.custom_on_shieldsdown_marker_desc = "Marca uma Elementalista Primeva vulnerável com {rt8}, requer assistente ou líder."

	L.custom_off_firecaller_marker = "Marcador de Bradachamas"
	L.custom_off_firecaller_marker_desc = "Marca Bradachamas com {rt7}{rt6}, requer assistente ou líder.\n|cFFFF0000Apenas 1 pessoa na raide deve ter esta opção ativada para evitar conflitos de marcação.|r\n|cFFADFF2FDICA: Se a raide escolheu você para ativar esta opção, rapidamente passar o mouse sobre os monstros é a maneira mais rápida de marcá-los.|r"

	L.heat_increased_message = "Calor aumentou! Explodir a cada %ss"

	L.bombs_dropped = "Bombas soltas! (%d)"
	L.bombs_dropped_p2 = "Engenheiro morto, bombas soltas!"

	L.operator = "Aparecimento de Operador de Fole"
	L.operator_desc = "Durante a primeira fase, 2 Operadores de Fole vão aparecer repetidamente, 1 de cada lado da sala."

	L.engineer = "Aparecimento de Engenheiro da Fornalha"
	L.engineer_desc = "Durante a primeira fase, 2 Engenheiro da Fornalha vão aparecer repetidamente, 1 de cada lado da sala."

	L.guard = "Aparecimento de Segurança"
	L.guard_desc = "Durante a primeira fase, 2 Segurança vão aparecer repetidamente, 1 de cada lado da sala. Durante a fase dois, 1 Segurança vai aparecer repetidamente na entrada da sala."

	L.firecaller = "Aparecimento de Bradachamas"
	L.firecaller_desc = "Durante a segunda fase, 2 Bradachamas vão aparecer repetidamente, 1 de cada lado da sala."
end

L = BigWigs:NewBossLocale("The Iron Maidens", "ptBR")
if L then
	L.ship_trigger = "se prepara para operar o canhão principal do Navio!" --TODO: needs reviewing

	L.ship = "Pular para o navio"

	L.custom_off_heartseeker_marker = "Marcador de Furacórdio Banhado em Sangue"
	L.custom_off_heartseeker_marker_desc = "Marca os alvos de Furacórdio Banhado em Sangue com {rt1}{rt2}{rt3}, requer assistente ou líder."

	L.power_message = "%d Fúria Férrea!"
end

L = BigWigs:NewBossLocale("Operator Thogar", "ptBR")
if L then
	L.custom_on_firemender_marker = "Marcador de Atafogo Grom'kar"
	L.custom_on_firemender_marker_desc = "Marca Atafogo Grom'kar com {rt7}, requer assistente ou líder."

	L.custom_on_manatarms_marker = "Marcador de Homem de Armas Grom'kar"
	L.custom_on_manatarms_marker_desc = "Marca Homem de Armas Grom'kar com {rt8},  requer assistente ou líder."

	L.trains = "Avisos de trem"
	L.trains_desc = "Mostra contadores e mensagens para casa linha para quando o próximo trem vier. Linhas são numeradas do chefe até a entrada. Ex: Chefe 1 2 3 4 Entrada."

	L.lane = "Linha %s: %s"
	L.train = "Trem"
	L.adds_train = "Trem de adds"
	L.big_add_train = "Trem de adds grande"
	L.cannon_train = "Trem de canhão"
	L.deforester = "Desflorestador"
	L.random = "Trens aleatórios"

	L.train_you = "Trem na sua linha! (%d)"
end

L = BigWigs:NewBossLocale("Blackrock Foundry Trash", "ptBR")
if L then
	L.guardian = "Guardião da Oficina"
	L.hauler = "Rebocador Ogron"
	L.beasttender = "Doma-feras do Senhor do Trovão"
	L.brute = "Brutamontes da Ferroficina"
	L.gronnling = "Gronnídeo Operário"
	L.gnasher = "Triscadente Negrastilha"
	L.enforcer = "Impositor da Rocha Negra"
	L.taskmaster = "Capataz de Ferro"
	L.furnace = "Exaustor da Fornalha Explosiva"
	L.earthbinder = "Ataterra de Ferro"
	L.mistress = "Dama da Forja Fogomanos"

	-- TODO: needs translating
	-- L.furnace_msg1 = "Hmm, kinda toasty isn't it?"
	-- L.furnace_msg2 = "It's marshmallow time!"
	-- L.furnace_msg3 = "This can't be good..."
end

