local L = BigWigs:NewBossLocale("The Fallen Protectors", "deDE")
if not L then return end
if L then
L["defile_you"] = "Geschändeter Boden unter Dir!"
L["defile_you_desc"] = "Warnung wenn Geschändeter Boden unter Dir ist."
L["inferno_self"] = "Infernostoß auf Dir"
L["inferno_self_bar"] = "Du explodierst!"
L["inferno_self_desc"] = "Spezieller Timer wenn Du von Infernostoß betroffen bist."
L["intermission_desc"] = "Warnt wenn die Bosse Verzweifelte Maßnahmen verwenden."
L["no_meditative_field"] = "Du bist nicht in der Blase!"

	L.custom_off_bane_marks = "Schattenwort: Unheil markieren"
	L.custom_off_bane_marks_desc = "Um bei der Einteilung zum Bannen zu helfen, werden die anfangs von Schattenwort: Unheil betroffenen Spieler mit {rt1}{rt2}{rt3}{rt4}{rt5} markiert (in dieser Reihenfolge, vielleicht werden nicht alle Symbole genutzt), benötigt Leiter oder Assistent."
end

L = BigWigs:NewBossLocale("Norushen", "deDE")
if L then
L["big_add"] = "Großes Add (%d)"
L["big_add_killed"] = "Großes Add getötet (%d)"
L["big_adds"] = "Große Adds"
L["big_adds_desc"] = "Warnungen für die Entstehung und den Tod der großen Adds."
L["warmup_trigger"] = "Nun gut, ich werde ein Feld erschaffen, das Eure Verderbnis eindämmt."
end

L = BigWigs:NewBossLocale("Sha of Pride", "deDE")
if L then
L["projection_green_arrow"] = "GRÜNER PFEIL"
L["titan_pride"] = "Titanen+Stolz: %s"

	L.custom_off_titan_mark = "Gabe der Titanen markieren"
	L.custom_off_titan_mark_desc = "Markiert Spieler, die von Gabe der Titanen betroffen sind, mit {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}, benötigt Leiter oder Assistent.\n|cFFFF0000Um Konflikte beim Markieren zu vermeiden, sollte lediglich 1 Person im Raid diese Option aktivieren.|r"

	L.custom_off_fragment_mark = "Verderbtes Fragment markieren"
	L.custom_off_fragment_mark_desc = "Markiert die Verderbten Fragmente mit {rt8}{rt7}, benötigt Leiter oder Assistent.\n|cFFFF0000Um Konflikte beim Markieren zu vermeiden, sollte lediglich 1 Person im Raid diese Option aktivieren.|r"
end

L = BigWigs:NewBossLocale("Galakras", "deDE")
if L then
L["adds_desc"] = "Zeigt an, wann neue Adds in den Kampf eintreten."
L["demolisher_message"] = "Verwüster"
L["drakes"] = "Protodrachen"
L["north_tower"] = "Nördlicher Turm"
L["north_tower_trigger"] = "Das Tor zum Nordturm ist durchbrochen!"
L["south_tower"] = "Südlicher Turm"
L["south_tower_trigger"] = "Das Tor zum Südturm ist durchbrochen!"
L["start_trigger_alliance"] = "Gut gemacht! Landungstrupps, angetreten! Infanterie nach vorn!"
L["start_trigger_horde"] = "Gute Arbeit. Die erste Kompanie ist an Land."
L["tower_defender"] = "Turmverteidiger"
L["towers"] = "Türme"
L["towers_desc"] = "Warnungen für das Durchbrechen der Tore zu den Türmen."
L["warlord_zaela"] = "Kriegsfürstin Zaela"

	L.custom_off_shaman_marker = "Schamanen markieren"
	L.custom_off_shaman_marker_desc = "Um bei der Einteilung zum Unterbrechen zu helfen, werden die Gezeitenschamanen des Drachenmals mit {rt1}{rt2}{rt3}{rt4}{rt5} markiert, benötigt Leiter oder Assistent.\n|cFFFF0000Um Konflikte beim Markieren zu vermeiden, sollte lediglich 1 Person im Raid diese Option aktivieren.|r\n|cFFADFF2FTIPP: Wenn Du diese Option aktivierst, ist die schnellste Methode zum Markieren das zügige Bewegen des Mauszeigers über die Schamanen.|r"
end

L = BigWigs:NewBossLocale("Iron Juggernaut", "deDE")
if L then
	L.custom_off_mine_marks = "Minen markieren"
	L.custom_off_mine_marks_desc = "Um bei der Einteilung zum Einstampfen zu helfen, werden die Kriecherminen mit {rt1}{rt2}{rt3} markiert, benötigt Leiter oder Assistent.\n|cFFFF0000Um Konflikte beim Markieren zu vermeiden, sollte lediglich 1 Person im Raid diese Option aktivieren.|r\n|cFFADFF2FTIPP: Wenn Du diese Option aktivierst, ist die schnellste Methode zum Markieren das zügige Bewegen des Mauszeigers über die Minen.|r"
end

L = BigWigs:NewBossLocale("Kor'kron Dark Shaman", "deDE")
if L then
L["blobs"] = "Schleim"

	L.custom_off_mist_marks = "Toxischer Nebel markieren"
	L.custom_off_mist_marks_desc = "Um bei der Einteilung zum Heilen zu helfen, werden Spieler mit Toxischem Nebel mit {rt1}{rt2}{rt3}{rt4}{rt5} markiert, benötigt Leiter oder Assistent.\n|cFFFF0000Um Konflikte beim Markieren zu vermeiden, sollte lediglich 1 Person im Raid diese Option aktivieren.|r"
end

L = BigWigs:NewBossLocale("General Nazgrim", "deDE")
if L then
	L.custom_off_bonecracker_marks = "Knochenknacker markieren"
	L.custom_off_bonecracker_marks_desc = "Um bei der Einteilung zum Heilen zu helfen, werden die von Knochenknacker betroffenen Spieler mit {rt1}{rt2}{rt3}{rt4}{rt5} markiert, benötigt Leiter oder Assistent.\n|cFFFF0000Um Konflikte beim Markieren zu vermeiden, sollte lediglich 1 Person im Raid diese Option aktivieren.|r"

	L.stance_bar = "%s(JETZT:%s)"
	L.battle = "Kampf"
	L.berserker = "Berserker"
	L.defensive = "Verteidigung"

	L.adds_trigger1 = "Verteidigt das Tor!"
	L.adds_trigger2 = "Truppen, sammelt Euch!"
	L.adds_trigger3 = "Nächste Staffel, nach vorn!"
	L.adds_trigger4 = "Krieger, im Laufschritt!"
	L.adds_trigger5 = "Kor'kron, zu mir!"
	L.adds_trigger_extra_wave = "Alle Kor'kron unter meinem Befehl, tötet sie! Jetzt!"
	L.extra_adds = "Zusätzliche Adds"
	L.final_wave = "Letzte Welle"
	L.add_wave = "%s (%s): %s"

	L.chain_heal_message = "Dein Fokusziel wirkt Kettenheilung!"

	L.arcane_shock_message = "Dein Fokusziel wirkt Arkaner Schock!"
end

L = BigWigs:NewBossLocale("Malkorok", "deDE")
if L then
	L.custom_off_energy_marks = "Verdrängte Energie markieren"
	L.custom_off_energy_marks_desc = "Um bei der Einteilung zum Bannen zu helfen, werden Spieler mit Verdrängter Energie mit {rt1}{rt2}{rt3}{rt4} markiert, benötigt Leiter oder Assistent.\n|cFFFF0000Um Konflikte beim Markieren zu vermeiden, sollte lediglich 1 Person im Raid diese Option aktivieren.|r"
end

L = BigWigs:NewBossLocale("Spoils of Pandaria", "deDE")
if L then
L["enable_zone"] = "Artefaktlagerraum"
L["start_trigger"] = "Hallo? Mikrofontest"
L["win_trigger"] = "System wird neu gestartet. Die Energieversorgung muss stabil bleiben, sonst fliegt die ganze Chose in die Luft."

	L.crates = "Kisten"
	L.crates_desc = "Nachrichten, für wie viel Energie du noch brauchst und wie viele große/mittlere/kleine Kisten das sind."
	L.full_power = "Volle Energie!"
	L.power_left = "%d übrig! (%d/%d/%d)"
end

L = BigWigs:NewBossLocale("Thok the Bloodthirsty", "deDE")
if L then
L["adds_desc"] = "Warnungen für den Kampfeintritt der Fledermäuse oder des Yetis."
L["cage_opened"] = "Käfig geöffnet"
L["npc_akolik"] = "Akolik"
L["npc_waterspeaker_gorai"] = "Wassersprecher Gorai"
end

L = BigWigs:NewBossLocale("Siegecrafter Blackfuse", "deDE")
if L then
L["assembly_line_items"] = "Waffen (%d): %s"
L["assembly_line_message"] = "Unfertige Waffen (%d)"
L["assembly_line_trigger"] = "Unfertige Waffen werden auf das Fabrikationsband befördert."
L["disabled"] = "Deaktiviert"
L["item_deathdealer"] = "Todesboten"
L["item_laser"] = "Laser"
L["item_magnet"] = "Magnet"
L["item_mines"] = "Minen"
L["item_missile"] = "Rakete"
L["laser_on_you"] = "Laser auf Dir PEW PEW!"
L["overcharged_crawler_mine"] = "Überladene Kriechermine"
L["shockwave_missile_trigger"] = "Ich präsentiere... den wunderschönen Erschütterungsraketenturm ST-03!"
L["shredder_engage_trigger"] = "Ein automatisierter Schredder nähert sich!"

	L.custom_off_mine_marker = "Minen markieren"
	L.custom_off_mine_marker_desc = "Markiert die Minen zum Einteilen der Betäubungen. (Alle Zeichen werden genutzt)"
end

L = BigWigs:NewBossLocale("Paragons of the Klaxxi", "deDE")
if L then
	L.catalyst_match = "Katalysator: |c%sSTIMMT MIT DIR ÜBEREIN|r"
	L.you_ate = "Du hast einen Parasiten gegessen (noch %d)"
	L.other_ate = "%s hat einen %sParasiten gegessen (noch %d)"
	L.parasites_up = "%d |4Parasit:Parasiten; vorhanden"
	L.dance = "%s, Tanzen!"
	L.prey_message = "Wirke Beute auf Parasiten"
	L.injection_over_soon = "Injektion bald vorbei (%s)!"

	L.one = "Iyyokuk wählt aus: Eins!"
	L.two = "Iyyokuk wählt aus: Zwei!"
	L.three = "Iyyokuk wählt aus: Drei!"
	L.four = "Iyyokuk wählt aus: Vier!"
	L.five = "Iyyokuk wählt aus: Fünf!"

	L.custom_off_edge_marks = "Brennendes Band markieren"
	L.custom_off_edge_marks_desc = "Markiert die Spieler mit Brennendem Band, basierend auf den Kalkulationen, mit {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}{rt8}, benötigt Leiter oder Assistent.\n|cFFFF0000Um Konflikte beim Markieren zu vermeiden, sollte lediglich 1 Person im Raid diese Option aktivieren.|r"
	L.edge_message = "Brennendes Band auf Dir"

	L.custom_off_parasite_marks = "Parasiten markieren"
	L.custom_off_parasite_marks_desc = "Markiert die Parasiten für Gruppenkontroll- und Beute-Einteilungen mit {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}, benötigt Leiter oder Assistent.\n|cFFFF0000Um Konflikte beim Markieren zu vermeiden, sollte lediglich 1 Person im Raid diese Option aktivieren.|r"

	L.injection_tank = "<Wirkt Injektion>"
	L.injection_tank_desc = "Timer für die Wirkzeit von Injektion auf den aktuellen Tank."
end

L = BigWigs:NewBossLocale("Garrosh Hellscream", "deDE")
if L then
L["bombardment"] = "Bombardement"
L["bombardment_desc"] = "Bombardiert Sturmwind und hinterlässt Feuer auf dem Boden. Eiserne Sterne der Kor'kron können nur während des Bombardements entstehen."
L["chain_heal_bar"] = "Fokusziel: Kettenheilung"
L["chain_heal_desc"] = "{focus}Heilt ein verbündetes Ziel um 40% ihrer maximalen Gesundheit. Springt auf nahe verbündete Ziele über."
L["chain_heal_message"] = "Dein Fokusziel wirkt Kettenheilung!"
L["clump_check_desc"] = "Prüft alle 3 Sekunden während des Bombardements, ob Spieler eng zusammenstehen, da hierdurch Eiserne Sterne der Kor'kron entstehen."
L["clump_check_warning"] = "Gruppierung gefunden, Stern kommt"
L["empowered_message"] = "%s ist jetzt mächtig!"
L["farseer_trigger"] = "Scharfseher, heilt unsere Wunden!"
L["ironstar_impact_desc"] = "Zeigt einen Timer für die Explosion der Eisernen Sterne an der jeweils gegenüberliegenden Wand."
L["ironstar_rolling"] = "Eiserner Stern rollt!"
L["manifest_rage"] = "Wut manifestieren"
L["manifest_rage_desc"] = "Wenn Garrosh 100 Energie erreicht, wirkt er zwei Sekunden lang Wut manifestieren und kanalisiert diesen Zauber dann. Während des Kanalisierens entstehen große Adds. Zieht den Eisernen Stern in Garrosh, um ihn zu betäuben und den Zauber zu unterbrechen."
L["phase_3_end_trigger"] = "Ihr glaubt GEWONNEN zu haben? BLIND seid ihr. ICH WERDE EUCH DIE AUGEN ÖFFNEN."

	L.custom_off_shaman_marker = "Scharfseher markieren"
	L.custom_off_shaman_marker_desc = "Um bei der Einteilung zum Unterbrechen zu helfen, werden die Scharfseherwolfsreiter mit {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7} markiert, benötigt Leiter oder Assistent.\n|cFFFF0000Um Konflikte beim Markieren zu vermeiden, sollte lediglich 1 Person im Raid diese Option aktivieren.|r\n|cFFADFF2FTIPP: Wenn Du diese Option aktivierst, ist die schnellste Methode zum Markieren das zügige Bewegen des Mauszeigers über die Scharfseher.|r"

	L.custom_off_minion_marker = "Diener markerieren"
	L.custom_off_minion_marker_desc = "Um bei der Unterscheidung der Diener zu helfen, werden diese mit {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}{rt8} markiert, benötigt Leiter oder Assistent."

	--L.warmup_yell_chat_trigger1 = "It is not too late, Garrosh" -- It is not too late, Garrosh. Lay down the mantle of Warchief. We can end this here, now, with no more bloodshed."
	--L.warmup_yell_chat_trigger2 = "Do you remember nothing of Honor" -- Ha! Do you remember nothing of Honor? Of glory on the battlefield?  You who would parlay with the humans, who allowed warlocks to practice their dark magics right under our feet.  You are weak.
end

