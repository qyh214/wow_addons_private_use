local L = BigWigs:NewBossLocale("Auriaya", "deDE")
if not L then return end
if L then
	L.swarm_message = "Wächterschwarm"

	L.defender = "Wilder Verteidiger"
	L.defender_desc = "Warnt, wieviele Leben der Wilder Verteidiger noch hat."
	L.defender_message = "Verteidiger da %d/9!"
end

L = BigWigs:NewBossLocale("Freya", "deDE")
if L then
	L.wave = "Wellen"
	L.wave_desc = "Warnt vor den Wellen."
	L.wave_bar = "Nächste Welle"
	L.conservator_trigger = "Eonar, Eure Dienerin braucht Hilfe!"
	L.detonate_trigger = "Der Schwarm der Elemente soll über Euch kommen!"
	L.elementals_trigger = "Helft mir, Kinder!"
	L.tree_trigger = "Ein |cFF00FFFFGeschenk der Lebensbinderin|r fängt an zu wachsen!"
	L.conservator_message = "Konservator!"
	L.detonate_message = "Explosionspeitscher!"
	L.elementals_message = "Elementare!"

	L.tree = "Eonars Geschenk"
	L.tree_desc = "Warnt, wenn Eonars Geschenk auftaucht."
	L.tree_message = "Eonars Geschenk!"

	L.fury_message = "Furor"

	L.tremor_warning = "Bebende Erde bald!"
	L.tremor_bar = "~Bebende Erde"
	L.energy_message = "Instabile Energie auf DIR!"
	L.sunbeam_message = "Sonnenstrahl!"
	L.sunbeam_bar = "~Sonnenstrahl"
end

L = BigWigs:NewBossLocale("Hodir", "deDE")
if L then
	L.hardmode = "Hard Mode"
	L.hardmode_desc = "Timer für den Hard Mode."
end

L = BigWigs:NewBossLocale("Ignis the Furnace Master", "deDE")
if L then
	L.brittle_message = "Konstrukt ist spröde!"
end

L = BigWigs:NewBossLocale("The Iron Council", "deDE")
if L then
	L.stormcaller_brundir = "Sturmrufer Brundir"
	L.steelbreaker = "Stahlbrecher"
	L.runemaster_molgeim = "Runenmeister Molgeim"

	L.summoning_message = "Elementare!"

	L.chased_other = "%s wird verfolgt!"
	L.chased_you = "DU wirst verfolgt!"
end

L = BigWigs:NewBossLocale("Kologarn", "deDE")
if L then
	L.arm = "Arm stirbt"
	L.arm_desc = "Warnung und Timer für das Sterben des linken & rechten Arms."
	L.left_dies = "Linker Arm stirbt!"
	L.right_dies = "Rechter Arm stirbt!"
	L.left_wipe_bar = "Neuer linker Arm"
	L.right_wipe_bar = "Neuer rechter Arm"

	L.eyebeam = "Fokussierter Augenstrahl"
	L.eyebeam_desc = "Warnt, wenn du von Fokussierter Augenstrahl betroffen bist."
end

L = BigWigs:NewBossLocale("Mimiron", "deDE")
if L then
	L.phase = "Phasen"
	L.phase_desc = "Warnt bei Phasenwechsel."
	L.engage_warning = "Phase 1"
	L.engage_trigger = "^Wir haben nicht viel Zeit, Freunde!"
	L.phase2_warning = "Phase 2"
	L.phase2_trigger = "WUNDERBAR! Das sind Ergebnisse nach meinem Geschmack! Integrität der Hülle bei 98,9 Prozent! So gut wie keine Dellen! Und weiter geht's."
	L.phase3_warning = "Phase 3"
	L.phase3_trigger = "^Danke Euch, Freunde! Eure Anstrengungen haben fantastische Daten geliefert!"
	L.phase4_warning = "Phase 4"
	L.phase4_trigger = "Vorversuchsphase abgeschlossen. Jetzt kommt der eigentliche Test!"
	L.phase_bar = "Phase %d"

	L.hardmode_trigger = "^Warum habt Ihr das denn jetzt gemacht?"

	L.plasma_warning = "Wirkt Plasmaeruption!"
	L.plasma_soon = "Plasmaeruption bald!"
	L.plasma_bar = "Plasmaeruption"

	L.shock_next = "~Schockschlag"

	L.laser_soon = "Lasersalve!"
	L.laser_bar = "Lasersalve"

	L.magnetic_message = "Einheit am Boden!"

	L.suppressant_warning = "Löschschaum kommt!"

	L.fbomb_bar = "~Frostbombe"

	L.bomb_message = "Bombenbot!"
end

L = BigWigs:NewBossLocale("Razorscale", "deDE")
if L then
	L.ground_trigger = "Beeilt Euch! Sie wird nicht lange am Boden bleiben!"
	L.ground_message = "Angekettet!"
	L.air_message = "Hebt ab!"

	L.harpoon = "Harpunengeschütze"
	L.harpoon_desc = "Warnungen und Timer für die Harpunengeschütze."
	L.harpoon_message = "Harpunengeschütz %d bereit!"
	L.harpoon_trigger = "Harpunengeschütz ist einsatzbereit!"
	L.harpoon_nextbar = "Geschütz %d"
end

L = BigWigs:NewBossLocale("Thorim", "deDE")
if L then
	L.phase2_trigger = " Eindringlinge! Ihr Sterblichen, die Ihr es wagt, Euch in mein Vergnügen einzumischen, werdet... Wartet... Ihr..." -- space in the beginning!
	L.phase3_trigger = "Ihr unverschämtes Geschmeiß! Ihr wagt es, mich in meinem Refugium herauszufordern? Ich werde Euch eigenhändig zerschmettern!"

	L.hardmode = "Hard Mode"
	L.hardmode_desc = "Timer für den Hard Mode."
	L.hardmode_warning = "Hard Mode beendet!"

	L.barrier_message = "Runenbarriere oben!"

	L.charge_message = "Blitzladung x%d!"
	L.charge_bar = "Blitzladung %d"
end

L = BigWigs:NewBossLocale("General Vezax", "deDE")
if L then
	L.surge_bar = "Sog %d"

	L.animus = "Saronitanimus"
	L.animus_desc = "Warnt, wenn ein Saronitanimus auftaucht."
	L.animus_trigger = "Die Saronitdämpfe sammeln sich, wirbeln heftig herum und verschmelzen zu einer monströsen Form!"
	L.animus_message = "Saronitanimus kommt!"

	L.vapor = "Saronitdämpfe"
	L.vapor_desc = "Warnung und Timer für das Auftauchen von Saronitdämpfen."
	L.vapor_message = "Saronitdämpfe %d!"
	L.vapor_bar = "Saronitdämpfe"
	L.vapor_trigger = "Eine Wolke Saronitdämpfe bildet sich in der Nähe!"

	L.vaporstack = "Saronitdämpfe Stapel"
	L.vaporstack_desc = "Warnt, wenn du 5 oder mehr Stapel der Saronitdämpfe hast."
	L.vaporstack_message = "Saronitdämpfe x%d!"

	L.crash_say = "Schattengeschoss"

	L.mark_message = "Mal"
end

L = BigWigs:NewBossLocale("XT-002 Deconstructor", "deDE")
if L then
	L.lightbomb_other = "Licht"
end

L = BigWigs:NewBossLocale("Yogg-Saron", "deDE")
if L then
	L.engage_trigger = "^Bald ist die Zeit"
	L.phase2_trigger = "^Ich bin der strahlende Traum"
	L.phase3_trigger = "^Erblickt das wahre Antlitz des Todes"

	L.portal = "Portale"
	L.portal_desc = "Warnt, wenn Portale erscheinen."
	L.portal_message = "Portale offen!"
	L.portal_bar = "Nächsten Portale"

	L.fervor_message = "Eifer auf %s!"

	L.sanity_message = "DU wirst verrückt!"

	L.weakened = "Geschwächt"
	L.weakened_desc = "Warnt, wenn Yogg-Saron geschwächt ist."
	L.weakened_message = "%s ist geschwächt!"

	L.madness_warning = "Wahnsinn in 10 sek!"
	L.malady_message = "Geisteskrank" -- short for Malady of the Mind (63830)

	L.tentacle = "Schmettertentakel"
	L.tentacle_desc = "Warnung und Timer für das Auftauchen der Schmettertentakel."
	L.tentacle_message = "Schmettertentakel %d!"

	--L.small_tentacles = "Small Tentacles"
	--L.small_tentacles_desc = "Warn for Corruptor Tentacle and Constrictor Tentacle spawns."

	L.link_warning = "DU bist verbunden!"

	L.guardian_message = "Wächter %d!"

	L.roar_warning = "Gebrüll in 5 sek!"
	L.roar_bar = "Nächstes Gebrüll"
end
