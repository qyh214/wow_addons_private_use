local L = BigWigs:NewBossLocale("Lord Marrowgar", "deDE")
if not L then return end
if L then
	L.bone_spike = "Knochenstachel" -- NPC ID 36619
end

L = BigWigs:NewBossLocale("Lady Deathwhisper", "deDE")
if L then
	L.touch = "Berührung"
	L.deformed_fanatic = "Deformierter Fanatiker" -- NPC ID 38135
	L.empowered_adherent = "Machterfüllter Kultist" -- NPC ID 38136
end

L = BigWigs:NewBossLocale("Icecrown Gunship Battle", "deDE")
if L then
	L.adds_trigger_alliance = "Häscher, Unteroffiziere, Angriff!"
	L.adds_trigger_horde = "Soldaten! Zum Angriff!"

	L.mage = "Magier"
	L.mage_desc = "Warnt, wenn ein Magier erscheint, um die Kanonen einzufrieren."
	-- Alliance: We're taking hull damage, get a battle-mage out here to shut down those cannons!
	-- Horde: We're taking hull damage, get a sorcerer out here to shut down those cannons!
	--L.mage_yell_trigger = "taking hull damage"

	L.warmup_trigger_alliance = "Alle Maschinen auf Volldampf"
	L.warmup_trigger_horde = "Erhebt Euch, Söhne und Töchter"

	L.disable_trigger_alliance = "Vorwärts, Brüder und Schwestern"
	L.disable_trigger_horde = "Vorwärts zum Lichkönig"
end

L = BigWigs:NewBossLocale("Deathbringer Saurfang", "deDE")
if L then
	L.blood_beast = "Blutbestie" --  NPC ID 38508

	L.warmup_alliance = "Dann beeilen wir uns! Brechen wir au..."
	L.warmup_horde = "Kor'kron, Aufbruch! Champions, gebt Acht. Die Geißel ist..."
end

L = BigWigs:NewBossLocale("Blood Prince Council", "deDE")
if L then
	L.switch_message = "Ziel wechseln: %s"
	L.switch_bar = "~Ziel wechseln"

	L.empowered_flames = "Machtvolle Flammen"

	L.empowered_shock_message = "Schockvortex kommt!"
	L.regular_shock_message = "Schockzone"
	L.shock_bar = "~Nächster Schock"

	L.iconprince = "Symbol auf aktivem Prinz"
	L.iconprince_desc = "Plaziert das erste Schlachtzugs-Symbol auf dem aktiven Blutprinzen (benötigt Assistent oder höher)."

	L.prison_message = "%dx Schattengefängnis!"
end

L = BigWigs:NewBossLocale("Blood-Queen Lana'thel", "deDE")
if L then
	L.engage_trigger = "Ihr habt... unklug... gewählt."

	L.shadow = "Schatten"
	L.shadow_message = "Schatten"
	L.shadow_bar = "Nächster Schatten"

	L.feed_message = "Blutdurst stillen!"

	L.pact_message = "Pakt"
	L.pact_bar = "Nächster Pakt"

	L.phase_message = "Flugphase kommt!"
	L.phase1_bar = "Zurück am Boden"
	L.phase2_bar = "Flugphase"
end

L = BigWigs:NewBossLocale("Festergut", "deDE")
if L then
	L.engage_trigger = "Zeit für Spaß?"

	L.inhale_bar = "Einatmen %d"
	L.blight_warning = "Stechende Seuche in ~5 sek!"
	L.ball_message = "Glibber!"
end

L = BigWigs:NewBossLocale("Professor Putricide", "deDE")
if L then
	L.engage_trigger = "Ich habe eine Seuche perfektioniert"

	L.phase = "Phasen"
	L.phase_desc = "Warnt vor Phasenwechsel."
	L.phase_warning = "Phase %d bald!"
	L.phase_bar = "Nächste Phase"

	L.ball_bar = "Nächster Glibber"
	L.ball_say = "Glibber auf MIR!"

	L.experiment_message = "Schlamm kommt!"
	L.experiment_heroic_message = "Schlammer kommen!"
	L.experiment_bar = "Nächster Schlamm"
	L.blight_message = "Roter Schlamm"
	L.violation_message = "Grüner Schlamm"

	L.gasbomb_bar = "Weitere Gasbomben"
	L.gasbomb_message = "Gasbomben!"
end

L = BigWigs:NewBossLocale("Rotface", "deDE")
if L then
	L.engage_trigger = "WIIIIII!"

	L.infection_message = "Infektion"

	L.ooze = "Brühschlammer verschmelzen"
	L.ooze_desc = "Warnt, wenn Brühschlammer miteinander verschmelzen."
	L.ooze_message = "%dx Brühschlammer!"

	L.spray_bar = "~Schleimsprühen"
end

L = BigWigs:NewBossLocale("Sindragosa", "deDE")
if L then
	L.engage_trigger = "Ihr seid Narren, euch hierher zu wagen. Der eisige Wind Nordends wird eure Seelen verschlingen!"

	L.phase2 = "Phase 2"
	L.phase2_desc = "Warnt, wenn Phase 2 bei 35% beginnt."
	L.phase2_trigger = "Fühlt die grenzenlose Macht meines Meisters, und verzweifelt!!"
	L.phase2_message = "Phase 2!"

	L.airphase = "Flugphase"
	L.airphase_desc = "Warnt, wenn Sindragosa abhebt."
	L.airphase_trigger = "Euer Vormarsch endet hier! Keiner wird überleben!"
	L.airphase_message = "Flugphase kommt!"
	L.airphase_bar = "Nächste Flugphase"

	L.boom_message = "Explosion!"
	L.boom_bar = "Explosion"

	L.instability_message = "%dx Instabilität!"
	L.chilled_message = "%dx Durchgefroren!"
	L.buffet_message = "%dx Puffer!"
	L.buffet_cd = "Nächster Puffer"
end

L = BigWigs:NewBossLocale("The Lich King", "deDE")
if L then
	L.warmup_trigger = "Der vielgerühmte Streiter des Lichts ist endlich hier?"
	L.engage_trigger = "Ihr bleibt bis zum Ende am Leben, Fordring."

	L.horror_message = "Torkelnder Schrecken!"
	L.horror_bar = "~Torkelnder Schrecken"

	L.valkyr_message = "Val'kyr!"
	L.valkyr_bar = "Nächsten Val'kyr"
	L.valkyrhug_message = "Val'kyren"

	L.cave_phase = "Höhlenphase"
	L.last_phase_bar = "Letzte Phase"

	L.frenzy_bar = "%s in Raserei"
	L.frenzy_survive_message = "%s wird Seuchentick überleben!"
	L.frenzy_message = "Add Raserei!"
	L.frenzy_soon_message = "5 sek bis Raserei!"

	--L.custom_on_valkyr_marker = "Val'kyr marker"
	--L.custom_on_valkyr_marker_desc = "Mark the Val'kyr with {rt8}{rt7}{rt6}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r\n|cFFADFF2FTIP: If the raid has chosen you to turn this on, quickly mousing over the Val'kyr is the fastest way to mark them.|r"
end

L = BigWigs:NewBossLocale("Valithria Dreamwalker", "deDE")
if L then
	L.engage_trigger = "Eindringlinge im Inneren Sanktum! Beschleunigt die Vernichtung des grünen Drachen!"

	L.portal = "Alptraumportale"
	L.portal_desc = "Warnt, wenn Valithria Alptraumportale öffnet."
	L.portal_message = "Portale offen!"
	L.portal_bar = "Portale kommen"
	L.portalcd_message = "Portale %d in 14 sek offen!"
	L.portalcd_bar = "Portale %d"
	L.portal_trigger = "Ich habe ein Portal in den Traum geöffnet. Darin liegt Eure Erlösung, Helden..."

	L.suppresser = "Unterdrücker erscheinen"
	L.suppresser_desc = "Warnt, wenn eine Gruppe Unterdrücker erscheint."
	L.suppresser_message = "~Unterdrücker"

	L.blazing = "Loderndes Skelett"
	L.blazing_desc = "|cffff0000Geschätzter|r Timer für die Lodernden Skelette. Dieser Timer ist wahrscheinlich ungenau, nur als Schätzung verwenden."
	L.blazing_warning = "Loderndes Skelett bald!"
end

L = BigWigs:NewBossLocale("Icecrown Citadel Trash", "deDE")
if L then
	L.deathbound_ward = "Todesgeweihter Wächter"
	L.deathspeaker_high_priest = "Hohepriester der Todessprecher" -- NPC ID 36829
	L.putricide_dogs = "Schatz & Stinki"
end
