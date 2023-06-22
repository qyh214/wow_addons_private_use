if GetLocale() ~= "ruRU" then
	return
end
local L

---------------
-- Kargath Bladefist --
---------------
L = DBM:GetModLocalization(1128)

L:SetTimerLocalization({
	timerSweeperCD	= "Следующий Чистильщик арены"
})

L:SetOptionLocalization({
	timerSweeperCD	= DBM_CORE_L.AUTO_TIMER_OPTIONS.next:format(177776)
})

---------------------------
-- Tectus, the Living Mountain --
---------------------------
L = DBM:GetModLocalization(1195)

L:SetMiscLocalization({
	pillarSpawn	= "ВОССТАНЬТЕ, ГОРЫ!"
})

------------------
-- Brackenspore, Walker of the Deep --
------------------
L = DBM:GetModLocalization(1196)

L:SetOptionLocalization({
	InterruptCounter	= "Сбрасывать счетчик Ослабления после",
	Two					= "После двух кастов",
	Three				= "После трех кастов",
	Four				= "После четырех кастов"
})

--------------
-- Twin Ogron --
--------------
L = DBM:GetModLocalization(1148)

L:SetOptionLocalization({
	PhemosSpecial		= "Звуковой обратный отсчет для кулдаунов Фем'а",
	PolSpecial			= "Звуковой обратный отсчет для кулдаунов Пол'а",
	PhemosSpecialVoice	= "Звуковые оповещения для способностей Фем'а, используя выбранный звуковой пакет",
	PolSpecialVoice		= "Звуковые оповещения для способностей Пол'а, используя выбранный звуковой пакет"
})

--------------------
--Koragh --
--------------------
L = DBM:GetModLocalization(1153)

L:SetWarningLocalization({
	specWarnExpelMagicFelFades	= "Скверна спадает через 5 сек. - вернитесь в начало"
})

L:SetOptionLocalization({
	specWarnExpelMagicFelFades	= "Спецпредупреждение о переходе в исходное положение, когда $spell:172895 спадает"
})

L:SetMiscLocalization({
	supressionTarget1	= "Я сокрушу вас!",
	supressionTarget2	= "Молчать!",
	supressionTarget3	= "Тихо!",
	supressionTarget4	= "Я разорву вас на части!"
})

--------------------------
-- Imperator Mar'gok --
--------------------------
L = DBM:GetModLocalization(1197)

L:SetTimerLocalization({
	timerNightTwistedCD	= "След. Поддавшийся ночи верный служитель"
})

L:SetOptionLocalization({
	GazeYellType		= "Тип крика для Взгляд Бездны",
	Countdown			= "Обратный отсчет до спадения",
	Stacks				= "Получаемые стаки",
	timerNightTwistedCD	= "Отсчет времени до след. Поддавшийся ночи верный служитель"
})

L:SetMiscLocalization({
	BrandedYell		= "Клеймо (%d) %dм",
	GazeYell		= "Взгляд спадает через %d",
	GazeYell2		= "Взгляд (%d) на %s",
	PlayerDebuffs	= "Ближайшие к Вспышке"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("HighmaulTrash")

L:SetGeneralLocalization({
	name	= "Трэш мобы Верховного Молота"
})

---------------
-- Gruul --
---------------
L = DBM:GetModLocalization(1161)

L:SetOptionLocalization({
	MythicSoakBehavior	= "Настройка получения стаков от Инфернального удара для спецпредупреждений (эпох. сложность)",
	ThreeGroup			= "3 группы по 1 стаку каждая",
	TwoGroup			= "2 группы по 2 стака каждая"
})

---------------------------
-- Oregorger, The Devourer --
---------------------------
L = DBM:GetModLocalization(1202)

L:SetOptionLocalization({
	InterruptBehavior	= "Настройка поведения предупреждений для прерывания",
	Smart				= "Основываясь на стаках",
	Fixed				= "Фиксированная последовательность из 5 или 3"
})

---------------------------
-- The Blast Furnace --
---------------------------
L = DBM:GetModLocalization(1154)

L:SetWarningLocalization({
	warnRegulators			= "Осталось Регуляторов температуры: %d",
	warnBlastFrequency		= "Частота взрывов увеличилась: каждые ~%d сек",
	specWarnTwoVolatileFire	= "Два Неустойчивых огня на Вас!"
})

L:SetOptionLocalization({
	warnRegulators			= "Объявлять сколько Регуляторов температуры осталось",
	warnBlastFrequency		= "Объявлять когда увеличивается частота $spell:155209",
	specWarnTwoVolatileFire	= "Спецпредупреждение, когда на Вас два $spell:176121",
	InfoFrame				= "Информационное окно для $spell:155192 и $spell:155196",
	VFYellType2				= "Тип крика для Неустойчивого огня (только эпохальный режим)",
	Countdown				= "Отсчет до спадения",
	Apply					= "Только получение дебаффа"
})

L:SetMiscLocalization({
	heatRegulator	= "Регулятор температуры",
	Regulator		= "Регулятор %d",--Can't use above, too long for infoframe
	bombNeeded		= "%d |4бомба:бомбы:бомб;"
})

--------------------------
-- Operator Thogar --
--------------------------
L = DBM:GetModLocalization(1147)

L:SetWarningLocalization({
	specWarnSplitSoon	= "Разделение рейда через 10 сек"
})

L:SetOptionLocalization({
	specWarnSplitSoon	= "Спецпредупредение за 10 секунд до разделения рейда",
	InfoFrameSpeed		= "Настройка отображения след. поезда в информационном окне",
	Immediately			= "Как только открываются двери для текущего поезда",
	Delayed				= "После того, как текущий поезд выехал",
	HudMapUseIcons		= "Использовать рейдовые метки для HudMap вместо зеленого круга",
	TrainVoiceAnnounce	= "Настройка голосовых оповещений о поездах",
	LanesOnly			= "Анонсировать только прибывающие пути",
	MovementsOnly		= "Анонсировать только передвижения по путям (только Эпох.)",
	LanesandMovements	= "Анонсировать прибывающие пути и передвижения (только Эпох.)"
})

L:SetMiscLocalization({
	Train			= "Поезд",
	lane			= "Путь",
	oneTrain		= "1 случайный путь: Поезд",
	oneRandom		= "Появляется на 1 случайном пути",
	threeTrains		= "3 случайных пути: Поезд",
	threeRandom		= "Появляются на 3 случайных путях",
	helperMessage	= "Этот бой может быть упрощен с помощью аддона 'Thogar Assist' или одного из множества доступных голосовых пакетов DBM, которые можно найти на CurseForge"
})

--------------------------
-- The Iron Maidens --
--------------------------
L = DBM:GetModLocalization(1203)

L:SetWarningLocalization({
	specWarnReturnBase	= "Возвращайтесь на причал!"
})

L:SetOptionLocalization({
	specWarnReturnBase	= "Спецпредупреждение, когда игрок на борту может безопасно вернуться на причал",
	filterBladeDash3	= "Не показывать спецпредупреждения для $spell:155794, когда на ком-то $spell:170395",
	filterBloodRitual3	= "Не показывать спецпредупреждения для $spell:158078, когда на ком-то $spell:170405"
})

L:SetMiscLocalization({
	shipMessage	= "готовится занять позицию у главного орудия дредноута!",
	EarlyBladeDash	= "Слишком медленно!"
})

--------------------------
-- Blackhand --
--------------------------
L = DBM:GetModLocalization(959)

L:SetWarningLocalization({
	specWarnMFDPosition		= "Позиция метки: %s",
	specWarnSlagPosition	= "Позиция бомбы: %s"
})

L:SetOptionLocalization({
	PositionsAllPhases	= "Задавать позиции для $spell:156096 криков во время всех фаз (вместо только 3 фазы, данная опция не рекомендуется)",
	InfoFrame			= "Информационное окно для $spell:155992 и $spell:156530"
})

L:SetMiscLocalization({
	customMFDSay	= "Метка %s на %s",
	customSlagSay	= "Бомба %s на %s"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("BlackrockFoundryTrash")

L:SetGeneralLocalization({
	name	= "Трэш мобы Литейной клана Черной горы"
})

---------------
-- Hellfire Assault --
---------------
L = DBM:GetModLocalization(1426)

L:SetTimerLocalization({
	timerSiegeVehicleCD	= "След. осад. машина %s",
})

L:SetOptionLocalization({
	timerSiegeVehicleCD = "Отсчет времени до появления новой осадной машины"
})

L:SetMiscLocalization({
	AddsSpawn1	= "Comin' in hot!",--Blizzard seems to have disabled these
	AddsSpawn2	= "Fire in the hole!",--Blizzard seems to have disabled these
	BossLeaving	= "Я вернусь..."
})

---------------------------
-- Hellfire High Council --
---------------------------
L = DBM:GetModLocalization(1432)

L:SetWarningLocalization({
	reapDelayed	= "Жатва после Лика закончилась"
})

L:SetOptionLocalization({
	reapDelayed	= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.soon:format(184476)
})

--------------
-- Kilrogg Deadeye --
--------------
L = DBM:GetModLocalization(1396)

L:SetMiscLocalization({
	BloodthirstersSoon	= "Ко мне, братья! Ваша судьба ждет!"
})

--------------------
--Gorefiend --
--------------------
L = DBM:GetModLocalization(1372)

L:SetTimerLocalization({
	SoDDPS2		= "След. Тени (%s)",
	SoDTank2	= "След. Тени (%s)",
	SoDHealer2	= "След. Тени (%s)"
})

L:SetOptionLocalization({
	SoDDPS2			= "Отсчет времени до след. $spell:179864 (дд)",
	SoDTank2		= "Отсчет времени до след. $spell:179864 (танки)",
	SoDHealer2		= "Отсчет времени до след. $spell:179864 (хилы)",
	ShowOnlyPlayer	= "Показывать HudMap для $spell:179909, только если Вы участник"
})

--------------------------
-- Shadow-Lord Iskar --
--------------------------
L = DBM:GetModLocalization(1433)

L:SetWarningLocalization({
	specWarnThrowAnzu	=	"Бросьте Глаз Анзу %s!"
})

L:SetOptionLocalization({
	specWarnThrowAnzu	=	"Спецпредупреждение, когда Вы должны кинуть $spell:179202"
})

--------------------------
-- Fel Lord Zakuun --
--------------------------
L = DBM:GetModLocalization(1391)

L:SetOptionLocalization({
	SeedsBehavior	= "Поведение крика для Семя разрушения (требуется лидер рейда)",
	Iconed			= "Метки на полу: Звезда, Круг, Ромб, Треугольник, Луна",
	Numbered		= "Нумерованные позиции: 1, 2, 3, 4, 5",
	DirectionLine	= "Лево, Слева от середины, Середина, Справа от середины, Право. Для стратегии в одну линию",
	FreeForAll		= "Свободное. Позиция не задается, используется обычный крик"
})

L:SetMiscLocalization({
	DBMConfigMsg	= "Конфигурация для Семя разрушения установлена в %s, чтобы соответствовать конфигурации рейд лидера.",
	BWConfigMsg		= "Рейд лидер использует Bigwigs, DBM автоматически настроен на использование нумерованных позиций"
})

--------------------------
-- Xhul'horac --
--------------------------
L = DBM:GetModLocalization(1447)

L:SetOptionLocalization({
	ChainsBehavior	= "Поведение предупреждения для Цепи Скверны",
	Cast			= "Выдавать только начальную цель в начале каста. Таймер синхронизируется по началу каста.",
	Applied			= "Выдавать цели в конце каста. Таймер синхронизируется по окончанию каста.",
	Both			= "Выдавать начальную цель в начале каста и другие цели в конце каста."
})

--------------------------
-- Socrethar the Eternal --
--------------------------
L = DBM:GetModLocalization(1427)

L:SetOptionLocalization({
	InterruptBehavior	= "Поведение ротации прерывания для рейда (требуется лидер рейда)",
	Count3Resume		= "Ротация из 3 чел., которая продолжается, когда барьер спадает",
	Count3Reset			= "Ротация из 3 чел., которая начинается заново, когда барьер спадает",
	Count4Resume		= "Ротация из 4 чел., которая продолжается, когда барьер спадает",
	Count4Reset			= "Ротация из 4 чел., которая начинается заново, когда барьер спадает"
})

--------------------------
-- Mannoroth --
--------------------------
L = DBM:GetModLocalization(1395)

L:SetOptionLocalization({
	CustomAssignWrath	= "Установить метки $spell:186348 на основе ролей игроков (должен быть включен лидером рейда. Может конфликтовать с BW или устаревшими версиями DBM)"
})

L:SetMiscLocalization({
	felSpire	= "начинает усиливать шпиль Скверны!"
})

--------------------------
-- Archimonde --
--------------------------
L = DBM:GetModLocalization(1438)

L:SetWarningLocalization({
	specWarnBreakShackle	= "Скованное страдание: разорвать связь %s!"
})

L:SetOptionLocalization({
	specWarnBreakShackle	= "Спецпредупреждение для $spell:184964. Это предупреждение автоматически назначает последовательность разрывания, чтобы минимизировать урон.",
	ExtendWroughtHud3		= "Продлять линии HUD за цель $spell:185014 (может уменьшить точность линии)",
	AlternateHudLine		= "Использовать альтернативную текстуру линии для HUD между целями $spell:185014",
	NamesWroughtHud			= "Отображать имена игроков для целей $spell:185014",
	FilterOtherPhase		= "Фильтровать предупреждения для событий из другой фазы",
	MarkBehavior			= "Установить поведение крика «Клеймо Легиона» для рейда (требуется лидер рейда)",
	Numbered				= "Звезда, круг, ромб, треугольник. Может использоваться для любой стратегии, использующей положения вспышки.",
	LocSmallFront			= "Ближний бой Лево/Право (звезда, круг), дальний бой Лево/Право (ромб, треугольник). Короткие дебаффы в ближнем бою.",
	LocSmallBack			= "Ближний бой Лево/Право (звезда, круг), дальний бой Лево/Право (ромб, треугольник). Короткие дебаффы в дальнем бою.",
	NoAssignment			= "Отключите все позиционные крики/сообщения, метки и HUD для всего рейда.",
	overrideMarkOfLegion	= "Не позволяйте лидеру рейда переопределять поведение «Клеймо Легиона» (рекомендуется только для экспертов, которые уверены, что их собственные настройки не противоречат намерениям лидеров рейда)"
})

L:SetMiscLocalization({
	phase2point5	= "Узрите несметные войска Пылающего Легиона и осознайте всю тщетность борьбы!",--3 seconds faster than CLEU, used as primary, slower CLEU secondary
	First			= "Первый",
	Second			= "Второй",
	Third			= "Третий",
	Fourth			= "Четвертый",--Just in case, not sure how many targets in 30 man raid
	Fifth			= "Пятый"--Just in case, not sure how many targets in 30 man raid
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("HellfireCitadelTrash")

L:SetGeneralLocalization({
	name	= "Трэш мобы Цитадель Адского Пламени"
})
