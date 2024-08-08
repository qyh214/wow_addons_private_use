
local L = BigWigs:NewBossLocale("Al'Akir", "ptBR")
if not L then return end
if L then
	L.stormling = "Tempestinhas"
	L.stormling_desc = "Invoca Tempestinha."

	L.acid_rain = "Chuva ácida (%d)"

	L.feedback_message = "%dx Retornado"
end

L = BigWigs:NewBossLocale("Conclave of Wind", "ptBR")
if L then
	L.gather_strength = "%s começou a ganhar forças"

	L["93059_desc"] = "Escudo de absorção"

	L.full_power = "Poder Máximo"
	L.full_power_desc = "Avisa quando os chefes alcanção Poder Máximo e começam a lançar as habilidades especiais."
	L.gather_strength_emote = "%s começou a ganhar forças dos Senhores do vento que cairam!"
end

