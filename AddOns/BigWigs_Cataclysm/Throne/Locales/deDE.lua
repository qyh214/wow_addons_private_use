
local L = BigWigs:NewBossLocale("Al'Akir", "deDE")
if not L then return end
if L then
	L.stormling = "Sturmling"
	L.stormling_desc = "Warnt vor dem Beschwören der Sturmlinge."

	L.acid_rain = "Säureregen (%d)"

	L.feedback_message = "%dx Rückkopplung"
end

L = BigWigs:NewBossLocale("Conclave of Wind", "deDE")
if L then
	L.gather_strength = "%s sammelt Stärke"

	L["93059_desc"] = "Warnt, wenn Rohash Sturmschild wirkt."

	L.full_power = "Volle Stärke"
	L.full_power_desc = "Warnt, wenn die Bosse volle Stärke erreicht haben und ihre Spezialfähigkeiten wirken."
	L.gather_strength_emote = "%s beinnt von den verbliebenen"
end

