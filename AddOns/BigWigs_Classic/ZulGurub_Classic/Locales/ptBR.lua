local L = BigWigs:NewBossLocale("High Priestess Jeklik", "ptBR")
if not L then return end
if L then
	L.bossName = "Alta-sacerdotisa Jeklik"

	L.swarm_desc = "Aviso para os enxames de morcegos"
	L.swarm_message = "Enxame de morcegos se aproximando!"

	L.bomb_desc = "Aviso para os morcegos bomba"
	-- L.bomb_trigger = "I command you to rain fire down upon these invaders!"
	L.bomb_message = "Morcegos bomba se aproximando!"
end

L = BigWigs:NewBossLocale("High Priest Venoxis", "ptBR")
if L then
	L.bossName = "Sumo Sacerdote Venoxis"
end

L = BigWigs:NewBossLocale("High Priestess Mar'li", "ptBR")
if L then
	L.bossName = "Alta-sacerdotisa Mar'li"
end

L = BigWigs:NewBossLocale("High Priest Thekal", "ptBR")
if L then
	L.bossName = "Sumo Sacerdote Thekal"
	L.lorkhan = "Zelote Lor'Khan"
	L.zath = "Zelote Zath"

	L.tigers_message = "Tigres se aproximando!"
end

L = BigWigs:NewBossLocale("High Priestess Arlokk", "ptBR")
if L then
	L.bossName = "Alta-sacerdotisa Arlokk"
end

L = BigWigs:NewBossLocale("Hakkar", "ptBR")
if L then
	L.bossName = "Hakkar"

	L.mc_bar = "CM: %s"
end

L = BigWigs:NewBossLocale("Bloodlord Mandokir", "ptBR")
if L then
	L.bossName = "Sangrelorde Mandokir"
end

L = BigWigs:NewBossLocale("Jin'do the Hexxer", "ptBR")
if L then
	L.bossName = "Jin'do, o Bagateiro"

	L.brain_wash_message = "Totem de Lavagem Cerebral"
end

L = BigWigs:NewBossLocale("Gahz'ranka", "ptBR")
if L then
	L.bossName = "Gahz'ranka"
end

L = BigWigs:NewBossLocale("Edge of Madness", "ptBR")
if L then
	L.bossName = "Beira da Loucura"
	L.grilek = "Gri'lek"
	L.hazzarah = "Hazza'rah"
	L.renataki = "Renataki"
	L.wushoolay = "Wushoolay"
end
