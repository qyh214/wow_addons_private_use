local L = BigWigs:NewBossLocale("The Restless Cabal", "itIT")
if not L then return end
if L then
	L.absorb = "Assorbi"
	L.absorb_text = "%s (|cff%s%.0f%%|r)"
	L.bubble = "Bolla" -- Bolla Detenzione del Profondo
	L.cast = "Lancio"
	L.cast_text = "%.1fs (|cff%s%.0f%%|r)"
end

L = BigWigs:NewBossLocale("Uu'nat, Harbinger of the Void", "itIT")
if L then
	L.custom_on_stop_timers = "Mostra sempre barre abilità"
	L.custom_on_stop_timers_desc = "Uunat può ritardare il lancio di alcune abilità. Quando questa opzione è attiva, le barre delle rispettive abilità resteranno a schermo."

	L.absorb = "Assorbi"
	L.absorb_text = "%s (|cff%s%.0f%%|r)"
	L.bubble = "Bolla" -- Bolla Detenzione del Profondo
	L.cast = "Lancio"
	L.cast_text = "%.1fs (|cff%s%.0f%%|r)"

	L.void = "Vuoto" -- Risonanza Instabile: Vuoto
	L.ocean = "Oceano" -- Risonanza Instabile: Oceano
	L.storm = "Tempesta" -- Risonanza Instabile: Tempesta

	L.custom_on_repeating_resonance_yell = "Ripetizione Urlo Reliquie di Potere"
	L.custom_on_repeating_resonance_yell_desc = "Spamma un urlo dicendo quale Reliquia stai trasportando durante Risonanza Instabile."

	L.custom_off_repeating_resonance_say = "Ripetizione chat Risonanza Instabile"
	L.custom_off_repeating_resonance_say_desc = "Spamma le icone {rt3}{rt5}{rt6} (Vuoto, Oceano e Tempesta) nella chat per evitarle durante Risonanza Instabile."
end
