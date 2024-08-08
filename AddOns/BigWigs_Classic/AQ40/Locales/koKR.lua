local L = BigWigs:NewBossLocale("Viscidus", "koKR")
if not L then return end
if L then
	--L.freeze = "Freezing States"
	--L.freeze_desc = "Warn for the different frozen states."

	L.freeze_trigger1 = "%s|1이;가; 느려지기 시작했습니다!" -- CHECK
	L.freeze_trigger2 = "%s|1이;가; 얼어붙고 있습니다!" -- CHECK
	L.freeze_trigger3 = "%s|1이;가; 단단하게 얼었습니다!" -- CHECK
	L.freeze_trigger4 = "%s|1이;가; 분해되기 시작합니다!" -- CHECK
	L.freeze_trigger5 = "%s|1이;가; 부서질 것 같습니다!" -- CHECK

	--L.freeze_warn1 = "First freeze phase!"
	--L.freeze_warn2 = "Second freeze phase!"
	--L.freeze_warn3 = "Viscidus is frozen!"
	--L.freeze_warn4 = "Cracking up - keep going!"
	--L.freeze_warn5 = "Cracking up - almost there!"
	--L.freeze_warn_melee = "%d melee attacks - %d more to go"
	--L.freeze_warn_frost = "%d frost attacks - %d more to go"
end

L = BigWigs:NewBossLocale("Ouro", "koKR")
if L then
	--L.engage_message = "Ouro engaged! Possible Submerge in 90sec!"
	--L.possible_submerge_bar = "Possible submerge"

	--L.emerge_message = "Ouro has emerged"
	--L.emerge_bar = "Emerge"

	--L.submerge_message = "Ouro has submerged"
	--L.submerge_bar = "Submerge"

	--L.scarab = "Scarab Despawn"
	--L.scarab_desc = "Warn for Scarab Despawn."
	--L.scarab_bar = "Scarabs despawn"
end

L = BigWigs:NewBossLocale("C'Thun", "koKR")
if L then
	--L.claw_tentacle = "Claw Tentacle"
	--L.claw_tentacle_desc = "Timers for the claw tentacle."

	--L.giant_claw_tentacle = "Giant Claw"
	--L.giant_claw_tentacle_desc = "Timers for the giant claw tentacle."

	--L.eye_tentacles = "Eye Tentacles"
	--L.eye_tentacles_desc = "Timers for the 8 eye tentacles."

	--L.giant_eye_tentacle = "Giant Eye"
	--L.giant_eye_tentacle_desc = "Timers for the giant eye tentacle."

	--L.weakened_desc = "Warn for weakened state."

	--L.dark_glare_message = "%s: %s (Group %s)" -- Dark Glare: PLAYER_NAME (Group 1)
	--L.stomach = "Stomach"
	--L.tentacle = "Tentacle (%d)"
end

L = BigWigs:NewBossLocale("Ahn'Qiraj Trash", "koKR")
if L then
	L.sentinel = "아누비사스 파수병" -- NPC 15264
	L.brainwasher = "퀴라지 세뇌관" -- NPC 15247
	L.defender = "아누비사스 문지기" -- NPC 15277
	L.crawler = "집게발 베크니스" -- NPC 15240

	--L.target_buffs = "Target Buff Warnings"
	--L.target_buffs_desc = "When your target is an Anubisath Sentinel, show a warning for what buff it has."
	--L.target_buffs_message = "Target Buffs: %s"
	L.detect_magic_missing_message = "마법 감지 is missing from your target"
	L.detect_magic_warning = "A Mage must cast \124cff71d5ff\124Hspell:2855:0\124h[마법 감지]\124h\124r on your target for buff warnings to work."
end
