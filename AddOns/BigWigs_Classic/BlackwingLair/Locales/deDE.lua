local L = BigWigs:NewBossLocale("Razorgore the Untamed", "deDE")
if not L then return end
if L then
	L.start_trigger = "Eindringlinge sind in die"

	L.eggs = "Eier nicht zählen"
	L.eggs_desc = "Die zerstörten Eier nicht zählen."
	L.eggs_message = "%d/30 Eier zerstört"
end

L = BigWigs:NewBossLocale("Vaelastrasz the Corrupt", "deDE")
if L then
	L.warmup_trigger = "Zu spät, Freunde!"
	--L.tank_bomb = "Tank Bomb"
end

L = BigWigs:NewBossLocale("Chromaggus", "deDE")
if L then
	L.breath = "Atem"
	L.breath_desc = "Warnung, wenn Chromaggus seinen Atem wirkt."

	L.debuffs_message = "3/5 Debuffs, vorsicht!"
	L.debuffs_warning = "4/5 Debuffs, %s auf 5th!"
	L.bronze = "Bronze"

	L.vulnerability = "Zauber-Verwundbarkeiten"
	L.vulnerability_desc = "Warnung, wenn Chromagguss Zauber-Verwundbarkeit sich ändert."
	L.vulnerability_message = "Neue Zauber-Verwundbarkeit: %s"
	L.detect_magic_missing = "Magie entdecken is missing from Chromaggus"
	L.detect_magic_warning = "A Mage must cast \124cff71d5ff\124Hspell:2855:0\124h[Magie entdecken]\124h\124r on Chromaggus for vulnerability warnings to work."
end

L = BigWigs:NewBossLocale("Nefarian Classic", "deDE")
if L then
	--L.engage_yell_trigger = "Let the games begin"
	L.stage3_yell_trigger = "Unmöglich! Erhebt euch"

	L.shaman_class_call_yell_trigger = "Schamane, zeigt mir was"
	L.deathknight_class_call_yell_trigger = "Todesritter"
	--L.monk_class_call_yell_trigger = "Monks"
	L.hunter_class_call_yell_trigger = "Jäger und ihre lästigen"

	L.warnshaman = "Schamanen - Totems!"
	L.warndruid = "Druiden - Gefangen in Katzenform!"
	L.warnwarlock = "Hexenmeister - Höllenbestien herbeigerufen!"
	L.warnpriest = "Priester - Heilung schadet!"
	L.warnhunter = "Jäger - Angelegte Fernkampfwaffen defekt!"
	L.warnwarrior = "Krieger - Gefangen in Berserkerhaltung!"
	L.warnrogue = "Schurken - Teleportiert und festgewurzelt!"
	L.warnpaladin = "Paladine - Segen des Schutzes!"
	L.warnmage = "Magier - Verwandlung!"
	--L.warndeathknight = "Death Knights - Death Grip"
	--L.warnmonk = "Monks - Stuck Rolling"
	--L.warndemonhunter = "Demon Hunters - Blinded"

	L.classcall = "Klassenruf"
	L.classcall_desc = "Warnung vor Klassenrufen."

	L.add = "Tote Drakoniden"
	L.add_desc = "Zeigt die Anzahl der getöteten Adds in Phase 1 vor Nefarians Landung an."
end

L = BigWigs:NewBossLocale("Blackwing Lair Trash", "deDE")
if L then
	L.wyrmguard_overseer = "Wyrmwache der Todeskrallen / Aufseher der Todeskrallen" -- NPC 12460 / 12461
	L.sandstorm = "Sandsturm"

	--L.target_vulnerability = "Target Vulnerability Warnings"
	--L.target_vulnerability_desc = "When your target is a Death Talon Wyrmguard or a Death Talon Overseer, show a warning for what vulnerability it has."
	--L.target_vulnerability_message = "Target Vulnerability: %s"
	L.detect_magic_missing_message = "Magie entdecken is missing from your target"
	L.detect_magic_warning = "A Mage must cast \124cff71d5ff\124Hspell:2855:0\124h[Magie entdecken]\124h\124r on your target for vulnerability warnings to work."

	L.warlock = "Hexenmeister der Pechschwingen" -- NPC 12459
end
