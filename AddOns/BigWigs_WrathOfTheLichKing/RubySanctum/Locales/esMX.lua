local L = BigWigs:NewBossLocale("Halion", "esMX")
if not L then return end
if L then
	L.twilight_cutter_emote_trigger = "esferas" -- ¡Las esferas que orbitan emiten energía oscura!
end

L = BigWigs:NewBossLocale("The Ruby Sanctum Trash", "esMX")
if L then
	--L.baltharus = "Baltharus the Warborn" -- NPC 39751
	--L.saviana = "Saviana Ragefire" -- NPC 39747
	--L.zarithrian = "General Zarithrian" -- NPC 39746

	L.adds_yell_trigger = "¡Háganlos cenizas, esbirros!"
end
