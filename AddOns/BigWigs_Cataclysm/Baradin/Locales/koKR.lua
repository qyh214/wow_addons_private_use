
local L = BigWigs:NewBossLocale("Occu'thar", "koKR")
if not L then return end
if L then
	L.shadows_bar = "~암흑"
	L.destruction_bar = "<폭발>"
	L.eyes_bar = "~눈"

	L.fire_message = "레이저, 퓨~ 퓨~"
	L.fire_bar = "~레이저"
end

L = BigWigs:NewBossLocale("Alizabal", "koKR")
if L then
	L.first_ability = "꿰기 또는 증오"
	L.dance_message = "칼춤 %d / 3"
end
