
local L = BigWigs:NewBossLocale("Magmaw", "ptBR")
if not L then return end
if L then
	L.stage2_yell_trigger = "Você parece ter derrotado meu verme de lava."

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
	L.air_phase_trigger = "Isso, fujam! Com cada passo, seus corações aceleram. Os batimentos, forte como trovôes... Chegam quase a ensurdecer. Vocês não vão escapar!"
	--L.circles = "Circles"
end

L = BigWigs:NewBossLocale("Maloriak", "ptBR")
if L then
	L.flames = "Chamas"
end

L = BigWigs:NewBossLocale("Nefarian", "ptBR")
if L then
	L.discharge = "Descarga"
	L.stage3_yell_trigger = "Eu tentei ser um anfitrião afável, mas vocês se recusaram a morrer! Está na hora de acabar com o fingimento e simplesmente... MATAR TODOS VOCÊS!"
	--L.too_close = "Dragons are too close"
end
