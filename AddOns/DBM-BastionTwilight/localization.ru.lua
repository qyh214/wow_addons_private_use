if GetLocale() ~= "ruRU" then return end

local L

--------------------------
--  Halfus Wyrmbreaker  --
--------------------------
L= DBM:GetModLocalization(156)

L:SetOptionLocalization({
	ShowDrakeHealth		= "Показать здоровье подчиненного дракона<br/>(должна быть включена опция отображения здоровья босса)"
})


---------------------------
--  Valiona & Theralion  --
---------------------------
L= DBM:GetModLocalization(157)

L:SetOptionLocalization({
	TBwarnWhileBlackout		= "Предупреждение о $spell:92898, когда активно $spell:86788",
	TwilightBlastArrow		= "Показывать стрелку DBM, когда $spell:92898 около Вас",
	RangeFrame				= "Показывать окно проверки дистанции (10м)",
	BlackoutShieldFrame		= "Показывать полоску здоровья для $spell:92878",
	BlackoutIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(86788),
	EngulfingIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(86622)
})

L:SetMiscLocalization({
	Trigger1				= "Глубокий вдох",
	BlackoutTarget			= "Затмение: %s"
})

----------------------------------
--  Twilight Ascendant Council  --
----------------------------------
L= DBM:GetModLocalization(158)

L:SetWarningLocalization({
	specWarnBossLow			= "%s ниже 30%% - скоро следующая фаза!",
	SpecWarnGrounded		= "Получите ауру заземления!",
	SpecWarnSearingWinds	= "Получите ауру кружащихся ветров!"
})

L:SetTimerLocalization({
	timerTransition			= "Смена фаз"
})

L:SetOptionLocalization({
	specWarnBossLow			= "Спецпредупреждение, когда здоровье боссов опускается до 30%",
	SpecWarnGrounded		= "Спецпредупреждение, когда у Вас не хватает ауры $spell:83581<br/>(~10сек перед началом применения)",
	SpecWarnSearingWinds	= "Спецпредупреждение, когда у Вас не хватает ауры $spell:83500<br/>(~10сек перед началом применения)",
	timerTransition			= "Показывать таймер перехода в другую фазу",
	RangeFrame				= "Автоматически показывать окно проверки дистанции при необходимости",
	yellScrewed				= "Кричать, когда на Вас одновременно $spell:83099 и $spell:92307",
	InfoFrame				= "Показывать игроков без $spell:83581 или $spell:83500",
	HeartIceIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82665),
	BurningBloodIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82660),
	LightningRodIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(83099),
	GravityCrushIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(84948),
	FrostBeaconIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92307),
	StaticOverloadIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92067),
	GravityCoreIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92075)
})

L:SetMiscLocalization({
	Quake					= "Земля уходит у вас из-под ног...", -- Yell string: Земля поглотит вас!
	Thundershock			= "Воздух потрескивает от скопившейся энергии...", -- Yell string: Ветер, явись на мой зов!
	Switch					= "Закончим этот фарс!",--"We will handle them!" comes 3 seconds after this one
	Phase3					= "Ваше упорство...",--"BEHOLD YOUR DOOM!" is about 13 seconds after
	Kill					= "Невозможно....",
	blizzHatesMe			= "Сфера и громотвод на МНЕ! С ДОРОГИ!!!",--You're probably fucked, and gonna kill half your raid if this happens, but worth a try anyways :).
	WrongDebuff				= "Отсутствует %s"
})

----------------
--  Cho'gall  --
----------------
L= DBM:GetModLocalization(167)

L:SetOptionLocalization({
	CorruptingCrashArrow	= "Показывать стрелку DBM, когда $spell:81685 около Вас",
	InfoFrame				= "Показывать информационное окно для $journal:3165",
	RangeFrame				= "Показывать окно проверки дистанции (5м) для $journal:3165",
	SetIconOnWorship		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(91317)
})

----------------
--  Sinestra  --
----------------
L= DBM:GetModLocalization(168)

L:SetWarningLocalization({
	WarnOrbSoon			= "Сферы через %d сек!",
	SpecWarnOrbs		= "Скоро появятся сферы!",
	warnWrackJump		= "%s прыгнуло на >%s<",
	warnAggro			= "На >%s< АГРО (возможные цели сфер)",
	SpecWarnAggroOnYou	= "На Вас АГРО! Смотрите за сферами!"
})

L:SetTimerLocalization({
	TimerEggWeakening	= "Снятие зашиты с яиц",
	TimerEggWeaken		= "Восст. Сумеречного панциря",
	TimerOrbs			= "Восст. Сферы Тьмы"
})

L:SetOptionLocalization({
	WarnOrbSoon			= "Предупреждение о появлении сфер (за 5с до начала, каждую 1с)<br/>Предупреждение может быть неточным. Может быть спамом.",
	warnWrackJump		= "Показывать цели, на которые прыгает $spell:92955",
	warnAggro			= "Показывать игроков, имеющих агро от сфер (возможные цели сфер)",
	SpecWarnAggroOnYou	= "Спецпредупреждение, если на Вас есть агро при появлении сфер",
	SpecWarnOrbs		= "Спецпредупреждение при появлении сфер<br/>Предупреждение может быть неточным",
	TimerEggWeakening	= "Отсчет времени до снятия $spell:87654",
	TimerEggWeaken		= "Отсчет времени восстановления $spell:87654",
	TimerOrbs			= "Отсчет времени до следующих сфер (таймер может быть неточным)",
	SetIconOnOrbs		= "Устанавливать метки на игроков, имеющих агро от сфер<br/>Предполагаемые цели сфер",
	InfoFrame			= "Показывать список игроков, имеющих агро"
})

L:SetMiscLocalization({
	YellDragon			= "Ешьте, дети мои! Пусть их мясо насытит вас!",
	YellEgg				= "Ты так в этом уверен? Глупец!",
	HasAggro			= "Имеют агро"
})

-------------------------------------
--  The Bastion of Twilight Trash  --
-------------------------------------
L = DBM:GetModLocalization("BoTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Сумеречный бастион"
})
