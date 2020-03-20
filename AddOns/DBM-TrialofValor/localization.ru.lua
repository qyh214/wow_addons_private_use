if GetLocale() ~= "ruRU" then return end

local L

---------------------------
-- Guarm --
---------------------------
L= DBM:GetModLocalization(1830)

L:SetOptionLocalization({
	YellActualRaidIcon		= "Change all DBM yells for foam to say icon set on player instead of matching colors (Requires raid leader)",--Translate
	FilterSameColor			= "Do not set icons, yell, or give special warning for Foams if they match players existing color"--Translate
})

---------------------------
-- Helya --
---------------------------
L= DBM:GetModLocalization(1829)

L:SetTimerLocalization({
	OrbsTimerText		= "След. Сфера (%d-%s)"
})

L:SetMiscLocalization({
	phaseThree =	"Your efforts are for naught, mortals! Odyn will NEVER be free!",
	near =			"Возле",
	far =			"Вдалеке",
	multiple =		"множественный"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("TrialofValorTrash")

L:SetGeneralLocalization({
	name =	"Trial of Valor Trash"
})
