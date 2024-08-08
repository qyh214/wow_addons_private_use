
local L = BigWigs:NewBossLocale("Halfus Wyrmbreaker", "esES")
if not L then return end
if L then
	L.strikes_message = "Golpes"
	--L.freed_message = "%s freed %s"
end

L = BigWigs:NewBossLocale("Cho'gall", "esES")
if L then
	L.orders = "Cambios de posición"
	L.orders_desc = "Avisa cuando Cho'gall cambia el orden de posiciones entre Sombra/Llama."

	L.crash_say = "Colisión"
	L.worship_cooldown = "~Conversión"
	L.adherent_bar = "Gran add #%d"
	L.adherent_message = "¡Add %d aparece!"
	L.ooze_bar = "Enjambre de mocos %d"
	L.ooze_message = "¡Enjambre de mocos %d inminente!"
	L.tentacles_bar = "Aparecen tentáculos"
	L.tentacles_message = "¡Fiesta de tentáculos!"
	L.sickness_message = "¡Te sientes fatal!"

	L.blaze_message = "¡Fuego en TI!"

	L.fury_message = "¡Furia!"
	L.first_fury_soon = "¡Furia inminente!"
	L.first_fury_message = "¡85% - comienza la Furia!"

	L.unleashed_shadows = "Sombras desatadas"

	L.phase2_message = "¡Fase 2!"
	L.phase2_soon = "¡Fase 2 inminente!"
end

L = BigWigs:NewBossLocale("Valiona and Theralion", "esES")
if L then
	L.phase_switch = "Cambio de fase"
	L.phase_switch_desc = "Avisa los cambios de fase"

	L.phase_bar = "%s aterriza"
	L.breath_message = "¡Aliento profundo inminente!"
	L.dazzling_message = "¡Zonas espirales inminentes!"

	L.blast_message = "Explosión en caída" --Sounds better and makes more sense than Twilight Blast (the user instantly knows something is coming from the sky at them)
	L.engulfingmagic_say = "Trago de magia"

	L.valiona_trigger = "Theralion, voy a incendiar el corredor. ¡Que no escapen!"

	L.twilight_shift = "Cambio"
end

L = BigWigs:NewBossLocale("Sinestra", "esES")
if L then
	L.whelps = "Crías"
	L.whelps_desc = "Aviso para la oleada de crías."

	--L.slicer_message = "Possible Orb targets"

	L.egg_vulnerable = "¡Hora de la tortilla!"

	L.whelps_trigger = "Feed, children!  Take your fill from their meaty husks!"
	L.omelet_trigger = "You mistake this for weakness?  Fool!"

	L.phase13 = "Fase 1 y 3"
	L.phase = "Fase"
	L.phase_desc = "Avisa los cambios de fase"
end

L = BigWigs:NewBossLocale("Ascendant Council", "esES")
if L then
	L.health_report = "%s está al %d%% de vida, ¡cambio pronto!"
	L.switch = "Cambio"
	L.switch_desc = "Avisa los cambios de jefes"

	L.shield_up_message = "¡El escudo está ALTO!"
	L.shield_down_message = "¡El escudo está BAJO!"
	L.shield_bar = "Escudo"

	L.switch_trigger = "¡Nos ocuparemos de ellos!"

	L.thundershock_quake_soon = "¡%s en 10 seg!"

	L.quake_trigger = "El suelo bajo tus pies empieza a temblar ominosamente..."
	L.thundershock_trigger = "El aire circundante chisporrotea de energía..."

	L.thundershock_quake_spam = "%s en %d"

	L.last_phase_trigger = "Una exhibición impresionante..."
end

