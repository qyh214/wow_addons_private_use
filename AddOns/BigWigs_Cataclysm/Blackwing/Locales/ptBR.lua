
local L = BigWigs:NewBossLocale("Magmaw", "ptBR")
if not L then return end
if L then
	L.stage2_yell_trigger = "meu verme de lava" -- Inconcebível! Talvez você consiga mesmo derrotar meu verme de lava! Quem sabe eu possa... virar o jogo um pouquinho.

	L.slump = "Cair"
	L.slump_desc = "Magorja cai e fica exposto, permitindo que o rodeio começe."
	L.slump_bar = "Rodeio"
	L.slump_message = "Yeeeha!! MONTA NELE!!"
end

L = BigWigs:NewBossLocale("Omnotron Defense System", "ptBR")
if L then
	L.nef = "Lorde Victor Nefarius"
	L.nef_desc = "Avisos para as habilidades de Lorde Victor Nefarius"

	L.pool_explosion = "Gerador de poder sobrecarregado"
	L.incinerate = "Incinerar"
	L.flamethrower = "Lança-chamas"
	L.lightning = "Condutor de Raios"
	L.infusion = "Infusão"
end

L = BigWigs:NewBossLocale("Atramedes", "ptBR")
if L then
	L.obnoxious_fiend = "Diabrete Irritante" -- NPC ID 49740
	--L.circles = "Circles"
end

L = BigWigs:NewBossLocale("Maloriak", "ptBR")
if L then
	L.flames = "Chamas"
end

L = BigWigs:NewBossLocale("Nefarian", "ptBR")
if L then
	L.discharge = "Descarga"
	L.stage3_yell_trigger = "MATAR TODOS VOCÊS" -- Eu tentei ser um anfitrião afável, mas vocês se recusaram a morrer! Está na hora de acabar com o fingimento e simplesmente... MATAR TODOS VOCÊS!
	--L.too_close = "Dragons are too close"
end
