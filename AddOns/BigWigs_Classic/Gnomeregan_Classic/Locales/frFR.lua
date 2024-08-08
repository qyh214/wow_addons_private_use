local L = BigWigs:NewBossLocale("Grubbis Discovery", "frFR")
if not L then return end
if L then
	L.bossName = "Grubbis"
	L.aoe = "Dégâts de mêlée en AoE"
	L.cloud = "Un nuage a atteint le boss"
	L.cone = "Cône \"frontal\"" -- "Frontal" Cone, it's a rear cone (he's farting)
	--L.warmup_say_chat_trigger = "Gnomeregan" -- There are still ventilation shafts actively spewing radioactive material throughout Gnomeregan.
end

L = BigWigs:NewBossLocale("Viscous Fallout Discovery", "frFR")
if L then
	L.bossName = "Retombée visqueuse"
	L.desiccated_fallout = "Retombée desséchée" -- NPC ID 216810
end

L = BigWigs:NewBossLocale("Crowd Pummeler 9-60 Discovery", "frFR")
if L then
	L.bossName = "Disperseur de foule 9-60"
end

L = BigWigs:NewBossLocale("Electrocutioner 6000 Discovery", "frFR")
if L then
	L.bossName = "Electrocuteur 6000"
end

L = BigWigs:NewBossLocale("Mechanical Menagerie Discovery", "frFR")
if L then
	L.bossName = "Ménagerie mécanique"
	L.attack_buff = "+50% de vitesse d'attaque"
	L.boss_at_hp = "%s à %d%%" -- BOSS_NAME at 50%
	L.red_button = "Bouton rouge"

	L[218242] = "|T134153:0:0:0:0:64:64:4:60:4:60|tDragon"
	L[218243] = "|T136071:0:0:0:0:64:64:4:60:4:60|tMouton"
	L[218244] = "|T133944:0:0:0:0:64:64:4:60:4:60|tÉcureuil"
	L[218245] = "|T135996:0:0:0:0:64:64:4:60:4:60|tPoulet"

	L.run = "Courir jusqu'à la porte"
	L.run_desc = "Affichez un message lorsque vous avez vaincu ce boss pour courir jusqu'à la porte. Cela est destiné à vous aider à éviter d'engager accidentellement le prochain boss."
end

L = BigWigs:NewBossLocale("Mekgineer Thermaplugg Discovery", "frFR")
if L then
	L.bossName = "Mekgénieur Thermojoncteur"
	L.red_button = "Bouton rouge"
	--L.position = "Position %d" -- Position 5
end
