local L = BigWigs:NewBossLocale("Al'Akir", "ruRU")
if not L then return end
if L then
	L.stormling = "Буревики"
	L.stormling_desc = "Призыв Буревиков."

	L.acid_rain = "Кислотный дождь (%d)"

	L.feedback_message = "%dx Ответная реакция"
end

L = BigWigs:NewBossLocale("Conclave of Wind", "ruRU")
if L then
	L.gather_strength = "%s Набирает Силу!"

	L["93059_desc"] = "Щит поглощает урон"

	L.full_power = "Полная сила"
	L.full_power_desc = "Сообщает когда босс достигает полной силы и начинает применять специальные способности."
	L.gather_strength_emote = "%s начинает вбирать силу оставшихся владык ветра!"
end

