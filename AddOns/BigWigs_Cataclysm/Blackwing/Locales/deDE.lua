
local L = BigWigs:NewBossLocale("Magmaw", "deDE")
if not L then return end
if L then
	L.stage2_yell_trigger = "Ihr könntet tatsächlich meinen Lavawurm besiegen" -- Unfassbar! Ihr könntet tatsächlich meinen Lavawurm besiegen! Vielleicht kann ich helfen... das Zünglein an der Waage zu sein.

	L.slump = "Nach vorne schlittern"
	L.slump_desc = "Warnt vor dem nach vorne Schlittern, das das Rodeo erlaubt zu starten."
	L.slump_bar = "Rodeo"
	L.slump_message = "Yeehaa, Rodeo!"
end

L = BigWigs:NewBossLocale("Omnotron Defense System", "deDE")
if L then
	L.nef = "Lord Victor Nefarius"
	L.nef_desc = "Warnungen für Nefarians Fähigkeiten."

	L.pool_explosion = "Pool-Explosion"
	L.incinerate = "Verbrennen"
	L.flamethrower = "Flammenwerfer"
	L.lightning = "Blitzableiter"
	L.infusion = "Schattenmacht"
end

L = BigWigs:NewBossLocale("Atramedes", "deDE")
if L then
	L.obnoxious_fiend = "Nerviges Scheusal" -- NPC ID 49740
	--L.circles = "Circles"
end

L = BigWigs:NewBossLocale("Maloriak", "deDE")
if L then
	L.flames = "Flammen"
end

L = BigWigs:NewBossLocale("Nefarian", "deDE")
if L then
	L.discharge = "Blitzentladung"
	L.stage3_yell_trigger = "Ich habe versucht" -- Ich habe versucht, ein guter Gastgeber zu sein, aber ihr wollt einfach nicht sterben! Genug der Spielchen! Ich werde euch einfach... ALLE TÖTEN!
	--L.too_close = "Dragons are too close"
end
