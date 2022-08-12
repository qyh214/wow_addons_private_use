if GetLocale() ~= "ruRU" then
	return
end
local L

------------------------
-- White Tiger Temple --
------------------------
L = DBM:GetModLocalization("d640")

L:SetMiscLocalization({
	Endless			= "Бесконечный",--Could not find a global for this one.
	ReplyWhisper	= "<Deadly Boss Mods> %s занят на арене испытаний (Режим: %s Волна: %d)"
})

------------------------
-- Mage Tower: TANK --
------------------------
L = DBM:GetModLocalization("Kruul")

L:SetGeneralLocalization({
	name	= "Возвращение Верховного лорда"
})

------------------------
-- Mage Tower: Healer --
------------------------
L = DBM:GetModLocalization("ArtifactHealer")

L:SetGeneralLocalization({
	name	= "Последнее восстание"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactFelTotem")

L:SetGeneralLocalization({
	name	= "Падение Тотема Скверны"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactImpossibleFoe")

L:SetGeneralLocalization({
	name	= "Невероятный противник"
})

L:SetMiscLocalization({
	impServants	= "Убейте cлуг бесов, прежде чем они зарядят Агату энергией!"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactQueen")

L:SetGeneralLocalization({
	name	= "Ярость королевы-богини"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactTwins")

L:SetGeneralLocalization({
	name	= "Разделить близнецов"
})

------------------------
-- Mage Tower: DPS --
------------------------
L = DBM:GetModLocalization("ArtifactXylem")

L:SetGeneralLocalization({
	name	= "Око бури"
})

------------------------
-- N'Zoth Visions: Stormwind --
------------------------
--L= DBM:GetModLocalization("d1993")

------------------------
-- N'Zoth Visions: Orgrimmar --
------------------------
--L= DBM:GetModLocalization("d1995")

------------------------
-- Torghast --
------------------------
--L= DBM:GetModLocalization("d1963")

------------------------
-- Path of Ascension (Shadowlands)
------------------------
L = DBM:GetModLocalization("Echthra")

L:SetGeneralLocalization{
	name = "Арена Кирий: Эктра"
}

L = DBM:GetModLocalization("Nuuminuuru")

L:SetGeneralLocalization{
	name = "Арена Кирий: Нууминууру"
}

L = DBM:GetModLocalization("Splinterbark")

L:SetGeneralLocalization{
	name = "Арена Кирий: Изломанный кошмар"
}

L = DBM:GetModLocalization("CravenCorinth")

L:SetGeneralLocalization{
	name = "Арена Кирий: Малодушный Коринф"
}

L = DBM:GetModLocalization("Kalisthene")

L:SetGeneralLocalization{
	name = "Арена Кирий: Калисфена"
}

L = DBM:GetModLocalization("AlderynandMynir")

L:SetGeneralLocalization{
	name = "Арена Кирий: Альдерин и Мин'ир"
}

L = DBM:GetModLocalization("MadMortimer")

L:SetGeneralLocalization{
	name = "Арена Кирий: Безумный Мортимер"
}

L = DBM:GetModLocalization("Thrantiok")

L:SetGeneralLocalization{
	name = "Арена Кирий: Тран'тиок"
}

L = DBM:GetModLocalization("Athanos")

L:SetGeneralLocalization{
	name = "Арена Кирий: Атанос"
}

L = DBM:GetModLocalization("Azaruux")

L:SetGeneralLocalization{
	name = "Арена Кирий: Азаруукс"
}
