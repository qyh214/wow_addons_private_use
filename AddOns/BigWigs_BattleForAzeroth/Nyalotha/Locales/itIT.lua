local L = BigWigs:NewBossLocale("Maut", "itIT")
if not L then return end
if L then
	L.stage2_over = "Fase 2 Terminata - %.1f sec"
end

L = BigWigs:NewBossLocale("Shad'har the Insatiable", "itIT")
if L then
	L.custom_on_stop_timers = "Mostra sempre le barre delle abilità"
	L.custom_on_stop_timers_desc = "Shad'har userà casualmente le abilità fuori dal tempo di recupero che lancerà successivamente. Quando questa opzione è attiva, le barre per quelle abilità restano a schermo."
end

L = BigWigs:NewBossLocale("Drest'agath", "itIT")
if L then
	L.adds_desc = "Warnings and Messages for the Eye, Tentacle and Maw of Drest'agath."
	L.adds_icon = "achievement_nzothraid_drestagath"

	L.eye_killed = "Occhio ucciso!"
	L.tentacle_killed = "Tentacolo ucciso!"
	L.maw_killed = "Fauce uccisa!"
end

L = BigWigs:NewBossLocale("Il'gynoth, Corruption Reborn", "itIT")
if L then
	L.custom_on_fixate_plates = "Icona Ossessione su nameplate nemico"
	L.custom_on_fixate_plates_desc = "Mostra un'icona sul nameplate nemico che ti sta inseguendo.\nUso dei nameplates nemici richiesto. Questa funzionalità è supportata solo da KuiNameplates."
end

L = BigWigs:NewBossLocale("Vexiona", "itIT")
if L then
	L.killed = "%s uccisa"
end

L = BigWigs:NewBossLocale("Ra-den the Despoiled", "itIT")
if L then
	L.essences = "Essenze"
	L.essences_desc = "Ra-Den attira periodicamente l'Essenza del Vuoto e della Vita dagli altri reami. Le Essenze che raggiungono Ra-Den lo potenziano con energia di quel tipo."
end

L = BigWigs:NewBossLocale("Carapace of N'Zoth", "itIT")
if L then
	L.player_membrane = "Membrana Giocatore" -- In stage 3
	L.boss_membrane = "Membrana Boss" -- In stage 3
end

L = BigWigs:NewBossLocale("N'Zoth, the Corruptor", "itIT")
if L then
	L.realm_switch = "Cambio Reame" -- When you leave the Mind of N'zoth

	L.custom_on_repeating_paranoia_say = "Ripetizione Messaggio Paranoia"
	L.custom_on_repeating_paranoia_say_desc = "Spamma un messaggio di chat di starti lontano mentre hai paranoia."

	L.gateway_yell = "Attenzione: Sala del Cuore compromessa. Rilevate prezenze ostili." -- Yelled by MOTHER to trigger mythic only stage
	-- L.gateway_open = "Gateway Open!"

	L.laser_left = "Laser (Sinistra)"
	L.laser_right = "Laser (Destra)"
end
