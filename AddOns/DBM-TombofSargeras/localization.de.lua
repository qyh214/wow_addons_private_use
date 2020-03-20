if GetLocale() ~= "deDE" then return end
local L

---------------------------
-- Mistress Sassz'ine --
---------------------------
L= DBM:GetModLocalization(1861)

L:SetOptionLocalization({
	TauntOnPainSuccess	= "Sync timers and taunt warning to Burden of Pain cast SUCCESS instead of START (for certain mythic strats where you let burden tick once on purpose, otherwise it's NOT recommended to use this options)"--translate
})

---------------------------
-- The Desolate Host --
---------------------------
L= DBM:GetModLocalization(1896)

L:SetOptionLocalization({
	IgnoreTemplarOn3Tank	= "Ignoriere Reanimierte Templer für Knochenkäfigrüstung Infofenster/Ansagen/Namensplaketten bei Verwendung von 3 oder mehr Tanks (nicht mitten im Kampf ändern, das ruiniert die Zählung)"
})

---------------------------
-- Fallen Avatar --
---------------------------
L= DBM:GetModLocalization(1873)

L:SetOptionLocalization({
	InfoFrame =	"Zeige Infofenster für Kampfübersicht"
})

L:SetMiscLocalization({
	FallenAvatarDialog	= "The husk before you was once a vessel for the might of Sargeras. But this temple itself is our prize. The means by which we will reduce your world to cinders!"--translate (trigger)
})

---------------------------
-- Kil'jaeden --
---------------------------
L= DBM:GetModLocalization(1898)

L:SetWarningLocalization({
	warnSingularitySoon		= "Rückstoß in %ds"
})

L:SetMiscLocalization({
	Obelisklasers	= "Obeliskenlaser"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("TombSargTrash")

L:SetGeneralLocalization({
	name =	"Trash des Grabmals des Sargeras"
})
