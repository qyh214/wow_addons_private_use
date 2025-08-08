local L = BigWigs:NewBossLocale("MOTHER", "itIT")
if not L then return end
if L then
	L.sideLaser = "(Lati) Raggi" -- short for: (location) Uldir Defensive Beam
	L.upLaser = "(Soffitto) Raggi"
	L.mythic_beams = "Raggi"
end

L = BigWigs:NewBossLocale("Zek'voz, Herald of N'zoth", "itIT")
if L then
	L.surging_darkness_eruption = "Eruzione (%d)"
	L.mythic_adds = "Add Mitico"
	L.mythic_adds_desc = "Mostra timer per l'apparizione degli add in modalità Mitica (Guerriero Silitide e Tessitore del Vuoto Nerubiano arrivano nello stesso istante)."
end

L = BigWigs:NewBossLocale("Zul", "itIT")
if L then
	L.crawg_msg = "Crog" -- Short for 'Bloodthirsty Crawg'
	L.crawg_desc = "Avvisi e timer per l'arrivo del Crog Sanguinario."

	L.bloodhexer_msg = "Sanguemalefico" -- Short for 'Nazmani Bloodhexer'
	L.bloodhexer_desc = "Avvisi e timer per l'arrivo del Sanguemalefico Nazmani."

	L.crusher_msg = "Frantumatrice" -- Short for 'Nazmani Crusher'
	L.crusher_desc = "Avvisi e timer per l'arrivo della Frantumatrice Nazmani."

	L.custom_off_decaying_flesh_marker = "Marcatore Carne in Decomposizione"
	L.custom_off_decaying_flesh_marker_desc = "Evidenzia le forze nemiche affette da Carne in Decomposizione con {rt8}, richiede assistente o capoincursione."
end

L = BigWigs:NewBossLocale("Mythrax the Unraveler", "itIT")
if L then
	L.destroyer_cast = "%s (Distruttore N'raq)" -- npc id: 139381
	L.xalzaix_returned = "Xalzaix è tornato!" -- npc id: 138324
	L.add_blast = "Detonazione Add"
	L.boss_blast = "Detonazione Boss"
end

L = BigWigs:NewBossLocale("G'huun", "itIT")
if L then
	L.orbs_deposited = "Sfere Depositate (%d/3) - %.1f sec"
	L.orb_spawning = "Apparizione Sfere"
	L.orb_spawning_side = "Apparizione Sfere (%s)"
	L.left = "Sinistra"
	L.right = "Destra"

	L.custom_on_fixate_plates = "Icona Inseguimento su nameplate nemico"
	L.custom_on_fixate_plates_desc = "Mostra un'icona sul nameplate del target che ti sta inseguimendo.\nUso dei nameplates nemici richiesto. Questa funzionalità è supportata solo da KuiNameplates."
end

L = BigWigs:NewBossLocale("Uldir Trash", "itIT")
if L then
	L.watcher = "Guardiano Corrotto"
	L.ascendant = "Ascesa Nazmani"
	L.dominator = "Dominatrice Nazmani"
end
