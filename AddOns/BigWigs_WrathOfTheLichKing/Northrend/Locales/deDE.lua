local L = BigWigs:NewBossLocale("Onyxia", "deDE")
if not L then return end
if L then
	L.phase1_trigger = "Was für ein Zufall"
	L.phase2_trigger = "Diese sinnlose Anstrengung langweilt mich"
	L.phase3_trigger = "Mir scheint, dass Ihr noch eine Lektion braucht"

	L.deep_breath = "Tiefer Atem"
end

local L = BigWigs:NewBossLocale("Archavon the Stone Watcher", "deDE")
if L then
	L.stomp_message = "Stampfen - Ansturm bald!"
	L.stomp_warning = "Mögliches Stampfen in ~5 sek!"

	L.charge = "Ansturm"
	L.charge_desc = "Warnt, wenn ein Spieler angestürmt wird."
end

L = BigWigs:NewBossLocale("Emalon the Storm Watcher", "deDE")
if L then
	L.overcharge_message = "Sturmdiener überladen!"
	L.overcharge_bar = "Explosion"

	L.custom_on_overcharge_mark = "Overcharge marker"
	L.custom_on_overcharge_mark_desc = "Place the {rt8} marker on the overcharged minion, requires promoted or leader."
end

L = BigWigs:NewBossLocale("Koralon the Flame Watcher", "deDE")
if L then
	L.breath_bar = "Atem %d"
	L.breath_message = "Atem %d bald!"
end

L = BigWigs:NewBossLocale("Malygos", "deDE")
if L then
	L.sparks = "Energiefunke"
	L.sparks_desc = "Warnungen und Timer für das Erscheinen von Energiefunken."
	L.sparks_message = "Energiefunke!"
	L.sparks_warning = "Energiefunke in ~5 sek!"

	L.sparkbuff = "Energiefunke auf Malygos"
	L.sparkbuff_desc = "Warnt, sobald ein Energiefunke Malygos erreicht hat."
	L.sparkbuff_message = "Malygos bekommt Energiefunke!"

	L.vortex = "Vortex"
	L.vortex_desc = "Warnungen und Timer für Vortex in Phase 1."
	L.vortex_message = "Vortex!"
	L.vortex_warning = "Vortex in ~5 sek!"
	L.vortex_next = "~Vortex"

	L.breath = "Tiefer Atem"
	L.breath_desc = "Warnungen und Timer für Tiefer Atem (Kraftsog) in Phase 2."
	L.breath_message = "Tiefer Atem!"
	L.breath_warning = "Tiefer Atem in ~5 sek!"

	L.surge = "Kraftsog"
	L.surge_desc = "Warnt, wenn du von Kraftsog in Phase 3 betroffen ist."
	L.surge_you = "Kraftsog auf DIR!"
	L.surge_trigger = "Die Augen von %s sind auf Euch fixiert!"

	L.phase = "Phasen"
	L.phase_desc = "Warnt bei Phasenwechsel."
	L.phase2_warning = "Phase 2 bald!"
	L.phase2_trigger = "Ich hatte gehofft, eure Leben schnell zu beenden, doch ihr zeigt euch... hartnäckiger als erwartet. Nichtsdestotrotz sind eure Bemühungen vergebens. Ihr törichten, leichtfertigen Sterblichen tragt die Schuld an diesem Krieg. Ich tue, was ich tun muss, und wenn das eure Auslöschung bedeutet... dann SOLL ES SO SEIN!"
	L.phase2_message = "Phase 2, Nexuslords & Saat der Ewigkeit"
	L.phase2_end_trigger = "GENUG! Wenn ihr die Magie Azeroths zurückhaben wollt, dann sollt ihr sie bekommen!"
	L.phase3_warning = "Phase 3 bald!"
	L.phase3_trigger = "Eure Wohltäter sind eingetroffen, doch sie kommen zu spät! Die hier gespeicherten Energien reichen aus, die Welt zehnmal zu zerstören. Was, denkt ihr, werden sie mit euch machen?"
	L.phase3_message = "Phase 3"
end

L = BigWigs:NewBossLocale("Sartharion", "deDE")
if L then
	L.engage_trigger = "Meine Aufgabe ist es, über diese Eier zu wachen. Kommt ihnen zu nahe und von euch bleibt nur ein Häuflein Asche."
	L.tsunami_trigger = "Die Lava um %s brodelt!"
	L.twilight_trigger_vesperon = "Ein Vesperonjünger erscheint im Zwielicht!"
	L.twilight_trigger_shadron = "Ein Shadronjünger erscheint im Zwielicht!"

	L.drakes = "Drachen"
	L.drakes_desc = "Warnungen und Timer für den Kampfbeitritt der Drachen."

	-- Adds
	L.shadron = "Shadron"
	L.tenebron = "Tenebron"
	L.vesperon = "Vesperon"
	L.lava_blaze = "Lavaflamme" -- NPC 30643
	L.acolyte_shadron = "Akolyth von Shadron" -- NPC 31218
	L.acolyte_vesperon = "Akolyth von Vesperon" -- NPC 31219
end

L = BigWigs:NewBossLocale("Toravon the Ice Watcher", "deDE")
if L then
	L.whiteout_bar = "Schneesturm %d"
	L.whiteout_message = "Schneesturm %d bald!"

	L.freeze_message = "Eingefroren"
end
