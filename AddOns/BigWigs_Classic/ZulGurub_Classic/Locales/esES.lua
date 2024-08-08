local L = BigWigs:NewBossLocale("High Priestess Jeklik", "esES")
if not L then return end
if L then
	L.bossName = "Suma Sacerdotisa Jeklik"

	L.swarm_desc = "Anuncia los enjambres de murciélagos"
	L.swarm_message = "¡Enjambre de murciélagos entrante!"

	L.bomb_desc = "Anuncia las bombas de murciélagos"
	-- L.bomb_trigger = "I command you to rain fire down upon these invaders!"
	L.bomb_message = "¡Bombas de murciélagos entrantes!"
end

L = BigWigs:NewBossLocale("High Priest Venoxis", "esES")
if L then
	L.bossName = "Sumo Sacerdote Venoxis"
end

L = BigWigs:NewBossLocale("High Priestess Mar'li", "esES")
if L then
	L.bossName = "Suma Sacerdotisa Mar'li"
end

L = BigWigs:NewBossLocale("High Priest Thekal", "esES")
if L then
	L.bossName = "Sumo Sacerdote Thekal"
	L.lorkhan = "Zelote Lor'Khan"
	L.zath = "Zelote Zath"

	L.tigers_message = "¡Tigres entrantes!"
end

L = BigWigs:NewBossLocale("High Priestess Arlokk", "esES")
if L then
	L.bossName = "Suma Sacerdotisa Arlokk"
end

L = BigWigs:NewBossLocale("Hakkar", "esES")
if L then
	L.bossName = "Hakkar"

	L.mc_bar = "CM: %s"
end

L = BigWigs:NewBossLocale("Bloodlord Mandokir", "esES")
if L then
	L.bossName = "Señor sangriento Mandokir"
end

L = BigWigs:NewBossLocale("Jin'do the Hexxer", "esES")
if L then
	L.bossName = "Jin'do el Aojador"

	L.brain_wash_message = "Tótem de lavado mental"
end

L = BigWigs:NewBossLocale("Gahz'ranka", "esES")
if L then
	L.bossName = "Gahz'ranka"
end

L = BigWigs:NewBossLocale("Edge of Madness", "esES")
if L then
	L.bossName = "Extremo de la Locura"
	L.grilek = "Gri'lek"
	L.hazzarah = "Hazza'rah"
	L.renataki = "Renataki"
	L.wushoolay = "Wushoolay"
end
