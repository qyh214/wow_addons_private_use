if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then
	return
end
local L

--------------------------
-- Señor supremo Kazzak --
--------------------------
L = DBM:GetModLocalization(1452)

L:SetMiscLocalization({
	Pull	= "¡Os enfrentáis al poder de la Legión Ardiente!"
})
