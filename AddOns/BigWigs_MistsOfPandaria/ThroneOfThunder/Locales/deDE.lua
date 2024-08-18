local L = BigWigs:NewBossLocale("Jin'rokh the Breaker", "deDE")
if not L then return end
if L then
	L.storm_duration = "Gewittersturm Dauer"
	L.storm_duration_desc = "Eine separate Leiste für die Dauer von Gewittersturm"
	L.storm_short = "Sturm"
end

L = BigWigs:NewBossLocale("Horridon", "deDE")
if L then
	L.charge_trigger = "richtet seinen Blick"
	L.door_trigger = "stürmen"
	--L.orb_trigger = "charge" -- PLAYERNAME forces Horridon to charge the Farraki door!

	L.chain_lightning_desc = "|cffff0000Nur Meldungen für Fokusziele.|r {-7124}"
	L.chain_lightning_message = "Dein Fokus wirkt Kettenblitzschlag!"
	L.chain_lightning_bar = "Fokus: Kettenblitzschlag"

	L.fireball_desc = "|cffff0000Nur Meldungen für Fokusziele.|r {-7122}"
	L.fireball_message = "Dein Fokus wirkt Feuerball!"
	L.fireball_bar = "Fokus: Feuerball"

	L.venom_bolt_volley_desc = "|cffff0000Nur Meldungen für Fokusziele.|r {-7112}"
	L.venom_bolt_volley_message = "Dein Fokus wirkt Salve!"
	L.venom_bolt_volley_bar = "Fokus: Salve"

	L.adds = "Adds erscheinen"
	L.adds_desc = "Warnungen für das Erscheinen der Farraki, Gurubashi, Drakkari, Amani und des Kriegsgottes Jalak."

	L.door_opened = "Tor geöffnet!"
	L.door_bar = "Nächstes Tor (%d)"
	L.balcony_adds = "Adds von oben"
	L.orb_message = "Kugel der Kontrolle gefallen!"
end

L = BigWigs:NewBossLocale("Council of Elders", "deDE")
if L then
	L.priestess_adds = "Priesterin Adds"
	L.priestess_adds_desc = "Warnungen, wenn Hohepriesterin Mar'li beginnt, Adds zu beschwören."
	L.priestess_adds_message = "Priesterin Add"

	L.custom_on_markpossessed = "Verstärkten Boss markieren"
	L.custom_on_markpossessed_desc = "Markiert den von Gara'jal verstärkten Boss mit einem Totenkopf."

	--L.priestess_heal = "%s was healed!"
	L.assault_stun = "Tank betäubt!"
	L.assault_message = "Kalte Angriffe"
	L.full_power = "Volle Energie"
	L.hp_to_go_power = "Noch %d%% HP! (Energie: %d)"
	L.hp_to_go_fullpower = "Noch %d%% HP! (Volle Energie)"
end

L = BigWigs:NewBossLocale("Tortos", "deDE")
if L then
	L.bats_desc = "Warnungen für die beschwörten Fledermäuse."

	L.kick = "Unterbrechen"
	L.kick_desc = "Anzeigen, wie viele Schildkröten unterbrochen werden können"
	L.kick_message = "Unterbrechbare Schildkröten: %d"
	L.kicked_message = "%s hat gekickt! (%d verbleiben)"

	L.custom_off_turtlemarker = "Schildkröten markieren"
	L.custom_off_turtlemarker_desc = "Markiert die Schildkröten mit allen Raidsymbolen.\n|cFFFF0000Um Konflikte beim Markieren zu vermeiden, sollte lediglich 1 Person im Raid diese Option aktivieren.|r\n|cFFADFF2FTIPP: Wenn Du diese Option aktivierst, ist die schnellste Methode zum Markieren das zügige Bewegen des Mauszeigers über alle Schildkröten.|r"

	L.no_crystal_shell = "KEIN Kristallpanzer!"
end

L = BigWigs:NewBossLocale("Megaera", "deDE")
if L then
	L.breaths = "Atem"
	L.breaths_desc = "Warnungen zu den verschiedenen Atem."

	L.arcane_adds = "Arkane Adds"
end

L = BigWigs:NewBossLocale("Ji-Kun", "deDE")
if L then
	L.first_lower_hatch_trigger = "Die Eier in einem der unteren Nester beginnen, aufzubrechen!"
	L.lower_hatch_trigger = "Die Eier in einem der unteren Nester beginnen, aufzubrechen!"
	L.upper_hatch_trigger = "Die Eier in einem der oberen Nester beginnen, aufzubrechen!"

	L.nest = "Nester"
	L.nest_desc = "Warnungen für die Nester.\n|cFFADFF2FTIPP: Schalte diese Warnungen aus, wenn Du nicht für die Nester eingeteilt bist.|r"

	L.flight_over = "Flug in %d Sek vorbei!"
	L.upper_nest = "|cff008000Oberes|r Nest"
	L.lower_nest = "|cffff0000Unteres|r Nest"
	L.up = "|cff008000HOCH|r"
	L.down = "|cffff0000RUNTER|r"
	L.add = "Add"
	L.big_add_message = "Großes Add in %s"
end

L = BigWigs:NewBossLocale("Durumu the Forgotten", "deDE")
if L then
	L.red_spawn_trigger = "purpurroten Nebel"
	L.blue_spawn_trigger = "azurblauen Nebel"
	L.yellow_spawn_trigger = "goldgelben Nebel"

	L.adds = "Erscheinende Adds"
	L.adds_desc = "Warnungen für das Erscheinen der purpurroten, goldgelben und azurblauen Nebel. Gibt an, wie viele Nebel verbleiben."

	L.custom_off_ray_controllers = "Kontrollierer der Lichtstrahlen"
	L.custom_off_ray_controllers_desc = "Verwenden der {rt1}{rt7}{rt6} Schlachtzugsmarkierungen auf Spieler, welche die Erscheinungsorte sowie Bewegungen der Lichtstrahlen kontrollieren."

	L.custom_off_parasite_marks = "Dunkle Parasiten markieren"
	L.custom_off_parasite_marks_desc = "Um Heilzuteilungen zu erleichtern werden die Ziele der dunklen Parasiten mit {rt3}{rt4}{rt5} markiert."

	L.initial_life_drain = "Anfänglicher Lebensentzug"
	L.initial_life_drain_desc = "Nachricht für den anfänglichen Lebensentzug anzeigen, um die erhaltene Heilung durch Verringerung des Schwächungszaubers zu reduzieren."

	L.life_drain_say = "%dx Entzug"

	L.rays_spawn = "Lichtstrahlen erscheinen"
	L.red_add = "|cffff0000Rotes|r Add"
	L.blue_add = "|cff0000ffBlaues|r Add"
	L.yellow_add = "|cffffff00Gelbes|r Add"
	L.death_beam = "Desintegrationsstrahl"
	L.red_beam = "|cffff0000Roter|r Strahl"
	L.blue_beam = "|cff0000ffBlauer|r Strahl"
	L.yellow_beam = "|cffffff00Gelber|r Strahl"
end

L = BigWigs:NewBossLocale("Primordius", "deDE")
if L then
	L.mutations = "Mutationen |cff008000(%d)|r |cffff0000(%d)|r"
	L.acidic_spines = "Säurestachel (Spritz-Schaden)"
end

L = BigWigs:NewBossLocale("Dark Animus", "deDE")
if L then
	L.engage_trigger = "Die Kugel explodiert!"

	L.matterswap_desc = "Ein Spielercharakter mit 'Materientausch' ist weit von Euch entfernt. Wenn der Effekt gebannt wird, tauscht Ihr Eure Positionen."
	L.matterswap_message = "Du bist am weitesten für Materientausch entfernt!"

	L.siphon_power = "Anima entziehen (%d%%)"
	L.siphon_power_soon = "Anima entziehen (%d%%) %s bald!"
	L.slam_message = "Schmettern"
end

L = BigWigs:NewBossLocale("Iron Qon", "deDE")
if L then
	L.molten_energy = "Geschmolzene Macht"

	L.arcing_lightning_cleared = "Kein Überspringender Blitz mehr"
end

L = BigWigs:NewBossLocale("Twin Consorts", "deDE")
if L then
	L.last_phase_yell_trigger = "Aber nur dieses eine Mal..."

	L.barrage_fired = "Beschuss abgefeuert!"
end

L = BigWigs:NewBossLocale("Lei Shen", "deDE")
if L then
	L.custom_off_diffused_marker = "Diffusionsblitze markieren"
	L.custom_off_diffused_marker_desc = "Markiert die Diffusionsblitze mit allen Raidsymbolen. Benötigt Leiter oder Assistent.\n|cFFFF0000Um Konflikte beim Markieren zu vermeiden, sollte lediglich 1 Person im Raid diese Option aktivieren.|r\n|cFFADFF2FTIPP: Wenn Du diese Option aktivierst, ist die schnellste Methode zum Markieren das zügige Bewegen des Mauszeigers über alle Adds.|r"

	L.shock_self = "Elektroschock auf DIR"
	L.shock_self_desc = "Eine Leiste für die Dauer des Elektroschock-Schwächungszaubers auf Dir anzeigen."

	L.overcharged_self = "Überladung auf DIR"
	L.overcharged_self_desc = "Eine Leiste für die Dauer des Überladung-Schwächungszaubers auf Dir anzeigen."

	L.last_inermission_ability = "Letzte Unterbrechungs-Fähigkeit genutzt!"
	L.safe_from_stun = "Du bist wahrscheinlich sicher vor Überladungs-Betäubungen"
	L.diffusion_add = "Kugelblitzelementare"
	L.shock = "Schock"
	L.static_shock_bar = "<Elektroschock-Aufteilung>"
	L.overcharge_bar = "<Überladung-Impuls>"
end

L = BigWigs:NewBossLocale("Ra-den", "deDE")
if L then
	L.vita_abilities = "Vita Fähigkeiten"
	L.anima_abilities = "Anima Fähigkeiten"
	L.worm = "Wurm"
	L.worm_desc = "Wurm beschwören"
	L.balls = "Bälle"
	L.balls_desc = "Anima- (rot) und Vita- (blau) Bälle, welche die von Ra-den verwendeten Fähigkeiten bestimmen."
	L.corruptedballs = "Korrumpierte Bälle"
	L.corruptedballs_desc = "Korrumpierte Vita- und Anima-Bälle, die entweder den verursachten Schaden (Vita) oder die maximale Gesundheit (Anima) erhöhen."
	L.unstablevitajumptarget = "Instabile Vita-Sprung-Ziel"
	L.unstablevitajumptarget_desc = "Warnen, wenn Du am weitesten von einem Spieler mit instabilen Vita entfernt bist. Wenn Du dies hervorhebst, gibt es auch einen Countdown wenn instabile Vita VON Dir weiterspringen."
	L.unstablevitajumptarget_message = "Du bist am weitesten von instabilen Vita entfernt"
	L.sensitivityfurthestbad = "Vita Sensitivität + Weit weg = |cffff0000SCHLECHT|r!"
	L.kill_trigger = "Wartet!"

	L.assistPrint = "Das kürzlich veröffentlichte Plugin 'BigWigs_Ra-denAssist' bietet weitere Hilfestellungen zu Ra-den an. Vielleicht wollt ihr es ja einmal ausprobieren."
end

L = BigWigs:NewBossLocale("Throne of Thunder Trash", "deDE")
if L then
	L.stormcaller = "Sturmrufer der Zandalari"
	L.stormbringer = "Sturmbringer Draz'kil"
	L.monara = "Monara"
	L.rockyhorror = "Krankenstein"
	L.thunderlord_guardian = "Donnerfürst / Blitzwächter"
end

