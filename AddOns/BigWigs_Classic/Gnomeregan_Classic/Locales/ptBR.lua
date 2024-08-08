local L = BigWigs:NewBossLocale("Grubbis Discovery", "ptBR")
if not L then return end
if L then
	L.bossName = "Grúdio"
	L.aoe = "Dano corpo a corpo em área"
	L.cloud = "Uma nuvem chegou ao chefe"
	L.cone = "Cone \"frontal\"" -- "Frontal" Cone, it's a rear cone (he's farting)
	L.warmup_say_chat_trigger = "Gnomeregan" -- Ainda há dutos de ventilação espalhando material radioativo em Gnomeregan.
end

L = BigWigs:NewBossLocale("Viscous Fallout Discovery", "ptBR")
if L then
	L.bossName = "Precipitação Radioativa Viscosa"
	L.desiccated_fallout = "Precipitação Desidratada" -- NPC ID 216810
end

L = BigWigs:NewBossLocale("Crowd Pummeler 9-60 Discovery", "ptBR")
if L then
	L.bossName = "Espanca-gente 9-60"
end

L = BigWigs:NewBossLocale("Electrocutioner 6000 Discovery", "ptBR")
if L then
	L.bossName = "Eletrocutor 6000"
end

L = BigWigs:NewBossLocale("Mechanical Menagerie Discovery", "ptBR")
if L then
	L.bossName = "Viveiro Mecânico"
	L.attack_buff = "+50% de velocidade de ataque"
	L.boss_at_hp = "%s com %d%%" -- BOSS_NAME at 50%
	L.red_button = "Botão vermelho"

	L[218242] = "|T134153:0:0:0:0:64:64:4:60:4:60|tDragão"
	L[218243] = "|T136071:0:0:0:0:64:64:4:60:4:60|tOvelha"
	L[218244] = "|T133944:0:0:0:0:64:64:4:60:4:60|tEsquilo"
	L[218245] = "|T135996:0:0:0:0:64:64:4:60:4:60|tFrango"

	L.run = "Corra até a porta"
	L.run_desc = "Ao derrotar este chefe, uma mensagem será mostrada instruindo você a correr até a porta. Isso é para ajudá-lo a evitar engajar acidentalmente o próximo chefe."
end

L = BigWigs:NewBossLocale("Mekgineer Thermaplugg Discovery", "ptBR")
if L then
	L.bossName = "Mecangenheiro Termaplugue"
	L.red_button = "Botão vermelho"
	L.position = "Posição %d" -- Position 5
end
