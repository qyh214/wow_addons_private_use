local L = BigWigs:NewBossLocale("Battle of Dazar'alor Trash", "itIT")
if not L then return end
if L then
	L.prelate = "Prelato Akk'al"
	L.flamespeaker = "Oratore delle Fiamme Rastari"
	L.hulk = "Colosso Risorto"
	L.enforcer = "Scagnozzo Eterno"
	L.punisher = "Punitore Rastari"
	L.vessel = "Ricettacolo di Bwonsamdi"

	L.victim = "%s ha pugnalato TE con %s!"
	L.witness = "%s pugnala %s con %s!"
end

L = BigWigs:NewBossLocale("Jadefire Masters Horde", "itIT")
if L then
	L.custom_on_fixate_plates = "Icona Inseguimento su nameplate nemico"
	L.custom_on_fixate_plates_desc = "Mostra un'icona sul nameplate del target vittima di inseguimento.\nUso dei nameplates nemici richiesto. Questa funzionalità è supportata solo da KuiNameplates."

	L.absorb = "Assorbimento"
	L.absorb_text = "%s (|cff%s%.0f%%|r)"
	L.cast = "Lancio"
	L.cast_text = "%.1fs (|cff%s%.0f%%|r)"

	L.interrupted_after = "%s interrotto da %s (%.1f secondi al termine)"
end

L = BigWigs:NewBossLocale("Jadefire Masters Alliance", "itIT")
if L then
	L.custom_on_fixate_plates = "Icona Inseguimento su nameplate nemico"
	L.custom_on_fixate_plates_desc = "Mostra un'icona sul nameplate del target che ti sta inseguimendo.\nUso dei nameplates nemici richiesto. Questa funzionalità è supportata solo da KuiNameplates."

	L.absorb = "Assorbimento"
	L.absorb_text = "%s (|cff%s%.0f%%|r)"
	L.cast = "Lancio"
	L.cast_text = "%.1fs (|cff%s%.0f%%|r)"

	L.interrupted_after = "%s interrotto da %s (%.1f secondi rimanenti)"
end

L = BigWigs:NewBossLocale("Opulence", "itIT")
if L then
	L.room = "Stanza (%d/8)"
	L.no_jewel = "No Gioielli:"

	L.custom_on_fade_out_bars = "Dissolvi barre Fase 1"
	L.custom_on_fade_out_bars_desc = "Dissolvi le barre che si riferiscono al costrutto non presente nella tua stanza durante la fase 1."

	L.custom_on_hand_timers = "Mano di In'zashi"
	L.custom_on_hand_timers_desc = "Mostra avvisi e barre per le abilità della Mano di In'zashi."
	L.hand_cast = "Mano: %s"

	L.custom_on_bulwark_timers = "Protettore di Yalat"
	L.custom_on_bulwark_timers_desc = "Mostra avvisi e barre per le abilità di Protettore di Yalat."
	L.bulwark_cast = "Protettore: %s"
end

L = BigWigs:NewBossLocale("Conclave of the Chosen", "itIT")
if L then
	L.custom_on_fixate_plates = "Icona Marchio della Preda su nameplate nemico"
	L.custom_on_fixate_plates_desc = "Mostra un'icona sul nameplate nemico che ti sta inseguendo.\nUso dei nameplates nemici richiesto. Questa funzionalità è supportata solo da KuiNameplates."
	L.killed = "%s ucciso!"
	L.count_of = "%s (%d/%d)"
end

L = BigWigs:NewBossLocale("King Rastakhan", "itIT")
if L then
	L.leap_cancelled = "Balzo Cancellato"
end

L = BigWigs:NewBossLocale("High Tinker Mekkatorque", "itIT")
if L then
	L.gigavolt_alt_text = "Bomba"

	L.custom_off_sparkbot_marker = "Marcatore Scintillabot"
	L.custom_off_sparkbot_marker_desc = "Evidenzia gli Scintillabot con {rt4}{rt5}{rt6}{rt7}{rt8}."

	L.custom_on_repeating_shrunk_say = "Ripetizione durante Riduzione" -- Shrunk = 284168
	L.custom_on_repeating_shrunk_say_desc = "Spamma Riduzione mentre sei |cff71d5ff[Ridotto]|r. Forse la smetteranno di calpestarti."

	L.custom_off_repeating_tampering_say = "Ripetizione durante Manomissione" -- Tampering = 286105
	L.custom_off_repeating_tampering_say_desc = "Spamma il tuo nome mentre stai controllando un robot."
end

L = BigWigs:NewBossLocale("Stormwall Blockade", "itIT")
if L then
	L.killed = "%s ucciso!"

	L.custom_on_fade_out_bars = "Dissolvi barre fase 1"
	L.custom_on_fade_out_bars_desc = "Elimina le barre che si riferiscono al boss che non è attivo sulla tua barca durante la fase 1."
end

L = BigWigs:NewBossLocale("Lady Jaina Proudmoore", "itIT")
if L then
	L.starbord_ship_emote = "Un Corsaro di Kul Tiras si avvicina da tribordo!"
	L.port_side_ship_emote = "Un Corsaro di Kul Tiras si avvicina da babordo!"

	L.starbord_txt = "Nave Destra" -- tribordo
	L.port_side_txt = "Nave Sinistra" -- babordo

	L.custom_on_stop_timers = "Mostra sempre le barre delle abilità"
	L.custom_on_stop_timers_desc = "Jaina userà casualmente le abilità fuori dal tempo di recupero che lancerà successivamente. Quando questa opzione è attiva, le barre per quelle abilità restano a schermo."

	L.frozenblood_player = "%s (%d giocatori)"

	L.intermission_stage2 = "Fase 2 - %.1f sec"
end
