if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

------------------------
-- White TIger Temple --
------------------------
L= DBM:GetModLocalization("d640")

L:SetMiscLocalization({
	Endless				= "Interminable",
	ReplyWhisper		= "<Deadly Boss Mods> %s está ocupado en el Terreno de Pruebas (%s, oleada %d)."
})
