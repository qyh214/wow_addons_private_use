local L = BigWigs:NewBossLocale("High Priestess Jeklik", "deDE")
if not L then return end
if L then
	L.bossName = "Hohepriesterin Jeklik"

	L.swarm_desc = "Warnung, wenn Fledermaus-Schwarm im Anflug"
	L.swarm_message = "Fledermaus-Schwarm im Anflug!"

	L.bomb_desc = "Warnung, wenn Fledermaus-Bomben im Anflug sind"
	L.bomb_trigger = "Ich befehle Euch Feuer über diese Eindringlinge regnen zu lassen!"
	L.bomb_message = "Fledermaus-Bomben im Anflug!"
end

L = BigWigs:NewBossLocale("High Priest Venoxis", "deDE")
if L then
	L.bossName = "Hohepriester Venoxis"
end

L = BigWigs:NewBossLocale("High Priestess Mar'li", "deDE")
if L then
	L.bossName = "Hohepriesterin Mar'li"
end

L = BigWigs:NewBossLocale("High Priest Thekal", "deDE")
if L then
	L.bossName = "Hohepriester Thekal"
	L.lorkhan = "Zelot Lor'Khan"
	L.zath = "Zelot Zath"

	L.tigers_message = "Tiger!"
end

L = BigWigs:NewBossLocale("High Priestess Arlokk", "deDE")
if L then
	L.bossName = "Hohepriesterin Arlokk"
end

L = BigWigs:NewBossLocale("Hakkar", "deDE")
if L then
	L.bossName = "Hakkar"

	-- L.mc_bar = "MC: %s"
end

L = BigWigs:NewBossLocale("Bloodlord Mandokir", "deDE")
if L then
	L.bossName = "Blutfürst Mandokir"
end

L = BigWigs:NewBossLocale("Jin'do the Hexxer", "deDE")
if L then
	L.bossName = "Jin'do der Verhexer"

	L.brain_wash_message = "Gehirnwäschetotem"
end

L = BigWigs:NewBossLocale("Gahz'ranka", "deDE")
if L then
	L.bossName = "Gahz'ranka"
end

L = BigWigs:NewBossLocale("Edge of Madness", "deDE")
if L then
	L.bossName = "Rand des Wahnsinns"
	L.grilek = "Gri'lek"
	L.hazzarah = "Hazza'rah"
	L.renataki = "Renataki"
	L.wushoolay = "Wushoolay"
end
