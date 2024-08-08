
local L = BigWigs:NewBossLocale("Al'Akir", "itIT")
if not L then return end
if L then
	L.stormling = "Prole Tempestosa"
	L.stormling_desc = "Evocazione Prole Tempestosa."

	L.acid_rain = "Pioggia Acida (%d)"

	L.feedback_message = "Retroazione %dx"
end

L = BigWigs:NewBossLocale("Conclave of Wind", "itIT")
if L then
	L.gather_strength = "%s sta Raccogliendo le Forze"

	L["93059_desc"] = "Scudo Assorbimento"

	L.full_power = "Piena Energia"
	L.full_power_desc = "Avvisa quando il boss è a Piena Energia ed inizia a lanciare la sua abilità speciale."
	L.gather_strength_emote = "%s inizia a raccogliere le forze"
end

