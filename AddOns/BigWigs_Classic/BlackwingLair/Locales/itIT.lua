local L = BigWigs:NewBossLocale("Razorgore the Untamed", "itIT")
if not L then return end
if L then
	--L.start_trigger = "Intruders have breached"

	--L.eggs = "Count Eggs"
	--L.eggs_desc = "Count the destroyed eggs."
	--L.eggs_message = "%d/30 eggs destroyed"
end

L = BigWigs:NewBossLocale("Vaelastrasz the Corrupt", "itIT")
if L then
	--L.warmup_trigger = "Too late, friends!"
	--L.tank_bomb = "Tank Bomb"
end

L = BigWigs:NewBossLocale("Chromaggus", "itIT")
if L then
	--L.breath = "Breaths"
	--L.breath_desc = "Warn for Breaths."

	--L.debuffs_message = "3/5 debuffs, carefull!"
	--L.debuffs_warning = "4/5 debuffs, %s on 5th!"
	L.bronze = "Bronzo"

	--L.vulnerability = "Vulnerability Change"
	--L.vulnerability_desc = "Warn for Vulnerability changes."
	--L.vulnerability_message = "Vulnerability: %s"
	--L.detect_magic_missing = "Detect Magic is missing from Chromaggus"
	--L.detect_magic_warning = "A Mage must cast \124cff71d5ff\124Hspell:2855:0\124h[Detect Magic]\124h\124r on Chromaggus for vulnerability warnings to work."
end

L = BigWigs:NewBossLocale("Nefarian Classic", "itIT")
if L then
	--L.engage_yell_trigger = "Let the games begin"
	--L.stage3_yell_trigger = "Impossible! Rise my"

	--L.shaman_class_call_yell_trigger = "Shamans"
	--L.deathknight_class_call_yell_trigger = "Death Knights"
	--L.monk_class_call_yell_trigger = "Monks"
	--L.hunter_class_call_yell_trigger = "Hunters"

	--L.warnshaman = "Shamans - Totems spawned!"
	--L.warndruid = "Druids - Stuck in cat form!"
	--L.warnwarlock = "Warlocks - Incoming Infernals!"
	--L.warnpriest = "Priests - Heals hurt!"
	--L.warnhunter = "Hunters - Bows/Guns broken!"
	--L.warnwarrior = "Warriors - Stuck in berserking stance!"
	--L.warnrogue = "Rogues - Ported and rooted!"
	--L.warnpaladin = "Paladins - Blessing of Protection!"
	--L.warnmage = "Mages - Incoming polymorphs!"
	--L.warndeathknight = "Death Knights - Death Grip"
	--L.warnmonk = "Monks - Stuck Rolling"
	--L.warndemonhunter = "Demon Hunters - Blinded"

	--L.classcall = "Class Call"
	--L.classcall_desc = "Warn for Class Calls."

	--L.add = "Drakonid deaths"
	--L.add_desc = "Announce the number of adds killed in stage 1 before Nefarian lands."
end

L = BigWigs:NewBossLocale("Blackwing Lair Trash", "itIT")
if L then
	L.wyrmguard_overseer = "Guardiadragoni dell'Artiglio della Morte / Sovrintendente dell'Artiglio della Morte" -- NPC 12460 / 12461
	L.sandstorm = "Tempesta di Sabbia"

	--L.target_vulnerability = "Target Vulnerability Warnings"
	--L.target_vulnerability_desc = "When your target is a Death Talon Wyrmguard or a Death Talon Overseer, show a warning for what vulnerability it has."
	--L.target_vulnerability_message = "Target Vulnerability: %s"
	--L.detect_magic_missing_message = "Detect Magic is missing from your target"
	--L.detect_magic_warning = "A Mage must cast \124cff71d5ff\124Hspell:2855:0\124h[Detect Magic]\124h\124r on your target for vulnerability warnings to work."

	L.warlock = "Stregone dell'Ala Nera" -- NPC 12459
end
