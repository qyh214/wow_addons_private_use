if GetLocale() ~= "ruRU" then
	return
end
local L

--------------------------
-- Jin'rokh the Breaker --
--------------------------
L = DBM:GetModLocalization(827)

L:SetWarningLocalization({
	specWarnWaterMove	= "Скоро %s - выйдите из Проводящей воды!"
})

L:SetOptionLocalization({
	specWarnWaterMove	= "Спецпредупреждение, если Вы стоите в $spell:138470<br/>(В случае, если скоро $spell:137313 или спадает дебафф $spell:138732)",
	RangeFrame			= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT_SHORT:format("8/4")
})

--------------
-- Horridon --
--------------
L = DBM:GetModLocalization(819)

L:SetWarningLocalization({
	warnAdds				= "%s",
	warnOrbofControl		= "Появилась сфера контроля",
	specWarnOrbofControl	= "Появилась сфера контроля!"
})

L:SetTimerLocalization({
	timerDoor	= "Следующие ворота племени",
	timerAdds	= "Следующие %s"
})

L:SetOptionLocalization({
	warnAdds				= "Объявлять, когда спрыгивают новые адды",
	warnOrbofControl		= "Предупреждение о появлении $journal:7092",
	specWarnOrbofControl	= "Спецпредупреждение о появлении $journal:7092",
	timerDoor				= "Отсчёт времени до следующей фазы ворот племени",
	timerAdds				= "Отсчёт времени до спрыгивания следующих аддов",
	SetIconOnAdds			= "Устанавливать метки на аддов, спрыгивающих с балкона",
	RangeFrame				= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT:format(5, 136480),
	SetIconOnCharge			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(136769)
})

L:SetMiscLocalization({
	newForces		= "прибывают из-за ворот",--Войска племени Амани прибывают из-за ворот племени Амани!
	chargeTarget	= "бьет хвостом!"--Хорридон останавливает свой взгляд на Тентаклюме и бьет хвостом!
})

---------------------------
-- The Council of Elders --
---------------------------
L = DBM:GetModLocalization(816)

L:SetWarningLocalization({
	specWarnPossessed	= "%s на %s - переключитесь"
})

L:SetOptionLocalization({
	warnPossessed		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.target:format(136442),
	specWarnPossessed	= DBM_CORE_L.AUTO_SPEC_WARN_OPTIONS.switch:format(136442),
	RangeFrame			= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT_SHORT:format(5),
	AnnounceCooldowns	= "Отсчитывать (до 3), какой сейчас каст $spell:137166 для рейдовых кулдаунов",
	SetIconOnBitingCold	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(136992),
	SetIconOnFrostBite	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(136922)
})

------------
-- Tortos --
------------
L = DBM:GetModLocalization(825)

L:SetWarningLocalization({
	warnKickShell			= "%s использован >%s< (осталось %d)",
	specWarnCrystalShell	= "Получите %s"
})

L:SetOptionLocalization({
	warnKickShell			= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(134031),
	specWarnCrystalShell	= "Спецпредупреждение, когда на Вас нет дебаффа $spell:137633 и более 90% здоровья",
	InfoFrame				= "Показывать информационное окно для игроков без $spell:137633",
	ClearIconOnTurtles		= "Убирать метки с $journal:7129, когда активируется $spell:133971",
	AnnounceCooldowns		= "Отсчитывать, какой сейчас каст $spell:134920 для рейдовых кулдаунов"
})

L:SetMiscLocalization({
	WrongDebuff	= "Нет %s"
})

-------------
-- Megaera --
-------------
L = DBM:GetModLocalization(821)

L:SetTimerLocalization({
	timerBreathsCD	= "Следующее дыхание"
})

L:SetOptionLocalization({
	timerBreaths			= "Отсчёт времени до следующего дыхания",
	SetIconOnCinders		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(139822),
	SetIconOnTorrentofIce	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(139889),
	AnnounceCooldowns		= "Отсчитывать какой сейчас каст Буйство для рейдовых кулдаунов",
	Never					= "Никогда",
	Every					= "Каждый (последовательно)",
	EveryTwo				= "Кулдауны, каждый 2",
	EveryThree				= "Кулдауны, каждый 3",
	EveryTwoExcludeDiff		= "Кулдауны, каждый 2 (искл. Диффузия)",
	EveryThreeExcludeDiff	= "Кулдауны, каждый 3 (искл. Диффузия)"
})

L:SetMiscLocalization({
	rampageEnds	= "Ярость Мегеры идет на убыль."
})

------------
-- Ji-Kun --
------------
L = DBM:GetModLocalization(828)

L:SetWarningLocalization({
	warnFlock			= "%s %s %s",
	specWarnFlock		= "%s %s %s",
	specWarnBigBird		= "Страж гнезда: %s",
	specWarnBigBirdSoon	= "Скоро Страж гнезда: %s"
})

L:SetTimerLocalization({
	timerFlockCD	= "Выводок (%d): %s"
})

L:SetOptionLocalization({
	warnFlock			= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.count:format("ej7348"),
	specWarnFlock		= DBM_CORE_L.AUTO_SPEC_WARN_OPTIONS.switch:format("ej7348"),
	specWarnBigBird		= DBM_CORE_L.AUTO_SPEC_WARN_OPTIONS.switch:format("ej7827"),
	specWarnBigBirdSoon	= DBM_CORE_L.AUTO_SPEC_WARN_OPTIONS.soon:format("ej7827"),
	timerFlockCD		= DBM_CORE_L.AUTO_TIMER_OPTIONS.nextcount:format("ej7348"),
	RangeFrame			= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT:format(10, 138923),
	ShowNestArrows	= "Показывать стрелку DBM при активации гнезд",
	Never			= "Никогда",
	Northeast		= "Синий - Низ & Верх СВ",
	Southeast		= "Зеленый - Низ & Верх ЮВ",
	Southwest		= "Фиолетовый/Красный - Низ ЮЗ & Верх ЮЗ(25) или Верх Центр(10)",
	West			= "Красный - Низ З & Верх Центр (только 25)",
	Northwest		= "Желтый - Низ & Верх СЗ (только 25)",
	Guardians		= "Стражи гнезда"
})

L:SetMiscLocalization({
	eggsHatch		= "гнезд начинают проклевываться!",
	Upper			= "Верхний",
	Lower			= "Нижний",
	UpperAndLower	= "Верхний и Нижний",
	TrippleD		= "Тройной (2 нижних)",
	TrippleU		= "Тройной (2 верхних)",
	NorthEast		= "|cff0000ffСВ|r",--Синий
	SouthEast		= "|cFF088A08ЮВ|r",--Зеленый
	SouthWest		= "|cFF9932CDЮЗ|r",--Фиолетовый
	West			= "|cffff0000З|r",--Красный
	NorthWest		= "|cffffff00СЗ|r",--Желтый
	Middle10		= "|cFF9932CDЦентр|r",--Фиолетовый (Центр это верх юго-запад для 10 ппл/LFR)
	Middle25		= "|cffff0000Центр|r"--Красный (Центр это верх запад для 25 ппл)
})

--------------------------
-- Durumu the Forgotten --
--------------------------
L = DBM:GetModLocalization(818)

L:SetWarningLocalization({
	warnBeamNormal				= "Лучи - |cffff0000Красный|r : >%s<, |cff0000ffСиний|r : >%s<",
	warnBeamHeroic				= "Лучи - |cffff0000Красный|r : >%s<, |cff0000ffСиний|r : >%s<, |cffffff00Желтый|r : >%s<",
	warnAddsLeft				= "Туманов осталось: %d",
	specWarnBlueBeam			= "Синий луч на Вас - избегайте движения!",
	specWarnFogRevealed			= "%s обнаружен!",
	specWarnDisintegrationBeam	= "%s (%s)"
})

L:SetOptionLocalization({
	warnBeam			= "Объявлять цели лучей",
	warnAddsLeft		= "Объявлять сколько осталось туманов",
	specWarnFogRevealed	= "Спецпредупреждение при обнаружении туманов",
	specWarnBlueBeam			= DBM_CORE_L.AUTO_SPEC_WARN_OPTIONS.spell:format(139202),
	specWarnDisintegrationBeam	= DBM_CORE_L.AUTO_SPEC_WARN_OPTIONS.spell:format("ej6882"),
	ArrowOnBeam			= "Показывать стрелку DBM во время $journal:6882, чтобы указать, в каком направлении двигаться",
	SetIconRays					= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format("ej6891"),
	SetIconLifeDrain			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(133795),
	SetIconOnParasite			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(133597),
	InfoFrame			= "Информационное окно для кол-ва стаков $spell:133795",
	SetParticle			= "Автоматически устанавливать минимальную плотность частиц на пулле<br/>(Настройка восстановится после выхода из боя)"
})

L:SetMiscLocalization({
	LifeYell	= "Похищение жизни на %s (%d)"
})

----------------
-- Primordius --
----------------
L = DBM:GetModLocalization(820)

L:SetWarningLocalization({
	warnDebuffCount	= "Прогресс мутации: %d/5 хороших и %d плохих"
})

L:SetOptionLocalization({
	warnDebuffCount		= "Показывать предупреждения о числе дебаффов, когда Вы поглощаете лужи",
	RangeFrame			= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT_SHORT:format("5/3"),
	SetIconOnBigOoze	= "Устанавливать метки на $journal:6969"
})

-----------------
-- Dark Animus --
-----------------
L = DBM:GetModLocalization(824)

L:SetWarningLocalization({
	warnMatterSwapped	= "%s: >%s< и >%s< поменялись"
})

L:SetOptionLocalization({
	warnMatterSwapped	= "Объявлять цели, измененные $spell:138618",
	SetIconOnFont		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(138707)
})

L:SetMiscLocalization({
	Pull	= "Сфера взрывается!"
})

--------------
-- Iron Qon --
--------------
L = DBM:GetModLocalization(817)

L:SetWarningLocalization({
	warnDeadZone	= "%s: %s и %s защитованы"
})

L:SetOptionLocalization({
	warnDeadZone			= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(137229),
	SetIconOnLightningStorm	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(136192),
	RangeFrame	= "Показывать динамическое окно проверки дистанции (10м.)",
	InfoFrame	= "Показывать информационное окно для игроков с $spell:136193"
})

-------------------
-- Twin Consorts --
-------------------
L = DBM:GetModLocalization(829)

L:SetWarningLocalization({
	warnNight	= "Ночная фаза",
	warnDay		= "Дневная фаза",
	warnDusk	= "Фаза сумерек"
})

L:SetTimerLocalization({
	timerDayCD	= "След. дневная фаза",
	timerDuskCD	= "След. фаза сумерек"
})

L:SetOptionLocalization({
	warnNight	= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format("ej7641"),
	warnDay		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format("ej7645"),
	warnDusk	= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format("ej7633"),
	timerDayCD	= DBM_CORE_L.AUTO_TIMER_OPTIONS.next:format("ej7645"),
	timerDuskCD	= DBM_CORE_L.AUTO_TIMER_OPTIONS.next:format("ej7633"),
	RangeFrame	= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT_SHORT:format(5)
})

L:SetMiscLocalization({
	DuskPhase	= "Мне нужна твоя сила, Лу'линь!"
})

--------------
-- Lei Shen --
--------------
L = DBM:GetModLocalization(832)

L:SetWarningLocalization({
	specWarnIntermissionSoon	= "Скоро смена фаз",
	warnDiffusionChainSpread	= "%s распространилось на >%s<"
})

L:SetTimerLocalization({
	timerConduitCD	= "Восст. первый проводник"
})

L:SetOptionLocalization({
	specWarnIntermissionSoon	= "Спецпредупреждение перед началом промежуточной фазы",
	warnDiffusionChainSpread	= "Объявлять цели распространения $spell:135991",
	timerConduitCD				= "Отсчет времени до восстановления способности первого проводника",
	RangeFrame					= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT_SHORT:format("8/6"),--Для двух разных заклинаний
	StaticShockArrow			= "Показывать стрелку DBM, когда на ком-то $spell:135695",
	OverchargeArrow				= "Показывать стрелку DBM, когда на ком-то $spell:136295",
	SetIconOnOvercharge			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(136295),
	SetIconOnStaticShock		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(135695)
})

L:SetMiscLocalization({
	StaticYell	= "Статический шок на %s (%d)"
})

------------
-- Ra-den --
------------
L = DBM:GetModLocalization(831)

L:SetWarningLocalization({
	specWarnUnstablVitaJump	= "Нестабильная жизнь перепрыгнула на Вас!"
})

L:SetOptionLocalization({
	specWarnUnstablVitaJump	= "Спецпредупреждение, когда $spell:138297 перепрыгивает на Вас",
	SetIconsOnVita			= "Устанавливать метки на игрока с дебаффом $spell:138297 и самого дальнего от него игрока"
})

L:SetMiscLocalization({
	Defeat	= "Остановитесь! Я… не враг вам."
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("ToTTrash")

L:SetGeneralLocalization({
	name	= "Трэш мобы Престола Гроз"
})

L:SetOptionLocalization({
	RangeFrame	= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT_SHORT:format(10)--Для 3-х разных заклинаний
})
