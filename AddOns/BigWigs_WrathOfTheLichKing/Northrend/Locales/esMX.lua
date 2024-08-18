local L = BigWigs:NewBossLocale("Toravon the Ice Watcher", "esMX")
if not L then return end
if L then
	L.whiteout_bar = "Tormenta de nieve %d"
	L.whiteout_message = "¡Tormenta de nieve %d pronto!"

	L.freeze_message = "Congelado"
end

L = BigWigs:NewBossLocale("Archavon the Stone Watcher", "esMX")
if L then
	--L.stomp_message = "Stomp - Charge Inc!"
	--L.stomp_warning = "Possible Stomp in ~5sec!"

	--L.charge = "Charge"
	--L.charge_desc = "Warn about Charge on players."
end

L = BigWigs:NewBossLocale("Malygos", "esMX")
if L then
	--L.sparks = "Spark Spawns"
	--L.sparks_desc = "Warns on Power Spark spawns."
	--L.sparks_message = "Power Spark spawns!"
	--L.sparks_warning = "Power Spark in ~5sec!"

	--L.sparkbuff = "Power Spark on Malygos"
	--L.sparkbuff_desc = "Warns when Malygos gets a Power Spark."
	--L.sparkbuff_message = "Malygos gains Power Spark!"

	--L.vortex = "Vortex"
	--L.vortex_desc = "Warn for Vortex in phase 1."
	--L.vortex_message = "Vortex!"
	--L.vortex_warning = "Possible Vortex in ~5sec!"
	--L.vortex_next = "Vortex Cooldown"

	--L.breath = "Deep Breath"
	--L.breath_desc = "Warn when Malygos is using Deep Breath in phase 2."
	--L.breath_message = "Deep Breath!"
	--L.breath_warning = "Deep Breath in ~5sec!"

	--L.surge = "Surge of Power"
	--L.surge_desc = "Warn when Malygos uses Surge of Power on you in phase 3."
	--L.surge_you = "Surge of Power on YOU!"
	--L.surge_trigger = "%s fixes his eyes on you!"

	--L.phase = "Phases"
	--L.phase_desc = "Warn for phase changes."
	--L.phase2_warning = "Phase 2 soon!"
	--L.phase2_trigger = "I had hoped to end your lives quickly"
	--L.phase2_message = "Phase 2 - Nexus Lord & Scion of Eternity!"
	--L.phase2_end_trigger = "ENOUGH! If you intend to reclaim Azeroth's magic"
	--L.phase3_warning = "Phase 3 soon!"
	--L.phase3_trigger = "Now your benefactors make their"
	--L.phase3_message = "Phase 3!"
end

L = BigWigs:NewBossLocale("Sartharion", "esMX")
if L then
	L.engage_trigger = "Mi tarea es cuidar de estos huevos. ¡Te carbonizaré antes que le causes algún daño!"
	L.tsunami_trigger = "¡La lava se arremolina alrededor de %s!"
	L.twilight_trigger_vesperon = "¡Un discípulo de Vesperon aparece en el Crepúsculo!"
	L.twilight_trigger_shadron = "¡Un discípulo de Shadron aparece en el Crepúsculo!"

	--L.drakes = "Drake Adds"
	--L.drakes_desc = "Warn when each drake add will join the fight."

	-- Adds
	L.shadron = "Shadron"
	L.tenebron = "Tenebron"
	L.vesperon = "Vesperon"
	L.lava_blaze = "Llamarada de lava" -- NPC 30643
	L.acolyte_shadron = "Acólito de Shadron" -- NPC 31218
	L.acolyte_vesperon = "Acólito de Vesperon" -- NPC 31219
end

L = BigWigs:NewBossLocale("Emalon the Storm Watcher", "esMX")
if L then
	--L.overcharge_message = "A minion is overcharged!"
	--L.overcharge_bar = "Explosion"

	--L.custom_on_overcharge_mark = "Overcharge marker"
	--L.custom_on_overcharge_mark_desc = "Place the {rt8} marker on the overcharged minion, requires promoted or leader."
end

L = BigWigs:NewBossLocale("Koralon the Flame Watcher", "esMX")
if L then
	--L.breath_bar = "Breath %d"
	--L.breath_message = "Breath %d soon!"
end

L = BigWigs:NewBossLocale("Onyxia", "esMX")
if L then
	L.phase1_trigger = "Qué casualidad"
	L.phase2_trigger = "desde arriba"
	L.phase3_trigger = "Parece ser que van a necesitar otra lección"

	L.deep_breath = "Aliento profundo"
end
