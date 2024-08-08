
local L = BigWigs:NewBossLocale("Al'Akir", "frFR")
if not L then return end
if L then
	L.stormling = "Tourmentin"
	L.stormling_desc = "Prévient quand un Tourmentin est invoqué."

	L.acid_rain = "Pluie acide (%d)"

	L.feedback_message = "%dx Réaction"
end

L = BigWigs:NewBossLocale("Conclave of Wind", "frFR")
if L then
	L.gather_strength = "%s rassemble ses forces"

	L["93059_desc"] = "Bouclier d'absorption"

	L.full_power = "Puissance maximale"
	L.full_power_desc = "Prévient quand les boss atteignent leur puissance maximale et commence à incanter les techniques spéciales."
	L.gather_strength_emote = "%s commence à puiser la force des seigneurs du Vent encore présents !" -- à vérifier
end

