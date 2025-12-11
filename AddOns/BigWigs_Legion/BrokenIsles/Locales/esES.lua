local L = BigWigs:NewBossLocale("Withered J'im", "esES") or BigWigs:NewBossLocale("Withered J'im", "esMX")
if not L then return end
if L then
	L.custom_on_mark_boss = "Marca J'im Marchito"
	L.custom_on_mark_boss_desc = "Marca al verdadero J'im Marchito con {rt8}, requiere ser líder de banda o asistente de banda."
end
