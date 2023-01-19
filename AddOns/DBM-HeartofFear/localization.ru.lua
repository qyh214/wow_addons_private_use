if GetLocale() ~= "ruRU" then
	return
end
local L

------------
-- Imperial Vizier Zor'lok --
------------
L = DBM:GetModLocalization(745)

L:SetWarningLocalization({
	warnEcho			= "Появилось эхо!",
	warnEchoDown		= "Эхо повержено",
	specwarnAttenuation	= "%s у %s (%s)",
	specwarnPlatform	= "Смена платформы"
})

L:SetOptionLocalization({
	warnEcho			= "Объявлять о появлении Эха",
	warnEchoDown		= "Объявлять, когда Эхо будет побеждено",
	specwarnAttenuation	= DBM_CORE_L.AUTO_SPEC_WARN_OPTIONS.spell:format(127834),
	specwarnPlatform	= "Спецпредупреждение, когда босс меняет платформу",
	ArrowOnAttenuation	= "Показывать стрелку DBM во время $spell:127834, чтобы<br/>указать в каком направлении двигаться",
	MindControlIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(122740)
})

L:SetMiscLocalization({
	Platform	= "летит к одной из своих платформ!",
	Defeat		= "Мы не погрузимся в отчаяние. Если она хочет, чтобы мы погибли – так и будет."
})

------------
-- Blade Lord Ta'yak --
------------
L = DBM:GetModLocalization(744)

L:SetOptionLocalization({
	RangeFrame			= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT:format(10, 123175)
})

-------------------------------
-- Garalon --
-------------------------------
L = DBM:GetModLocalization(713)

L:SetWarningLocalization({
	warnCrush		= "%s",
	specwarnUnder	= "Выйдите из фиолетового круга!"
})

L:SetOptionLocalization({
	warnCrush		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(122774),
	specwarnUnder	= "Спецпредупреждение, когда Вы стоите под боссом",
	PheromonesIcon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(122835)
})

L:SetMiscLocalization({
	UnderHim	= "под ним",
	Phase2		= "доспех Гаралона начинает трескаться и расползаться"
})

----------------------
-- Wind Lord Mel'jarak --
----------------------
L = DBM:GetModLocalization(741)

L:SetOptionLocalization({
	AmberPrisonIcons		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(121885),
	specWarnReinforcements	= DBM_CORE_L.AUTO_SPEC_WARN_OPTIONS.spell:format("ej6554")
})

------------
-- Amber-Shaper Un'sok --
------------
L = DBM:GetModLocalization(737)

L:SetWarningLocalization({
	warnReshapeLife				= "%s на >%s< (%d)",
	warnReshapeLifeTutor		= "1: Сбить каст/продебаффать цель (используйте это на боссе, чтобы настакать дебафф), 2: Сбить себе каст, когда кастуется Янтарный взрыв, 3: Восстановить силу воли, когда ее мало (используейте в основном на 3 фазе), 4: Выйти (только на 1 и 2 фазе)",
	warnAmberExplosion			= ">%s< кастует %s",
	warnAmberExplosionAM		= "Янтарное чудовище кастует Янтарный взрыв - Сбейте!",--personal warning.
	warnInterruptsAvailable		= "Сбить %s могут: >%s<",
	warnWillPower				= "Текущая сила воли: %s",
	specwarnWillPower			= "Низкая сила воли! - выйдите или поглотите лужу",
	specwarnAmberExplosionYou	= "Сбейте СВОЙ %s!",--Struggle for Control interrupt.
	specwarnAmberExplosionAM	= "%s: Прервать %s!",--Amber Montrosity
	specwarnAmberExplosionOther	= "%s: Прервать %s!"--Mutated Construct
})

L:SetTimerLocalization{
	timerDestabalize		= "Дестабилизация (%2$d) : %1$s",
	timerAmberExplosionAMCD	= "Восст. Взрыв: Чудовище"
}

L:SetOptionLocalization({
	warnReshapeLife				= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.target:format(122784),
	warnReshapeLifeTutor		= "Показывать назначение способностей у мутировавшего организма",
	warnAmberExplosion			= "Предупреждение (с указанием источника) о начале применения $spell:122398",
	warnAmberExplosionAM		= "Персональное предупреждение о начале применения $spell:122398 (для прерывания)",
	warnInterruptsAvailable		= "Показывать кто может сбить $spell:122402",
	warnWillPower				= "Предупреждать об уровне силы воли на 80, 50, 30, 10 и 4.",
	specwarnWillPower			= "Спецпредупреждение, когда уровень силы воли слишком низок",
	specwarnAmberExplosionYou	= "Спецпредупреждение для прерывания своего $spell:122398",
	specwarnAmberExplosionAM	= "Спецпредупреждение для прерывания $spell:122402 у Янтарного чудовища",
	specwarnAmberExplosionOther	= "Спецпредупреждение для прерывания $spell:122398 у Мутировавшего организма",
	timerDestabalize			= DBM_CORE_L.AUTO_TIMER_OPTIONS.target:format(123059),
	timerAmberExplosionAMCD		= "Отсчет времени до следующего $spell:122402 у Янтарного чудовища",
	InfoFrame					= "Показывать информационное окно для игроков с низким уровнем силы воли",
	FixNameplates				= "Автоматическое отключение мешающих неймплейтов во время построения<br/>(восстанавливает настройки после выхода из боя)"
})

L:SetMiscLocalization({
	WillPower	= "Сила воли"
})

------------
-- Grand Empress Shek'zeer --
------------
L = DBM:GetModLocalization(743)

L:SetWarningLocalization({
	warnAmberTrap	= "Прогресс создания ловушки: (%d/5)"
})

L:SetOptionLocalization({
	warnAmberTrap	= "Отображать прогресс создания $spell:125826",
	InfoFrame		= "Показывать информационное окно для игроков с $spell:125390",
	RangeFrame			= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT:format(5, 123735),
	StickyResinIcons	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(124097),
	HeartOfFearIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(123845)
})

L:SetMiscLocalization({
	PlayerDebuffs	= "Сосредоточение",
	YellPhase3		= "Больше никаких оправданий, императрица! Избавься от этих кретинов или я сам убью тебя!"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("HoFTrash")

L:SetGeneralLocalization({
	name	= "Трэш мобы Сердца Страха"
})
