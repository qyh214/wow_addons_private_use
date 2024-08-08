
local L = BigWigs:NewBossLocale("Halfus Wyrmbreaker", "itIT")
if not L then return end
if L then
	L.strikes_message = "Assalti"
	--L.freed_message = "%s freed %s"
end

L = BigWigs:NewBossLocale("Cho'gall", "itIT")
if L then
	L.orders = "Cambio Postura"
	L.orders_desc = "Avvisi per il cambio di postura di Cho'Gall tra le fasi Ordini Fiammeggianti/dell'Ombra."

	L.worship_cooldown = "~Devozione"

	L.adherent_bar = "Add Grosso #%d"
	L.adherent_message = "Add %d in arrivo!"
	L.ooze_bar = "Ondata di melme %d"
	L.ooze_message = "Ondata di melme %d in arrivo!"

	L.tentacles_bar = "Apparizione Tentacoli"
	L.tentacles_message = "Festino discotecaro di Tentacoli!"

	L.sickness_message = "Ti senti Debilitato!"
	L.blaze_message = "Fuoco sotto di TE!!!"
	L.crash_say = "Impatto"

	L.fury_message = "Furia!"
	L.first_fury_soon = "Furia Tra Poco!"
	L.first_fury_message = "85% - Inizia la Furia!"

	L.unleashed_shadows = "Ombre Potenziate"

	L.phase2_message = "Fase 2!"
	L.phase2_soon = "Fase 2 tra poco!"
end

L = BigWigs:NewBossLocale("Valiona and Theralion", "itIT")
if L then
	L.phase_switch = "Cambio Fase"
	L.phase_switch_desc = "Avvisi per il cambio di fase."

	L.phase_bar = "%s sta atterrando"
	L.breath_message = "Respiro Profondo tra poco!"
	L.dazzling_message = "Zone Turbinanti tra poco!"

	L.blast_message = "Colpo dall'Alto" --Sounds better and makes more sense than Twilight Blast (the user instantly knows something is coming from the sky at them)
	L.engulfingmagic_say = "Inondamento"

	L.valiona_trigger = "Theralion, inonderò la sala di fiamme, impedisci che fuggano!"

	L.twilight_shift = "Cambio"
end

L = BigWigs:NewBossLocale("Sinestra", "itIT")
if L then
	L.whelps = "Draghetti"
	L.whelps_desc = "Avviso per le ondate dei draghetti."

	L.slicer_message = "Possibili bersagli del Globo"

	L.egg_vulnerable = "È L'ORA DI ROMPERE LE UOVA!"

	L.whelps_trigger = "Nutritevi piccoli! Saziatevi della loro carne!"
	L.omelet_trigger = "Credete che questa sia debolezza?  Sciocchi!"

	L.phase13 = "Fase 1 e 3"
	L.phase = "Fase"
	L.phase_desc = "Avvisi per il cambio di fase."
end

L = BigWigs:NewBossLocale("Ascendant Council", "itIT")
if L then
	L.health_report = "%s al %d%%, cambio di fase tra poco!"
	L.switch = "Cambio"
	L.switch_desc = "Avvisi per il cambio di boss."

	L.shield_up_message = "Lo Scudo è ATTIVO!"
	L.shield_down_message = "Lo Scudo è ANDATO VIA!"
	L.shield_bar = "Scudo"

	L.switch_trigger = "Ce ne occupiamo noi!"

	L.thundershock_quake_soon = "%s tra 10sec!"

	L.quake_trigger = "Il terreno sotto di te romba minacciosamente...."
	L.thundershock_trigger = "L'aria circostante scoppietta di energia...."

	L.thundershock_quake_spam = "%s in %d"

	L.last_phase_trigger = "Ecco la vostra rovina..."
end

