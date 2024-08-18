local L = BigWigs:NewBossLocale("Lord Marrowgar", "ptBR")
if not L then return end
if L then
	L.bone_spike = "Espigão Ósseo" -- NPC ID 36619
end

L = BigWigs:NewBossLocale("Lady Deathwhisper", "ptBR")
if L then
	L.touch = "Toque"
	L.deformed_fanatic = "Fanático Deformado" -- NPC ID 38135
	L.empowered_adherent = "Seguidor Investido de Poderes" -- NPC ID 38136
end

L = BigWigs:NewBossLocale("Icecrown Gunship Battle", "ptBR")
if L then
	--L.adds_trigger_alliance = "Reavers, Sergeants, attack!"
	--L.adds_trigger_horde = "Marines, Sergeants, attack!"

	--L.mage = "Mage"
	--L.mage_desc = "Warn when a mage spawns to freeze the gunship cannons."
	-- Alliance: We're taking hull damage, get a battle-mage out here to shut down those cannons!
	-- Horde: We're taking hull damage, get a sorcerer out here to shut down those cannons!
	--L.mage_yell_trigger = "taking hull damage"

	--L.warmup_trigger_alliance = "Fire up the engines"
	--L.warmup_trigger_horde = "Rise up, sons and daughters"

	--L.disable_trigger_alliance = "Onward, brothers and sisters"
	--L.disable_trigger_horde = "Onward to the Lich King"
end

L = BigWigs:NewBossLocale("Deathbringer Saurfang", "ptBR")
if L then
	L.blood_beast = "Fera Sangrenta" --  NPC ID 38508

	--L.warmup_alliance = "Let's get a move on then! Move ou..."
	--L.warmup_horde = "Kor'kron, move out! Champions, watch your backs. The Scourge have been..."
end

L = BigWigs:NewBossLocale("Blood Prince Council", "ptBR")
if L then
	--L.switch_message = "Health swap: %s"
	--L.switch_bar = "Next health swap"

	--L.empowered_flames = "Empowered Flames"

	--L.empowered_shock_message = "Casting Shock!"
	--L.regular_shock_message = "Shock zone"
	--L.shock_bar = "Next Shock"

	--L.iconprince = "Icon on active prince"
	--L.iconprince_desc = "Place the primary raid icon on the active prince (requires promoted or leader)."

	--L.prison_message = "Shadow Prison x%d!"
end

L = BigWigs:NewBossLocale("Festergut", "ptBR")
if L then
	--L.engage_trigger = "Fun time?"

	--L.inhale_bar = "Inhale (%d)"
	--L.blight_warning = "Pungent Blight in ~5sec!"
	--L.ball_message = "Goo ball incoming!"
end

L = BigWigs:NewBossLocale("Blood-Queen Lana'thel", "ptBR")
if L then
	--L.engage_trigger = "You have made an... unwise... decision."

	--L.shadow = "Shadows"
	--L.shadow_message = "Shadows"
	--L.shadow_bar = "Next Shadows"

	--L.feed_message = "Time to feed soon!"

	--L.pact_message = "Pact"
	--L.pact_bar = "Next Pact"

	--L.phase_message = "Air phase incoming!"
	--L.phase1_bar = "Back on floor"
	--L.phase2_bar = "Air phase"
end

L = BigWigs:NewBossLocale("The Lich King", "ptBR")
if L then
	--L.warmup_trigger = "So the Light's vaunted justice has finally arrived"
	--L.engage_trigger = "I'll keep you alive to witness the end, Fordring."

	--L.horror_message = "Shambling Horror"
	--L.horror_bar = "Next Horror"

	--L.valkyr_message = "Val'kyr"
	--L.valkyr_bar = "Next Val'kyr"
	--L.valkyrhug_message = "Val'kyrs Hugged"

	--L.cave_phase = "Cave Phase"
	--L.last_phase_bar = "Last Phase"

	--L.frenzy_bar = "%s frenzies!"
	--L.frenzy_survive_message = "%s will survive after plague"
	--L.frenzy_message = "Add frenzied!"
	--L.frenzy_soon_message = "5sec to frenzy!"

	--L.custom_on_valkyr_marker = "Val'kyr marker"
	--L.custom_on_valkyr_marker_desc = "Mark the Val'kyr with {rt8}{rt7}{rt6}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r\n|cFFADFF2FTIP: If the raid has chosen you to turn this on, quickly mousing over the Val'kyr is the fastest way to mark them.|r"
end

L = BigWigs:NewBossLocale("Professor Putricide", "ptBR")
if L then
	--L.engage_trigger = "I think I've perfected a plague"

	--L.phase = "Phases"
	--L.phase_desc = "Warn for phase changes."
	--L.phase_warning = "Phase %d soon!"
	--L.phase_bar = "Next Phase"

	--L.ball_bar = "Next bouncing goo ball"
	--L.ball_say = "Goo ball incoming!"

	--L.experiment_message = "Ooze incoming!"
	--L.experiment_heroic_message = "Oozes incoming!"
	--L.experiment_bar = "Next ooze"
	--L.blight_message = "Red ooze"
	--L.violation_message = "Green ooze"

	--L.gasbomb_bar = "More yellow gas bombs"
	--L.gasbomb_message = "Yellow bombs!"
end

L = BigWigs:NewBossLocale("Rotface", "ptBR")
if L then
	--L.engage_trigger = "WEEEEEE!"

	--L.infection_message = "Infection"

	--L.ooze = "Ooze Merge"
	--L.ooze_desc = "Warn when an ooze merges."
	--L.ooze_message = "Ooze %dx"

	--L.spray_bar = "Next Spray"
end

L = BigWigs:NewBossLocale("Sindragosa", "ptBR")
if L then
	--L.engage_trigger = "You are fools to have come to this place."

	--L.phase2 = "Phase 2"
	--L.phase2_desc = "Warn when Sindragosa goes into phase 2, at 35%."
	--L.phase2_trigger = "Now, feel my master's limitless power and despair!"
	--L.phase2_message = "Phase 2!"

	--L.airphase = "Air phase"
	--L.airphase_desc = "Warn when Sindragosa will lift off."
	--L.airphase_trigger = "Your incursion ends here! None shall survive!"
	--L.airphase_message = "Air phase!"
	--L.airphase_bar = "Next air phase"

	--L.boom_message = "Explosion!"
	--L.boom_bar = "Explosion"

	--L.instability_message = "Unstable x%d!"
	--L.chilled_message = "Chilled x%d!"
	--L.buffet_message = "Magic x%d!"
	--L.buffet_cd = "Next Magic"
end

L = BigWigs:NewBossLocale("Valithria Dreamwalker", "ptBR")
if L then
	--L.engage_trigger = "Intruders have breached the inner sanctum. Hasten the destruction of the green dragon!"

	--L.portal = "Nightmare Portals"
	--L.portal_desc = "Warns when Valithria opens portals."
	--L.portal_message = "Portals up!"
	--L.portal_bar = "Portals inc"
	--L.portalcd_message = "Portals %d up in 14 sec!"
	--L.portalcd_bar = "Next Portals %d"
	--L.portal_trigger = "I have opened a portal into the Dream. Your salvation lies within, heroes..."

	--L.suppresser = "Suppressers spawn"
	--L.suppresser_desc = "Warns when a pack of Suppressers spawn."
	--L.suppresser_message = "Suppressers"

	--L.blazing = "Blazing Skeleton"
	--L.blazing_desc = "Blazing Skeleton |cffff0000estimated|r respawn timer. This timer may be inaccurate, use only as a rough guide."
	--L.blazing_warning = "Blazing Skeleton soon!"
end

L = BigWigs:NewBossLocale("Icecrown Citadel Trash", "ptBR")
if L then
	L.deathbound_ward = "Guardião Ata-morte"
	L.deathspeaker_high_priest = "Sumo Sacerdote Morta-voz" -- NPC ID 36829
	L.putricide_dogs = "Precioso & Inhaca"
end
