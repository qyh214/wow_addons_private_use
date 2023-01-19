if GetLocale() ~= "ruRU" then
	return
end
local L

------------
-- Protectors of the Endless --
------------
L = DBM:GetModLocalization(683)

L:SetWarningLocalization({
	warnGroupOrder		= "Ротация: группа %s",
	specWarnYourGroup	= "Ваша группа должна получить дебафф!"
})

L:SetOptionLocalization({
	warnGroupOrder		= "Объявлять ротацию для $spell:118191<br/>(Опция расчитана на стратегию для 25 человек: 5,2,2,2, и т.д.)",
	specWarnYourGroup	= "Спецпредупреждение, когда Ваша группа должна получить<br/>$spell:118191 (только для 25 человек)",
	RangeFrame			= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT:format(8, 111850) .. "<br/>(Показывает всех, если на Вас дебафф, иначе только игроков с дебаффом)",
	SetIconOnPrison		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(117436)
})

------------
-- Tsulong --
------------
L = DBM:GetModLocalization(742)

L:SetOptionLocalization({
	warnLightOfDay	= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.target:format(123716)
})

L:SetMiscLocalization{
	Victory	= "Спасибо вам, незнакомцы. Я свободен."
}

-------------------------------
-- Lei Shi --
-------------------------------
L = DBM:GetModLocalization(729)

L:SetWarningLocalization({
	warnHideOver	= "%s закончилось"
})

L:SetTimerLocalization({
	timerSpecialCD	= "Восст. Спецспособность (%d)"
})

L:SetOptionLocalization({
	warnHideOver	= "Предупреждение о появлении босса после $spell:123244",
	timerSpecialCD	= "Отсчет времени до следующей спецспособности",
	RangeFrame		= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT:format(3, 123121) .. "<br/>(Показывает всех во время $spell:123244, иначе только танков)"
})

L:SetMiscLocalization{
	Victory	= "Я... а... о! Я?.. Все было таким... мутным."--wtb alternate and less crappy victory event.
}

----------------------
-- Sha of Fear --
----------------------
L = DBM:GetModLocalization(709)

L:SetWarningLocalization({
	MoveForward					= "Пробегите через босса",
	MoveRight					= "Перейдите направо",
	MoveBack					= "Вернитесь назад",
	specWarnBreathOfFearSoon	= "Скоро дыхание страха - зайдите в конус света!"
})

L:SetTimerLocalization({
	timerSpecialAbilityCD	= "Следующая спецспособность",
	timerSpoHudCD			= "Восст. Страх / Изводень",
	timerSpoStrCD			= "Восст. Изводень / Клив",
	timerHudStrCD			= "Восст. Страх / Клив"
})

L:SetOptionLocalization({
	warnThrash					= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(131996),
	warnBreathOnPlatform		= "Предупреждать о $spell:119414, когда Вы на платформе<br/>(не рекомендуется, для рейд лидера)",
	specWarnBreathOfFearSoon	= "Предупреждать заранее о $spell:119414, если на Вас нет баффа $spell:117964",
	specWarnMovement			= "Спецпредупреждение, куда двигаться при выстрелах $spell:120047",
	timerSpecialAbility			= "Отсчет времени до следующей спецспособности на второй фазе",
	RangeFrame					= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT:format(2, 119519),
	SetIconOnHuddle				= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(120629)
})
