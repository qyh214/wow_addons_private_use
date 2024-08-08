
local L = BigWigs:NewBossLocale("Occu'thar", "itIT")
if not L then return end
if L then
	L.shadows_bar = "~Ombre Roventi"
	L.destruction_bar = "<Esplosione>"
	L.eyes_bar = "~Occhi"

	L.fire_message = "Laser, Pew Pew"
	L.fire_bar = "~Laser"
end

L = BigWigs:NewBossLocale("Alizabal", "itIT")
if L then
	L.first_ability = "Spiedo o Odio"
	L.dance_message = "Lame Danzanti %d di 3"
end
