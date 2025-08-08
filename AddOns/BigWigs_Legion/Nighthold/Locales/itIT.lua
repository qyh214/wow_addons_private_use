local L = BigWigs:NewBossLocale("Skorpyron", "itIT")
if not L then return end
if L then
	--L.blue = "Blue"
	--L.red = "Red"
	--L.green = "Green"
	--L.mode = "%s Mode"
end

L = BigWigs:NewBossLocale("Chronomatic Anomaly", "itIT")
if L then
	--L.timeLeft = "%.1fs" -- s = seconds
end

L = BigWigs:NewBossLocale("Trilliax", "itIT")
if L then
	--L.yourLink = "You are linked with %s"
	--L.yourLinkShort = "Linked with %s"
	--L.imprint = "Imprint"
end

L = BigWigs:NewBossLocale("Tichondrius", "itIT")
if L then
	--L.addsKilled = "Adds killed"
	--L.gotEssence = "Got Essence"

	--L.adds_desc = "Timers and warnings for the add spawns."
	--L.adds_yell1 = "Underlings! Get in here!"
	--L.adds_yell2 = "Show these pretenders how to fight!"
end

L = BigWigs:NewBossLocale("Krosus", "itIT")
if L then
	--L.leftBeam = "Left Beam"
	--L.rightBeam = "Right Beam"

	--L.goRight = "> GO RIGHT >"
	--L.goLeft = "< GO LEFT <"

	--L.smashingBridge = "Smashing Bridge"
	--L.smashingBridge_desc = "Slams which break the bridge. You can use this option to emphasize or enable countdown."

	--L.removedFromYou = "%s removed from you" -- "Searing Brand removed from YOU!"
end

L = BigWigs:NewBossLocale("Star Augur Etraeus", "itIT")
if L then
	--L.yourSign = "Your sign"
	--L.with = "with"
	--L[205429] = "|T1391538:15:15:0:0:64:64:4:60:4:60|t|cFFFFDD00Crab|r"
	--L[205445] = "|T1391537:15:15:0:0:64:64:4:60:4:60|t|cFFFF0000Wolf|r"
	--L[216345] = "|T1391536:15:15:0:0:64:64:4:60:4:60|t|cFF00FF00Hunter|r"
	--L[216344] = "|T1391535:15:15:0:0:64:64:4:60:4:60|t|cFF00DDFFDragon|r"
end

L = BigWigs:NewBossLocale("Grand Magistrix Elisande", "itIT")
if L then
	--L.elisande = "Elisande"

	--L.ring_yell = "Let the waves of time crash over you!"
	--L.orb_yell = "You'll find time can be quite volatile."

	--L.slowTimeZone = "Slow Time Zone"
	--L.fastTimeZone = "Fast Time Zone"

	--L.boss_active = "Elisande Active"
	--L.boss_active_desc = "Time until Elisande is active after clearing the trash event."
	--L.elisande_trigger = "I foresaw your coming, of course. The threads of fate that led you to this place. Your desperate attempt to stop the Legion."
end

L = BigWigs:NewBossLocale("Gul'dan", "itIT")
if L then
	--L.warmup_trigger = "Have you forgotten" -- Have you forgotten your humiliation on the Broken Shore? How your precious high king was bent and broken before me? Will you beg for your lives as he did, whimpering like some worthless dog?

	--L.empowered = "(E) %s" -- (E) Eye of Gul'dan
	--L.gains = "Gul'dan gains %s"
	--L.p2_start = "You failed, heroes! The ritual is upon us! But first, I'll indulge myself a bit... and finish you!"
	--L.p4_mythic_start_yell = "Time to return the demon hunter's soul to his body... and deny the Legion's master a host!"

	--L.nightorb_desc = "Summons a Nightorb, killing it will spawn a Time Zone."
	--L.timeStopZone = "Time Stop Zone"

	--L.manifest_desc = "Summons a Soul Fragment of Azzinoth, killing it will spawn a Demonic Essence."

	--L.winds_desc = "Gul'dan summons Violent Winds to push the players off the platform."
end

L = BigWigs:NewBossLocale("Nighthold Trash", "itIT")
if L then
	--[[ Skorpyron to Trilliax ]]--
	L.torm = "Torm il Bruto"
	L.fulminant = "Fulminant"
	L.pulsauron = "Pulsauron"

	--[[ Chronomatic Anomaly to Trilliax ]]--
	L.sludgerax = "Poltirax"

	--[[ Trilliax to Aluriel ]]--
	L.karzun = "Kar'zun"
	L.guardian = "Guardiano Dorato"
	L.battle_magus = "Magus da Battaglia della Guardia del Vespro"
	L.chronowraith = "Cronopresenza"
	L.protector = "Protettore della Rocca della Notte"

	--[[ Aluriel to Etraeus ]]--
	L.jarin = "Astrologo Jarin"

	--[[ Aluriel to Telarn ]]--
	L.defender = "Difensore Astrale"
	L.weaver = "Tessitore della Guardia del Vespro"
	L.archmage = "Arcimaga Shal'dorei"
	L.manasaber = "Manafiera Addomesticata"
	L.naturalist = "Naturalista Shal'dorei"

	--[[ Aluriel to Krosus ]]--
	L.infernal = "Infernale Rovente"

	--[[ Aluriel to Tichondrius ]]--
	L.chaosmage = "Mago del Caos Vilfedele"
	L.watcher = "Guardiano dell'Abisso"
end
