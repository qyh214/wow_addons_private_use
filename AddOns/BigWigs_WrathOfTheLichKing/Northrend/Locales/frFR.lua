local L = BigWigs:NewBossLocale("Onyxia", "frFR")
if not L then return end
if L then
	L.phase1_trigger = "Quelle chance !"
	L.phase2_trigger = "un seul coup !"
	L.phase3_trigger = "Il semble que vous ayez besoin d'une autre leçon, mortels !"

	L.deep_breath = "Souffle profond"
end

local L = BigWigs:NewBossLocale("Archavon the Stone Watcher", "frFR")
if L then
	L.stomp_message = "Piétinement - Empaler imminent !"
	L.stomp_warning = "Piétinement probable dans ~5 sec. !"

	L.charge = "Empaler"
	L.charge_desc = "Prévient quand un joueur subit les effets d'un Empaler."
end

L = BigWigs:NewBossLocale("Emalon the Storm Watcher", "frFR")
if L then
	L.overcharge_message = "Un séide est surchargé !"
	L.overcharge_bar = "Explosion"

	L.custom_on_overcharge_mark = "Overcharge marker"
	L.custom_on_overcharge_mark_desc = "Place the {rt8} marker on the overcharged minion, requires promoted or leader."
end

L = BigWigs:NewBossLocale("Koralon the Flame Watcher", "frFR")
if L then
	L.breath_bar = "Souffle %d"
	L.breath_message = "Souffle %d imminent !"
end

L = BigWigs:NewBossLocale("Malygos", "frFR")
if L then
	L.sparks = "Etincelle de puissance"
	L.sparks_desc = "Prévient quand une Etincelle de puissance apparait."
	L.sparks_message = "Etincelle de puissance apparue !"
	L.sparks_warning = "Etincelle de puissance dans ~5 sec. !"

	L.sparkbuff = "Etincelle de puissance sur Malygos"
	L.sparkbuff_desc = "Prévient quand Malygos récupère une Etincelle de puissance."
	L.sparkbuff_message = "Malygos gagne Etincelle de puissance !"

	L.vortex = "Vortex"
	L.vortex_desc = "Prévient de l'arrivée des Vortex."
	L.vortex_message = "Vortex !"
	L.vortex_warning = "Vortex probable dans ~5 sec. !"
	L.vortex_next = "Recharge Vortex"

	L.breath = "Inspiration profonde"
	L.breath_desc = "Prévient quand Malygos inspire profondément."
	L.breath_message = "Inspiration profonde !"
	L.breath_warning = "Inspiration profonde dans ~5 sec. !"

	L.surge = "Vague de puissance"
	L.surge_desc = "Prévient quand un joueur subit les effets de la Vague de puissance."
	L.surge_you = "Vague de puissance sur VOUS !"
	L.surge_trigger = "%s fixe le regard sur vous !"

	L.phase = "Phases"
	L.phase_desc = "Prévient quand la rencontre entre dans une nouvelle phase."
	L.phase2_warning = "Phase 2 imminente !"
	L.phase2_trigger = "Je pensais mettre rapidement fin à vos existences"
	L.phase2_message = "Phase 2 - Seigneurs du Nexus & Scions de l'Éternité !"
	L.phase2_end_trigger = "ASSEZ ! Si c'est la magie d'Azeroth que vous voulez, alors vous l'aurez !"
	L.phase3_warning = "Phase 3 imminente !"
	L.phase3_trigger = "Vos bienfaiteurs font enfin leur entrée, mais ils arrivent trop tard !"
	L.phase3_message = "Phase 3 !"
end

L = BigWigs:NewBossLocale("Sartharion", "frFR")
if L then
	L.engage_trigger = "Ces œufs sont sous ma responsabilité. Je vous ferai brûler avant de vous laisser y toucher !"
	L.tsunami_trigger = "La lave qui entoure %s bouillonne !"
	L.twilight_trigger_vesperon = "Un disciple de Vespéron apparaît dans le crépuscule !"
	L.twilight_trigger_shadron = "Un disciple d’Obscuron apparaît dans le crépuscule !"

	L.drakes = "Arrivée des drakes"
	L.drakes_desc = "Prévient quand chaque drake se joint au combat."

	-- Adds
	L.shadron = "Obscuron"
	L.tenebron = "Ténébron"
	L.vesperon = "Vespéron"
	L.lava_blaze = "Brasier de lave" -- NPC 30643
	L.acolyte_shadron = "Acolyte d'Obscuron" -- NPC 31218
	L.acolyte_vesperon = "Acolyte de Vespéron" -- NPC 31219
end

L = BigWigs:NewBossLocale("Toravon the Ice Watcher", "frFR")
if L then
	L.whiteout_bar = "Blanc aveuglant %d"
	L.whiteout_message = "Blanc aveuglant %d imminent !"

	L.freeze_message = "Sol givrant"
end
