
local L = BigWigs:NewBossLocale("Magmaw", "esMX")
if not L then return end
if L then
	L.stage2_yell_trigger = "Inconcebible" -- ¡Inconcebible! ¡Es posible que venzan a mi gusano de lava! Quizás yo pueda... desequilibrar la balanza.

	L.slump = "Cae"
	L.slump_desc = "Cae hacia delante exponiendose a sí mismo, permitiendo que el rodeo empiece."
	L.slump_bar = "Rodeo"
	L.slump_message = "¡Yeepah, móntalo!"
end

L = BigWigs:NewBossLocale("Omnotron Defense System", "esMX")
if L then
	L.nef = "Lord Victor Nefarius"
	L.nef_desc = "Avisos para las abilidades de Lord Victor Nefarius"

	L.pool_explosion = "Generador de poder sobrecargado"
	L.incinerate = "Incinerar"
	L.flamethrower = "Lanzallamas"
	L.lightning = "Relámpago"
	L.infusion = "Infusión"
end

L = BigWigs:NewBossLocale("Atramedes", "esMX")
if L then
	L.obnoxious_fiend = "Maligno execrable" -- NPC ID 49740
	--L.circles = "Circles"
end

L = BigWigs:NewBossLocale("Maloriak", "esMX")
if L then
	L.flames = "Llamas"
end

L = BigWigs:NewBossLocale("Nefarian", "esMX")
if L then
	L.discharge = "Descarga"
	L.stage3_yell_trigger = "He intentado ser un buen anfitrión" -- ¡He intentado ser un buen anfitrión, pero rehusaron morir! Hora de dejar de fingir y... ¡MATARLOS A TODOS!
	--L.too_close = "Dragons are too close"
end
