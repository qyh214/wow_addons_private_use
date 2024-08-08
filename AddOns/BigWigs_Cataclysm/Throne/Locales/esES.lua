
local L = BigWigs:NewBossLocale("Al'Akir", "esES")
if not L then return end
if L then
	L.stormling = "Tormentillas"
	L.stormling_desc = "Invoca Tormentillas."

	L.acid_rain = "Lluvia ácida (%d)"

	L.feedback_message = "%dx Rebote"
end

L = BigWigs:NewBossLocale("Conclave of Wind", "esES")
if L then
	L.gather_strength = "%s empieza a extraer fuerza"

	L["93059_desc"] = "Escudo de absorción"

	L.full_power = "Poder Máximo"
	L.full_power_desc = "Avisa cuando los jefes alcanzan Poder Máximo y empiezan a lanzar las abilidades especiales."
	L.gather_strength_emote = "¡%s empieza a extraer fuerza de los señores del viento que quedan!"
end

