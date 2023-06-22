if GetLocale() ~= "ruRU" then return end
local L

----------------
--  Argaloth  --
----------------
L= DBM:GetModLocalization(139)

L:SetOptionLocalization({
	SetIconOnConsuming		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(88954)
})

-----------------
--  Occu'thar  --
-----------------
L= DBM:GetModLocalization(140)

----------------------------------
--  Alizabal, Mistress of Hate  --
----------------------------------
L= DBM:GetModLocalization(339)

L:SetTimerLocalization({
	TimerFirstSpecial		= "Первая способность"
})

L:SetOptionLocalization({
	TimerFirstSpecial		= "Отсчет времени до первой особой способности после $spell:105738<br/>(Первая способность выбирается случайным образом из $spell:105067 или $spell:104936)"
})

-------------------------------
--  Dark Iron Golem Council  --
-------------------------------
L = DBM:GetModLocalization(169)

L:SetWarningLocalization({
	SpecWarnActivated			= "Смена цели на: %s!",
	specWarnGenerator			= "Генератор энергии - Двигайтесь %s!"
})

L:SetTimerLocalization({
	timerShadowConductorCast	= "Проводник тьмы",
	timerArcaneLockout			= "Волшебный уничтожитель",
	timerArcaneBlowbackCast		= "Чародейская обратная вспышка",
	timerNefAblity				= "Восст. баффа" --Ability Buff CD
})

L:SetOptionLocalization({
	timerShadowConductorCast	= "Отсчет времени применения заклинания $spell:92048",
	timerArcaneLockout			= "Отсчет времени блокировки $spell:79710",
	timerArcaneBlowbackCast		= "Отсчет времени применения заклинания $spell:91879",
	timerNefAblity				= "Отсчет времени восстановления баффа (героический режим)",
	SpecWarnActivated			= "Спецпредупреждение при активации нового босса",
	specWarnGenerator			= "Спецпредупреждение, когда босс стоит в $spell:79629",
	AcquiringTargetIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79501),
	ConductorIcon				= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79888),
	ShadowConductorIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92053),
	SetIconOnActivated			= "Устанавливать метку на появившегося босса"
})

L:SetMiscLocalization({
	YellTargetLock				= "На МНЕ - Обрамляющие тени! Прочь от меня!"
})

--------------
--  Magmaw  --
--------------
L = DBM:GetModLocalization(170)

L:SetWarningLocalization({
	SpecWarnInferno	= "Появляется Пыляющее костяное создание! (~4 сек)"
})

L:SetOptionLocalization({
	SpecWarnInferno	= "Предупреждать заранее о $spell:92190 (~4 сек)",
	RangeFrame		= "Показывать окно проверки дистанции на второй фазе (5м)"
})

L:SetMiscLocalization({
	Slump			= "%s внезапно падает, выставляя клешки!",
	HeadExposed		= "%s насаживается на пику, обнажая голову!",
	YellPhase2		= "Непостижимо! Вы, кажется, можете уничтожить моего лавового червяка! Пожалуй, я помогу ему."
})

-----------------
--  Atramedes  --
-----------------
L = DBM:GetModLocalization(171)

L:SetOptionLocalization({
	InfoFrame				= "Показывать информационное окно для $journal:3072",
	TrackingIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(78092)
})

L:SetMiscLocalization({
	NefAdd					= "Атрамед, они вон там!",
	Airphase				= "Да, беги! С каждым шагом твое сердце бьется все быстрее. Эти громкие, оглушительные удары... Тебе некуда бежать!"
})

-----------------
--  Chimaeron  --
-----------------
L = DBM:GetModLocalization(172)

L:SetOptionLocalization({
	RangeFrame		= "Показывать окно проверки дистанции (6м)",
	SetIconOnSlime	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82935),
	InfoFrame		= "Показывать информационное окно со здоровьем (<10к хп)"
})

L:SetMiscLocalization({
	HealthInfo	= "Инфо о здоровье"
})

----------------
--  Maloriak  --
----------------
L = DBM:GetModLocalization(173)

L:SetWarningLocalization({
	WarnPhase			= "%s фаза"
})

L:SetTimerLocalization({
	TimerPhase			= "Следующая фаза"
})

L:SetOptionLocalization({
	WarnPhase			= "Предупреждать о переходе фаз",
	TimerPhase			= "Показывать таймер до следующей фазы",
	RangeFrame			= "Показывать окно проверки дистанции (6м) во время синей фазы",
	SetTextures			= "Автоматически отключить \"Проецирование текстур\" в темной фазе<br/>(включается обратно при выходе из фазы)",
	FlashFreezeIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(77699),
	BitingChillIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(77760),
	ConsumingFlamesIcon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(77786)
})

L:SetMiscLocalization({
	YellRed				= "красный|r пузырек в котел!",--Partial matchs, no need for full strings unless you really want em, mod checks for both.
	YellBlue			= "синий|r пузырек в котел!",
	YellGreen			= "зеленый|r пузырек в котел!",
	YellDark			= "магию на котле!"
})

----------------
--  Nefarian  --
----------------
L = DBM:GetModLocalization(174)

L:SetWarningLocalization({
	OnyTailSwipe		= "Удар хвостом (Ониксия)",
	NefTailSwipe		= "Удар хвостом (Нефариан)",
	OnyBreath			= "Дыхание темного огня (Ониксия)",
	NefBreath			= "Дыхание темного огня (Нефариан)",
	specWarnShadowblazeSoon	= "%s",
	warnShadowblazeSoon		= "%s"
})

L:SetTimerLocalization({
	timerNefLanding		= "Приземление Нефариана",
	OnySwipeTimer		= "Удар хвостом - перезарядка (Ониксия)",
	NefSwipeTimer		= "Удар хвостом - перезарядка (Нефариан)",
	OnyBreathTimer		= "Дыхание темного огня (Ониксия)",
	NefBreathTimer		= "Дыхание темного огня (Нефариан)"
})

L:SetOptionLocalization({
	OnyTailSwipe		= "Предупреждение для $spell:77827 Ониксии",
	NefTailSwipe		= "Предупреждение для $spell:77827 Нефариана",
	OnyBreath			= "Предупреждение для $spell:77826 Ониксии",
	NefBreath			= "Предупреждение для $spell:77826 Нефариана",
	specWarnCinderMove	= "Спецпредупреждение за 5 секунд до взрыва $spell:79339",
	warnShadowblazeSoon	= "Отсчитывать время до $spell:81031 (за 5 секунд до каста)<br/>(Отсчет пойдет только после первой синхронизации с эмоцией босса)",
	specWarnShadowblazeSoon	= "Предупреждать заранее о $spell:81031<br/>(За 5 секунд до первого каста, за 1 секунду до каждого следующего)",
	timerNefLanding		= "Отсчет времени до приземления Нефариана",
	OnySwipeTimer		= "Отсчет времени до восстановления $spell:77827 Ониксии",
	NefSwipeTimer		= "Отсчет времени до восстановления $spell:77827 Нефариана",
	OnyBreathTimer		= "Отсчет времени до восстановления $spell:77826 Ониксии",
	NefBreathTimer		= "Отсчет времени до восстановления $spell:77826 Нефариана",
	InfoFrame			= "Показывать информационное окно для $journal:3284",
	SetWater			= "Автоматически отключать настройку Брызги воды<br/>(Включается обратно при выходе из боя)",
	SetIconOnCinder		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79339),
	RangeFrame			= "Окно проверки дистанции (10м) для $spell:79339<br/>(Если на Вас дебафф - показывает всех, иначе только игроков с метками)"
})

L:SetMiscLocalization({
	NefAoe				= "В воздухе трещат электрические разряды!",
	YellPhase2			= "Дерзкие смертные! Неуважение к чужой собственности нужно пресекать самым жестоким образом!",
	YellPhase3			= "Я пытался следовать законам гостеприимства, но вы всё никак не умрете!",
	YellShadowBlaze		= "И плоть превратится в прах!",
	ShadowBlazeExact		= "Вспышка пламени тени через %d",
	ShadowBlazeEstimate		= "Скоро вспышка пламени тени (~5с)"
})

-------------------------------
--  Blackwing Descent Trash  --
-------------------------------
L = DBM:GetModLocalization("BWDTrash")

L:SetGeneralLocalization({
	name = "Трэш мобы Твердыни Крыла Тьмы"
})

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

------------------------
--  Conclave of Wind  --
------------------------
L = DBM:GetModLocalization(154)

L:SetWarningLocalization({
	warnSpecial			= "Активация - Урагана/Зефира/Вихря",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial		= "Активация особой способности!",
	warnSpecialSoon		= "Особые способности через 10 сек!"
})

L:SetTimerLocalization({
	timerSpecial		= "Перезарядка особой способности",
	timerSpecialActive	= "Активация особой способности"
})

L:SetOptionLocalization({
	warnSpecial			= "Сообщить о применении Урагана/Зефира/Вихря стали",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial		= "Спецпредупреждение о применении особых способностя",
	timerSpecial		= "Отсчет времени до восстановления особых способностей",
	timerSpecialActive	= "Отсчет времени действия особых способностей",
	warnSpecialSoon		= "Показывать предупреждение за 10 секунд до применения особых способностей",
	OnlyWarnforMyTarget	= "Показывать только таймеры/предупреждения для текущей цели и фокуса<br/>(Скрывает все остальное. ВКЛЮЧАЯ ПУЛЛ)"
})

L:SetMiscLocalization({
	gatherstrength		= "%s близок к обретению абсолютной силы"
})

---------------
--  Al'Akir  --
---------------
L = DBM:GetModLocalization(155)

L:SetTimerLocalization({
	TimerFeedback 	= "Ответная реакция (%d)"
})

L:SetOptionLocalization({
	LightningRodIcon= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(89668),
	TimerFeedback	= "Отсчет времени действия $spell:87904",
	RangeFrame		= "Показывать окно проверки дистанции (20м), когда на Вас $spell:89668"
})

-----------------
-- Beth'tilac --
-----------------
L= DBM:GetModLocalization(192)

L:SetMiscLocalization({
	EmoteSpiderlings 	= "Сверху свисают пеплопряды-ткачи!"
})

-------------------
-- Lord Rhyolith --
-------------------
L= DBM:GetModLocalization(193)

---------------
-- Alysrazor --
---------------
L= DBM:GetModLocalization(194)

L:SetWarningLocalization({
	WarnPhase			= "Фаза %d",
	WarnNewInitiate		= "Новообращенный друид-огнеястреб (%s)"
})

L:SetTimerLocalization({
	TimerPhaseChange	= "Фаза %d",
	TimerHatchEggs		= "Вылупление яиц",
	timerNextInitiate	= "Следующий друид (%s)"
})

L:SetOptionLocalization({
	WarnPhase			= "Предупреждение о смене фаз",
	WarnNewInitiate		= "Предупреждение о появлении нового друида-огнеястреба",
	timerNextInitiate	= "Отсчет времени до появления нового друида-огнеястреба",
	TimerPhaseChange	= "Отсчет времени до следующей фазы",
	TimerHatchEggs		= "Отсчет времени до вылупления яиц"
})

L:SetMiscLocalization({
	YellPull			= "Теперь я служу новому господину, смертные!",
	YellPhase2			= "Небо над вами принадлежит МНЕ!",
	LavaWorms			= "На поверхность вылезают огненные лавовые паразиты!",
	PowerLevel			= "Опаляющее перо",
	East				= "на востоке",
	West				= "на западе",
	Both				= "обе стороны"
})

-------------
-- Shannox --
-------------
L= DBM:GetModLocalization(195)

-------------
-- Baleroc --
-------------
L= DBM:GetModLocalization(196)

L:SetWarningLocalization({
	warnStrike	= "%s (%d)"
})

L:SetTimerLocalization({
	TimerBladeActive	= "%s",
	timerStrike			= "След. %s",
	TimerBladeNext		= "Следующее лезвие"
})

L:SetOptionLocalization({
	ResetShardsinThrees	= "Отсчитывать кристаллы группами по 3(25 ппл)/2(10 ппл) в каждой",
	warnStrike			= "Предупреждение о лезвиях",
	timerStrike			= "Отсчет времени между ударами лезвий",
	TimerBladeActive	= "Отсчет времени действия активного лезвия",
	TimerBladeNext		= "Отсчет времени до следующего лезвия"
})

--------------------------------
-- Majordomo Fandral Staghelm --
--------------------------------
L= DBM:GetModLocalization(197)

L:SetTimerLocalization({
	timerNextSpecial		= "След. %s (%d)"
})

L:SetOptionLocalization({
	timerNextSpecial		= "Отсчет времени до следующей особой способности",
	RangeFrameSeeds			= "Показывать окно проверки дистанции (12м) для $spell:98450",
	RangeFrameCat			= "Показывать окно проверки дистанции (10м) для $spell:98374"
})

--------------
-- Ragnaros --
--------------
L= DBM:GetModLocalization(198)

L:SetWarningLocalization({
	warnRageRagnarosSoon	= "%s на %s через 5 секунд",--Spellname on targetname
	warnSplittingBlow		= "%s через %s",--Spellname in Location
	warnEngulfingFlame		= "%s через %s",--Spellname in Location
	warnEmpoweredSulf		= "%s через 5 секунд"--The spell has a 5 second channel, but tooltip doesn't reflect it so cannot auto localize
})

L:SetTimerLocalization({
	timerRageRagnaros	= "%s на %s",--Spellname on targetname
	TimerPhaseSons		= "Окончание переходной фазы"
})

L:SetOptionLocalization({
	warnRageRagnarosSoon		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.prewarn:format(101109),
	warnSplittingBlow			= "Предупреждение для $spell:98951",
	warnEngulfingFlame			= "Предупреждение для $spell:99171 (в обычном режиме)",
	WarnEngulfingFlameHeroic	= "Предупреждение о появлении $spell:99171 (в героическом режиме)",
	warnSeedsLand				= "Отсчитывать время до появления $spell:98520, а не до их появления в воздухе",
	warnEmpoweredSulf			= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.cast:format(100604),
	timerRageRagnaros			= DBM_CORE_L.AUTO_TIMER_OPTIONS.cast:format(101109),
	TimerPhaseSons				= "Отсчет времени до окончания \"фазы Сыновей пламени\"",
	InfoHealthFrame				= "Информационное окно для игроков с низким уровнем здоровья (<100к)",
	MeteorFrame					= "Информационное окно для целей $spell:99849",
	AggroFrame					= "Информационное окно для игроков, не имеющих аггро от элементалей"
})

L:SetMiscLocalization({
	East				= "на востоке",
	West				= "на западе",
	Middle				= "в центре",
	North				= "в мили",
	South				= "сзади",
	HealthInfo			= "Уровень здоровья",
	HasNoAggro			= "Без аггро",
	MeteorTargets		= "ОМФГ Метеоры!",--Keep rollin' rollin' rollin' rollin'.
	TransitionEnded1	= "Довольно! Пора покончить с этим.",--More reliable then adds method.
	TransitionEnded2	= "Сульфурас уничтожит вас!",--More reliable then adds method.
	TransitionEnded3	= "На колени, смертные!",
	Defeat				= "Слишком рано!.. Вы пришли слишком рано...",
	Phase4				= "Слишком рано..."
})

-----------------------
--  Firelands Trash  --
-----------------------
L = DBM:GetModLocalization("FirelandsTrash")

L:SetGeneralLocalization({
	name = "Трэш мобы Огненные Просторы"
})

----------------
--  Volcanus  --
----------------
L = DBM:GetModLocalization("Volcanus")

L:SetGeneralLocalization({
	name = "Вулканий"
})

L:SetTimerLocalization({
	timerStaffTransition	= "Следующая фаза"
})

L:SetOptionLocalization({
	timerStaffTransition	= "Отсчет времени до перехода фаз"
})

L:SetMiscLocalization({
	StaffEvent				= "Ветвь Нордрассила яростно реагирует на прикосновение",--Partial, not sure if pull detection will work with partials yet :\
	StaffTrees				= "Из-под земли появляются пылающие древни, чтобы помощь защитнику!",--Might add a spec warning for this later.
	StaffTransition			= "Пламя, пожирающее измученного заступника, меркнет."
})

-----------------------
--  Nexus Legendary  --
-----------------------
L = DBM:GetModLocalization("NexusLegendary")

L:SetGeneralLocalization({
	name = "Тиринар"
})

-------------
-- Morchok --
-------------
L= DBM:GetModLocalization(311)

L:SetWarningLocalization({
	KohcromWarning	= "%s: %s"
})

L:SetTimerLocalization({
	KohcromCD		= "Кохром повторяет %s"
})

L:SetOptionLocalization({
	KohcromWarning	= "Предупреждать, когда Кохром повторяет заклинания Морхока",
	KohcromCD		= "Отсчет времени до следующего повторения заклинания",
	RangeFrame		= "Показывать окно проверки дистанции (5м) для достижения."
})

L:SetMiscLocalization({
})

---------------------
-- Warlord Zon'ozz --
---------------------
L= DBM:GetModLocalization(324)

L:SetOptionLocalization({
	ShadowYell			= "Кричать, когда на Вас $spell:103434<br/>(героический уровень сложности)",
	CustomRangeFrame	= "Настройки окна проверки дистанции (героический уровень сложности)",
	Never				= "Отключено",
	Normal				= "Обычное",
	DynamicPhase2		= "Фильтрация дебафов (фаза 2)",
	DynamicAlways		= "Фильтрация дебафов (всегда)"
})

L:SetMiscLocalization({
	voidYell	= "Gul'kafh an'qov N'Zoth."--Start translating the yell he does for Void of the Unmaking cast, the latest logs from DS indicate blizz removed the event that detected casts. sigh.
})

-----------------------------
-- Yor'sahj the Unsleeping --
-----------------------------
L= DBM:GetModLocalization(325)

L:SetWarningLocalization({
	warnOozesHit	= "%s поглотил %s"
})

L:SetTimerLocalization({
	timerOozesActive	= "Появление капель крови",
	timerOozesReach		= "Капли достигнут босса"
})

L:SetOptionLocalization({
	warnOozesHit		= "Объявлять какие капли достигли босса",
	timerOozesActive	= "Отсчет времени спавна капель крови",
	timerOozesReach		= "Отсчет времени до достижения каплями босса",
	RangeFrame			= "Окно проверки дистанции (4) для $spell:104898<br/>(Сложность Обычная+)"
})

L:SetMiscLocalization({
	Black			= "|cFF424242черная|r",
	Purple			= "|cFF9932CDтеневая|r",
	Red				= "|cFFFF0404алая|r",
	Green			= "|cFF088A08кислотная|r",
	Blue			= "|cFF0080FFкобальтовая|r",
	Yellow			= "|cFFFFA901светящаяся|r"
})

-----------------------
-- Hagara the Binder --
-----------------------
L= DBM:GetModLocalization(317)

L:SetWarningLocalization({
	WarnPillars				= "%s: осталось %d",
	warnFrostTombCast		= "%s через 8 сек."
})

L:SetTimerLocalization({
	TimerSpecial			= "Первая способность"
})

L:SetOptionLocalization({
	WarnPillars				= "Объявлять сколько $journal:3919 или $journal:4069 осталось",
	TimerSpecial			= "Отсчет времени до первой особой способности",
	RangeFrame				= "Показывать окно проверки дистанции: (3м) для $spell:105269 и<br/>(10м) для $journal:4327",
	AnnounceFrostTombIcons	= "Дублировать рейдовые иконки на целях $spell:104451 в рейд-чат<br/>(Необходимы права лидера или помощника)",
	warnFrostTombCast		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.cast:format(104448),
	SetIconOnFrostTomb		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(104451),
	SetIconOnFrostflake		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(109325),
	SpecialCount			= "Звуковой отсчет для $spell:105256 или $spell:105465",
	SetBubbles				= "Автоматически отключать сообщения в облачках, когда $spell:104451 доступен<br/>(возвращает их в исходное после боя)"
})

L:SetMiscLocalization({
	TombIconSet				= "Ледяная гробница {rt%d} на %s"
})

---------------
-- Ultraxion --
---------------
L= DBM:GetModLocalization(331)

L:SetWarningLocalization({
	specWarnHourofTwilightN		= "%s (%%d)"
})

L:SetTimerLocalization({
	TimerCombatStart	= "Ультраксион приземляется"
})

L:SetOptionLocalization({
	TimerCombatStart	= "Отсчет времени до приземления Ультраксиона",
	ResetHoTCounter		= "Сброс счетчика \"Время сумерек\"",--$spell doesn't work in this function apparently so use typed spellname for now.
	Never				= "Никогда",
	ResetDynamic		= "Сброс на 3/2 (гер./обыч.)",
	Reset3Always		= "Сброс на 3 всегда",
	SpecWarnHoTN		= "Спецпредупреждение за 5 сек до \"Время сумерек\". Если сброс счетчика \"Никогда\", используется правило на 3",
	One					= "1 (т.е. 1 4 7)",
	Two					= "2 (т.е. 2 5)",
	Three				= "3 (т.е. 3 6)"
})

L:SetMiscLocalization({
	Pull				= "Я чувствую приближение Хаоса... Мой разум не в силах этого выдержать!"
})

-------------------------
-- Warmaster Blackhorn --
-------------------------
L= DBM:GetModLocalization(332)

L:SetWarningLocalization({
	SpecWarnElites	= "Сумеречные Элитки!"
})

L:SetTimerLocalization({
	TimerAdd			= "Следующие помощники"
})

L:SetOptionLocalization({
	TimerAdd			= "Отсчет времени до появления следующих помощников",
	SpecWarnElites		= "Спецпредупреждение для новых Сумеречных Элиток",
	SetTextures			= "Автоматически отключать проэцирование текстур на 1 фазе<br/>(возвращает в исходное на 2 фазе)"
})

L:SetMiscLocalization({
	SapperEmote			= "Дракон пикирует на палубу, чтобы сбросить на нее сумеречного сапера!",
	GorionaRetreat			= "Гориона издает полный боли визг и скрывается в клубящихся вокруг облаках."
})

-------------------------
-- Spine of Deathwing  --
-------------------------
L= DBM:GetModLocalization(318)

L:SetWarningLocalization({
	warnSealArmor			= "%s",
	SpecWarnTendril			= "Закрепитесь!"
})

L:SetOptionLocalization({
	warnSealArmor			= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.cast:format(105847),
	SpecWarnTendril			= "Спецпредупреждение, когда на Вас нет дебаффа $spell:109454",
	InfoFrame				= "Показывать информационное окно для игроков без $spell:109454",
	SetIconOnGrip			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(109459),
	ShowShieldInfo			= "Показывать полосы здоровья для исцеления $spell:105479"
})

L:SetMiscLocalization({
	Pull			= "Смотрите, он разваливается! Оторвите пластины, и у нас появится шанс сбить его!",
	NoDebuff		= "Нет %s",
	PlasmaTarget	= "Жгучая плазма: %s",
	DRoll			= "собирается накрениться",
	DLevels			= "выравнивается"
})

---------------------------
-- Madness of Deathwing  --
---------------------------
L= DBM:GetModLocalization(333)

L:SetOptionLocalization({
	RangeFrame			= "Динамическое окно проверки дистанции, используя статус дебафа<br/>$spell:108649 на героическом уровне сложности",
	SetIconOnParasite	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(108649)
})

L:SetMiscLocalization({
	Pull				= "У вас НИЧЕГО не вышло. Я РАЗОРВУ ваш мир на куски."
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("DSTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Душа Дракона"
})

L:SetWarningLocalization({
	DrakesLeft			= "Осталось Сумеречных агрессоров: %d"
})

L:SetTimerLocalization({
	timerRoleplay		= GUILD_INTEREST_RP,
	TimerDrakes			= "%s",--spellname from mod
})

L:SetOptionLocalization({
	DrakesLeft			= "Объявлять сколько Сумеречных агрессоров осталось",
	TimerDrakes			= "Отсчет времени при применении $spell:109904 Сумеречными агрессорами"
})

L:SetMiscLocalization({
	firstRP				= "Хвала Титанам, они вернулись!",
	UltraxionTrash		= "Рад встрече, Алекстраза. Скоро ты увидишь, над чем я трудился.",
	UltraxionTrashEnded = "Детеныши, эксперименты, шаги к будущему величию. Вы увидите, чего я добился."
})
