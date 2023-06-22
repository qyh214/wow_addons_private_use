if GetLocale() ~= "ruRU" then return end

local L

----------------------------------
--  Archavon the Stone Watcher  --
----------------------------------
L = DBM:GetModLocalization("Archavon")

L:SetGeneralLocalization({
	name = "Аркавон Страж Камня"
})

L:SetWarningLocalization({
	WarningGrab	= "Аркавон хватает >%s<"
})

L:SetTimerLocalization({
	ArchavonEnrage	= "Берсерк Аркавона"
})

L:SetMiscLocalization({
	TankSwitch	= "%%s бросается к (%S+)!"
})

L:SetOptionLocalization({
	WarningGrab		= "Объявлять о захвате цели",
	ArchavonEnrage	= "Отсчет времени до $spell:26662"
})

--------------------------------
--  Emalon the Storm Watcher  --
--------------------------------
L = DBM:GetModLocalization("Emalon")

L:SetGeneralLocalization{
	name = "Эмалон Страж Бури"
}

L:SetTimerLocalization{
	timerMobOvercharge	= "Взрыв в результате перегрузки",
	EmalonEnrage		= "Берсерк Эмалона"
}

L:SetOptionLocalization{
	timerMobOvercharge	= "Отсчет времени для моба с Перегрузкой (стакающего дебафф)",
	EmalonEnrage		= "Отсчет времени до $spell:26662"
}

---------------------------------
--  Koralon the Flame Watcher  --
---------------------------------
L = DBM:GetModLocalization("Koralon")

L:SetGeneralLocalization{
	name = "Коралон Страж Огня"
}

L:SetTimerLocalization{
	KoralonEnrage	= "Берсерк Коралона"
}

L:SetOptionLocalization{
	KoralonEnrage		= "Отсчет времени до $spell:26662"
}

L:SetMiscLocalization{
	Meteor	= "%s применяет заклинание \"Кулаки-метеоры\"!"
}

-------------------------------
--  Toravon the Ice Watcher  --
-------------------------------
L = DBM:GetModLocalization("Toravon")

L:SetGeneralLocalization{
	name = "Торавон Страж Льда"
}

L:SetTimerLocalization{
	ToravonEnrage	= "Берсерк Торавона"
}

L:SetMiscLocalization{
	ToravonEnrage	= "Отсчет времени до Берсерка"
}

-------------------
--  Anub'Rekhan  --
-------------------
L = DBM:GetModLocalization("Anub'Rekhan")

L:SetGeneralLocalization({
	name = "Ануб'Рекан"
})

L:SetOptionLocalization({
	ArachnophobiaTimer	= "Отсчет времени для Арахнофобия (достижение)"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "Арахнофобия",
	Pull1				= "Бегите, бегите! Я люблю горячую кровь!",
	Pull2				= "Посмотрим, какие вы на вкус!"
})

----------------------------
--  Grand Widow Faerlina  --
----------------------------
L = DBM:GetModLocalization("Faerlina")

L:SetGeneralLocalization({
	name = "Великая вдова Фарлина"
})

L:SetWarningLocalization({
	WarningEmbraceExpire	= "Объятие Вдовы через 5 секунд",
	WarningEmbraceExpired	= "Объятие Вдовы исчезает"
})

L:SetOptionLocalization({
	WarningEmbraceExpire	= "Показать предупреждение, когда Объятие Вдовы исчезает",
	WarningEmbraceExpired	= "Показать предупреждение, когда Объятие Вдовы закончится"
})

L:SetMiscLocalization({
	Pull					= "Склонитесь передо мной, черви!"
})

---------------
--  Maexxna  --
---------------
L = DBM:GetModLocalization("Maexxna")

L:SetGeneralLocalization({
	name = "Мексна"
})

L:SetWarningLocalization({
	WarningSpidersSoon	= "Паученыши Мексны через 5 секунд",
	WarningSpidersNow	= "В паутине появляются паучата"
})

L:SetTimerLocalization({
	TimerSpider	= "Паученыши Мексны"
})

L:SetOptionLocalization({
	WarningSpidersSoon	= "Предупреждать перед следующим призывом Паученышей Мексны",
	WarningSpidersNow	= "Предупреждение для призыва Паученышей Мексны",
	TimerSpider			= "Отсчет времени до Паученышей Мексны"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "Арахнофобия"
})

------------------------------
--  Noth the Plaguebringer  --
------------------------------
L = DBM:GetModLocalization("Noth")

L:SetGeneralLocalization({
	name = "Нот Чумной"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "Телепортация",
	WarningTeleportSoon	= "Телепортация через 10 секунд"
})

L:SetTimerLocalization({
	TimerTeleport		= "Телепортация",
	TimerTeleportBack	= "Телепортация обратно"
})

L:SetOptionLocalization({
	WarningTeleportNow	= "Предупреждение о телепортации",
	WarningTeleportSoon	= "Предупреждать перед следующей телепортацией",
	TimerTeleport		= "Отсчет времени до телепортации",
	TimerTeleportBack	= "Отсчет времени до обратной телепортации"
})

L:SetMiscLocalization({
	Pull				= "Умри, преступник!",
	Adds				= "Восстаньте, мои воины! Восстаньте и сразитесь вновь!",
	AddsTwo				= "raises more skeletons!"
})

--------------------------
--  Heigan the Unclean  --
--------------------------
L = DBM:GetModLocalization("Heigan")

L:SetGeneralLocalization({
	name = "Хейган Нечестивый"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "Телепортация",
	WarningTeleportSoon	= "Телепортация через %d сек."
})

L:SetTimerLocalization({
	TimerTeleport	= "Телепортация"
})

L:SetOptionLocalization({
	WarningTeleportNow	= "Предупреждение о телепортации",
	WarningTeleportSoon	= "Предупреждать перед следующей телепортацией",
	TimerTeleport		= "Отсчет времени до телепортации"
})

L:SetMiscLocalization({
	Pull				= "Пришло ваше время..."
})

---------------
--  Loatheb  --
---------------
L = DBM:GetModLocalization("Loatheb")

L:SetGeneralLocalization({
	name = "Лотхиб"
})

L:SetWarningLocalization({
	WarningHealSoon	= "Можно исцелять через 3 секунды",
	WarningHealNow	= "Исцеляйте сейчас"
})

L:SetOptionLocalization({
	WarningHealSoon		= "Предупреждать заранее перед 3-х секундным окном исцеления",
	WarningHealNow		= "Предупреждение для 3-х секундного окна исцеления"
})

-----------------
--  Patchwerk  --
-----------------
L = DBM:GetModLocalization("Patchwerk")

L:SetGeneralLocalization({
	name = "Лоскутик"
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	yell1			= "Лоскутик хочет поиграть!",
	yell2			= "Кел'Тузад объявил Лоскутика воплощением войны!"
})

-----------------
--  Grobbulus  --
-----------------
L = DBM:GetModLocalization("Grobbulus")

L:SetGeneralLocalization({
	name = "Гроббулус"
})

-------------
--  Gluth  --
-------------
L = DBM:GetModLocalization("Gluth")

L:SetGeneralLocalization({
	name = "Глут"
})

----------------
--  Thaddius  --
----------------
L = DBM:GetModLocalization("Thaddius")

L:SetGeneralLocalization({
	name = "Таддиус"
})

L:SetMiscLocalization({
	Yell	= "Сталагг сокрушит вас!",
	Emote	= "Катушка Теслы перезагружается!",
	Emote2	= "Катушка Теслы теряет связь!",
	Boss1	= "Фойген",
	Boss2	= "Сталагг",
	Charge1 = "отрицательную",
	Charge2 = "положительную"
})

L:SetOptionLocalization({
	WarningChargeChanged	= "Показывать предупреждение, когда Ваша полярность изменена",
	WarningChargeNotChanged	= "Показывать предупреждение, когда Ваша полярность не изменена",
	AirowEnabled			= "Показывать стрелки во время смены полярности",
	TwoCamp					= "Показывать стрелки (обычная \"2-сторонняя\" стратегия)",
	ArrowsRightLeft			= "Показывать стрелки влево/вправо для \"4-сторонней\" стратегии (показать стрелку влево, если полярность изменилась, вправо - не изменилась)",
	ArrowsInverse			= "Обратная \"4-сторонняя\" стратегия (вправо, если полярность изменена, влево - не изменена)"
})

L:SetWarningLocalization({
	WarningChargeChanged	= "Полярность изменена на %s",
	WarningChargeNotChanged	= "Полярность не изменена"
})

----------------------------
--  Instructor Razuvious  --
----------------------------
L = DBM:GetModLocalization("Razuvious")

L:SetGeneralLocalization({
	name = "Инструктор Разувий"
})

L:SetMiscLocalization({
	Yell1 = "Покажите мне, на что способны!",
	Yell2 = "Обучение окончено! Покажите мне, что вы усвоили!",
	Yell3 = "Вспомните, чему я вас учил!",
	Yell4 = "Выше ногу! Или у тебя с этим проблемы?"
})

L:SetOptionLocalization({
	WarningShieldWallSoon	= "Предупреждать о скором исчезновении Стены костей"
})

L:SetWarningLocalization({
	WarningShieldWallSoon	= "Стена костей закончится через 5 секунд"
})

----------------------------
--  Gothik the Harvester  --
----------------------------
L = DBM:GetModLocalization("Gothik")

L:SetGeneralLocalization({
	name = "Готик Жнец"
})

L:SetOptionLocalization({
	TimerWave			= "Отсчет времени до следующей волны",
	TimerPhase2			= "Отсчет времени до фазы 2",
	WarningWaveSoon		= "Предупреждать перед следующей волной",
	WarningWaveSpawned	= "Предупреждение для волны призыва",
	WarningRiderDown	= "Предупреждение, когда всадник мертв",
	WarningKnightDown	= "Предупреждение, когда рыцарь мертв"
})

L:SetTimerLocalization({
	TimerWave	= "Волна %d",
	TimerPhase2	= "Фаза 2"
})

L:SetWarningLocalization({
	WarningWaveSoon		= "Волна %d: %s через 3 секунды",
	WarningWaveSpawned	= "Волна %d: %s призван",
	WarningRiderDown	= "Всадник мертв",
	WarningKnightDown	= "Рыцарь мертв",
	WarningPhase2		= "Фаза 2"
})

L:SetMiscLocalization({
	yell			= "Глупо было искать свою смерть.",
	WarningWave1	= "%d %s",
	WarningWave2	= "%d %s и %d %s",
	WarningWave3	= "%d %s, %d %s и %d %s",
	Trainee			= "Ученика",
	Knight			= "Рыцаря",
	Rider			= "Всадника"
})

---------------------
--  Four Horsemen  --
---------------------
L = DBM:GetModLocalization("Horsemen")

L:SetGeneralLocalization({
	name = "Четыре Всадника"
})

L:SetOptionLocalization({
	WarningMarkSoon				= "Предупреждать перед следующими знаками",
	WarningMarkNow				= "Предупреждение для знаков",
	SpecialWarningMarkOnPlayer	= "Спецпредупреждение, когда на Вас более 4-х знаков",
	timerMark					= "Показать таймер для следующего знака Всадника (с количеством)"
})

L:SetTimerLocalization({
	timerMark	= "Метка %d",
})

L:SetWarningLocalization({
	WarningMarkSoon				= "Метка %d через 3 секунды",
	WarningMarkNow				= "Метка %d",
	SpecialWarningMarkOnPlayer	= "%s: %s"
})

L:SetMiscLocalization({
	Korthazz	= "Тан Кортазз",
	Rivendare	= "Барон Ривендер",
	Blaumeux	= "Леди Бломе",
	Zeliek		= "Сэр Зелиек"
})

-----------------
--  Sapphiron  --
-----------------
L = DBM:GetModLocalization("Sapphiron")

L:SetGeneralLocalization({
	name = "Сапфирон"
})

L:SetOptionLocalization({
	WarningAirPhaseSoon	= "Предупреждать о приближении Воздушной фазы",
	WarningAirPhaseNow	= "Объявлять Воздушную фазу",
	WarningLanded		= "Объявлять Наземную фазу",
	TimerAir			= "Отсчет времени до Воздушной фазы",
	TimerLanding		= "Отсчет времени до приземления"
})

L:SetMiscLocalization({
	EmoteBreath			= "%s делает глубокий вдох.",
})

L:SetWarningLocalization({
	WarningAirPhaseSoon	= "Воздушная фаза через 10 секунд",
	WarningAirPhaseNow	= "Воздушная фаза",
	WarningLanded		= "Сапфирон приземляется"
})

L:SetTimerLocalization({
	TimerAir		= "Воздушная фаза",
	TimerLanding	= "Приземление"
})

------------------
--  Kel'Thuzad  --
------------------

L = DBM:GetModLocalization("Kel'Thuzad")

L:SetGeneralLocalization({
	name = "Кел'Тузад"
})

L:SetOptionLocalization({
	TimerPhase2			= "Отсчет времени до фазы 2",
	specwarnP2Soon		= "Спецпредупреждение за 10 секунд до вступления Кел'Тузада в бой",
	warnAddsSoon		= "Предупреждать заранее о Стражах Ледяной Короны"
})

L:SetMiscLocalization({
	Yell = "Соратники, слуги, солдаты холодной тьмы! Повинуйтесь зову Кел'Тузада!"
})

L:SetWarningLocalization({
	specwarnP2Soon	= "Кел'Тузад вступает в бой через 10 секунд",
	warnAddsSoon	= "Скоро прибытие Стражей Ледяной Короны"
})

L:SetTimerLocalization({
	TimerPhase2	= "Фаза 2"
})

----------------------------
--  The Obsidian Sanctum  --
----------------------------
--  Shadron  --
---------------
L = DBM:GetModLocalization("Shadron")

L:SetGeneralLocalization({
	name = "Шадрон"
})

----------------
--  Tenebron  --
----------------
L = DBM:GetModLocalization("Tenebron")

L:SetGeneralLocalization({
	name = "Тенеброн"
})

----------------
--  Vesperon  --
----------------
L = DBM:GetModLocalization("Vesperon")

L:SetGeneralLocalization({
	name = "Весперон"
})

------------------
--  Sartharion  --
------------------
L = DBM:GetModLocalization("Sartharion")

L:SetGeneralLocalization({
	name = "Сартарион"
})

L:SetWarningLocalization({
	WarningTenebron			= "Прибытие Тенеброна",
	WarningShadron			= "Прибытие Шадрона",
	WarningVesperon			= "Прибытие Весперона",
	WarningFireWall			= "Огненная стена",
	WarningVesperonPortal	= "Портал Весперона",
	WarningTenebronPortal	= "Портал Тенеброна",
	WarningShadronPortal	= "Портал Шадрона"
})

L:SetTimerLocalization({
	TimerTenebron	= "Прибытие Тенеброна",
	TimerShadron	= "Прибытие Шадрона",
	TimerVesperon	= "Прибытие Весперона"
})

L:SetOptionLocalization({
	AnnounceFails			= "Объявлять игроков, потерпевших неудачу в Огненной стене и Расщелине тьмы<br/>(требуются права лидера или помощника)",
	TimerTenebron			= "Отсчет времени до прибытия Тенеброна",
	TimerShadron			= "Отсчет времени до прибытия Шадрона",
	TimerVesperon			= "Отсчет времени до прибытия Весперона",
	WarningFireWall			= "Cпецпредупреждение для Огненной стены",
	WarningTenebron			= "Объявлять прибытие Тенеброна",
	WarningShadron			= "Объявлять прибытие Шадрона",
	WarningVesperon			= "Объявлять прибытие Весперона",
	WarningTenebronPortal	= "Cпецпредупреждение для порталов Тенеброна",
	WarningShadronPortal	= "Cпецпредупреждение для порталов Шадрона",
	WarningVesperonPortal	= "Cпецпредупреждение для порталов Весперона"
})

L:SetMiscLocalization({
	Wall			= "Лава вокруг %s начинает бурлить!",
	Portal			= "%s открывает сумрачный портал!",
	NameTenebron	= "Тенеброн",
	NameShadron		= "Шадрон",
	NameVesperon	= "Весперон",
	FireWallOn		= "Огненная стена: %s",
	VoidZoneOn		= "Расщелина тьмы: %s",
	VoidZones		= "Потерпели неудачу в Расщелине тьмы (за эту попытку): %s",
	FireWalls		= "Потерпели неудачу в Огненной стене (за эту попытку): %s"
})

---------------
--  Malygos  --
---------------
L = DBM:GetModLocalization("Malygos")

L:SetGeneralLocalization({
	name = "Малигос"
})

L:SetMiscLocalization({
	YellPull	= "Мое терпение лопнуло! Пора от вас избавиться!",
	EmoteSpark	= "Искра мощи появляется из ближайшей расселины!",
	YellPhase2	= "Я надеялся быстро с вами покончить",
	YellBreath	= "Пока я дышу, вам не добиться своего!",
	YellPhase3	= "Вот и ваши благодетели появились"
})

-----------------------
--  Flame Leviathan  --
-----------------------
L = DBM:GetModLocalization("FlameLeviathan")

L:SetGeneralLocalization{
	name = "Огненный Левиафан"
}

L:SetMiscLocalization{
	YellPull	= "Обнаружены противники. Запуск протокола оценки угрозы. Главная цель выявлена. Повторный анализ через 30 секунд.",
	Emote		= "%%s наводится на (%S+)%."
}

L:SetWarningLocalization{
	PursueWarn				= "Преследуется >%s<",
	warnNextPursueSoon		= "Смена цели через 5 секунд",
	SpecialPursueWarnYou	= "Вас преследуют - бегите",
	warnWardofLife			= "Призыв Защитника жизни"
}

L:SetOptionLocalization{
	SpecialPursueWarnYou	= "Спецпредупреждение, когда на Вас $spell:62374",
	PursueWarn				= "Объявлять цели заклинания $spell:62374",
	warnNextPursueSoon		= "Предупреждать заранее о следующем $spell:62374",
	warnWardofLife			= "Спецпредупреждение для призыва Защитника жизни"
}

--------------------------------
--  Ignis the Furnace Master  --
--------------------------------
L = DBM:GetModLocalization("Ignis")

L:SetGeneralLocalization{
	name = "Повелитель Горнов Игнис"
}

L:SetOptionLocalization{
	SlagPotIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(63477)
}

------------------
--  Razorscale  --
------------------
L = DBM:GetModLocalization("Razorscale")

L:SetGeneralLocalization{
	name = "Острокрылая"
}

L:SetWarningLocalization{
	warnTurretsReadySoon		= "Гарпунные пушки будут собраны через 20 секунд",
	warnTurretsReady			= "Гарпунные пушки собраны"
}

L:SetTimerLocalization{
	timerTurret1	= "Гарпунная пушка 1",
	timerTurret2	= "Гарпунная пушка 2",
	timerTurret3	= "Гарпунная пушка 3",
	timerTurret4	= "Гарпунная пушка 4",
	timerGrounded	= "на земле"
}

L:SetOptionLocalization{
	warnTurretsReadySoon		= "Предварительное предупреждение для пушек",
	warnTurretsReady			= "Предупреждение для пушек",
	timerTurret1				= "Отсчет времени до пушки 1",
	timerTurret2				= "Отсчет времени до пушки 2",
	timerTurret3				= "Отсчет времени до пушки 3 (25 чел.)",
	timerTurret4				= "Отсчет времени до пушки 4 (25 чел.)",
	timerGrounded			    = "Отсчет времени для наземной фазы"
}

L:SetMiscLocalization{
	YellAir				= "Дайте время подготовить пушки.",
	YellAir2			= "Огонь прекратился! Надо починить пушки!",
	YellGround			= "Быстрее! Сейчас она снова взлетит!",
	EmotePhase2			= "%%s обессилела и больше не может летать!"
}

----------------------------
--  XT-002 Deconstructor  --
----------------------------
L = DBM:GetModLocalization("XT002")

L:SetGeneralLocalization{
	name = "Разрушитель XT-002"
}

--------------------
--  Iron Council  --
--------------------
L = DBM:GetModLocalization("IronCouncil")

L:SetGeneralLocalization{
	name = "Железное Собрание"
}

L:SetOptionLocalization{
	AlwaysWarnOnOverload		= "Всегда предупреждать при $spell:63481<br/>(иначе, только когда босс в цели)"
}

L:SetMiscLocalization{
	Steelbreaker		= "Сталелом",
	RunemasterMolgeim	= "Мастер рун Молгейм",
	StormcallerBrundir 	= "Буревестник Брундир"
}

----------------------------
--  Algalon the Observer  --
----------------------------
L = DBM:GetModLocalization("Algalon")

L:SetGeneralLocalization{
	name = "Алгалон Наблюдатель"
}

L:SetTimerLocalization{
	NextCollapsingStar		= "Вспыхивающая звезда",
	TimerCombatStart		= "Битва начнется через"
}

L:SetWarningLocalization{
	WarnPhase2Soon			= "Скоро фаза 2",
	warnStarLow				= "У Вспыхивающей звезды мало здоровья"
}

L:SetOptionLocalization{
	WarningPhasePunch		= "Объявлять цели заклинания Фазовый удар",
	NextCollapsingStar		= "Отсчет времени до появления Вспыхивающей звезды",
	TimerCombatStart		= "Отсчет времени до начала боя",
	WarnPhase2Soon			= "Предупреждать заранее о фазе 2 (на ~23%)",
	warnStarLow				= "Спецпредупреждение, когда у Вспыхивающей звезды мало здоровья (на ~25%)"
}

L:SetMiscLocalization{
	YellPull				= "Ваши действия нелогичны. Все возможные исходы этой схватки просчитаны. Пантеон получит сообщение от Наблюдателя в любом случае.",
	YellKill				= "Я видел миры, охваченные пламенем Творцов. Их жители гибли, не успев издать ни звука. Я был свидетелем того, как галактики рождались и умирали в мгновение ока. И все время я оставался холодным... и безразличным. Я. Не чувствовал. Ничего. Триллионы загубленных судеб. Неужели все они были подобны вам? Неужели все они так же любили жизнь?",
	Emote_CollapsingStar	= "%s призывает вспыхивающие звезды!",
	Phase2					= "Узрите чудо созидания!",
	FirstPull				= "Взгляните на мир моими глазами: узрите необъятную вселенную, непостижимую даже для величайших умов.",
	PullCheck				= "Алгалон подаст сигнал бедствия через (%d+) мин."
}

----------------
--  Kologarn  --
----------------
L = DBM:GetModLocalization("Kologarn")

L:SetGeneralLocalization{
	name = "Кологарн"
}

L:SetTimerLocalization{
	timerLeftArm		= "Возрождение левой руки",
	timerRightArm		= "Возрождение правой руки",
	achievementDisarmed	= "Обезоружен"
}

L:SetOptionLocalization{
	timerLeftArm			= "Отсчет времени до Возрождения левой руки",
	timerRightArm			= "Отсчет времени до Возрождения правой руки",
	achievementDisarmed		= "Отсчет времени для достижения Обезоружен"
}

L:SetMiscLocalization{
	Yell_Trigger_arm_left	= "Царапина...",
	Yell_Trigger_arm_right	= "Всего лишь плоть!",
	Health_Body				= "Кологарн",
	Health_Right_Arm		= "Правая рука",
	Health_Left_Arm			= "Левая рука",
	FocusedEyebeam			= "%s устремляет на вас свой взгляд!"
}

---------------
--  Auriaya  --
---------------
L = DBM:GetModLocalization("Auriaya")

L:SetGeneralLocalization{
	name = "Ауриайа"
}

L:SetMiscLocalization{
	Defender = "Дикий эащитник (%d)",
	YellPull = "Вы зря сюда заявились!"
}

L:SetTimerLocalization{
	timerDefender	= "Возрождение Дикого защитника"
}

L:SetWarningLocalization{
	WarnCatDied		= "Дикий эащитник погибает (осталось %d жизней)",
	WarnCatDiedOne	= "Дикий эащитник погибает (осталась 1 жизнь)"
}

L:SetOptionLocalization{
	WarnCatDied		= "Предупреждение, когда Дикий защитник погибает",
	WarnCatDiedOne	= "Предупреждение, когда у Дикого защитника остается 1 жизнь",
	timerDefender	= "Отсчет времени до возрождения Дикого защитника"
}

-------------
--  Hodir  --
-------------
L = DBM:GetModLocalization("Hodir")

L:SetGeneralLocalization{
	name = "Ходир"
}

L:SetTimerLocalization{
	TimerHardmode	= "Разрушение тайника"
}

L:SetOptionLocalization{
	TimerHardmode	= "Показывать таймер для сложного режима"
}

L:SetMiscLocalization{
	Pull		= "Вы будете наказаны за это вторжение!",
	YellKill	= "Наконец-то я... свободен от его оков..."
}

--------------
--  Thorim  --
--------------
L = DBM:GetModLocalization("Thorim")

L:SetGeneralLocalization{
	name = "Торим"
}

L:SetTimerLocalization{
	TimerHardmode	= "Сложный режим"
}

L:SetOptionLocalization{
	TimerHardmode	= "Отсчет времени для сложного режима",
	AnnounceFails	= "Объявлять игроков, попавших под $spell:62017, в рейд-чат<br/>(требуются права лидера или помощника)"
}

L:SetMiscLocalization{
	YellPhase1	= "Незваные гости! Вы заплатите за то, что посмели вмешаться... Погодите, вы...",
	YellPhase2	= "Бесстыжие выскочки, вы решили бросить вызов мне лично? Я сокрушу вас всех!",
	YellKill	= "Придержите мечи! Я сдаюсь.",
	ChargeOn	= "Разряд молнии: %s",
	Charge		= "Попали под Разряд молнии (в этом бою): %s"
}

-------------
--  Freya  --
-------------
L = DBM:GetModLocalization("Freya")

L:SetGeneralLocalization{
	name = "Фрейя"
}

L:SetMiscLocalization{
	SpawnYell          = "Помогите мне, дети мои!",
	WaterSpirit        = "Древний дух воды",
	Snaplasher         = "Хватоплет",
	StormLasher        = "Грозовой плеточник",
	YellKill           = "Он больше не властен надо мной. Мой взор снова ясен. Благодарю вас, герои."
}

L:SetWarningLocalization{
	WarnSimulKill	= "Первый помощник погиб - воскрешение через ~12 сек."
}

L:SetTimerLocalization{
	TimerSimulKill	= "Воскрешение"
}

L:SetOptionLocalization{
	WarnSimulKill	= "Объявлять, когда первый монстр погибает",
	TimerSimulKill	= "Отсчет времени до воскрешения монстров"
}

----------------------
--  Freya's Elders  --
----------------------
L = DBM:GetModLocalization("Freya_Elders")

L:SetGeneralLocalization{
	name = "Древни Фрейи"
}

---------------
--  Mimiron  --
---------------
L = DBM:GetModLocalization("Mimiron")

L:SetGeneralLocalization{
	name = "Мимирон"
}

L:SetWarningLocalization{
	MagneticCore		= "Магнитное ядро у >%s<",
	WarnBombSpawn		= "Бомбот"
}

L:SetTimerLocalization{
	TimerHardmode	= "Сложный режим - Самоуничтожение",
	TimeToPhase2	= "Фаза 2",
	TimeToPhase3	= "Фаза 3",
	TimeToPhase4	= "Фаза 4"
}

L:SetOptionLocalization{
	TimeToPhase2			= "Отсчет времени для фазы 2",
	TimeToPhase3			= "Отсчет времени для фазы 3",
	TimeToPhase4			= "Отсчет времени для фазы 4",
	MagneticCore			= "Объявлять подобравших Магнитное ядро",
	WarnBombSpawn			= "Предупреждение о Бомботах",
	TimerHardmode			= "Отсчет времени для сложного режима"
}

L:SetMiscLocalization{
	MobPhase1		= "Левиафан II",
	MobPhase2		= "VX-001 <Противопехотная пушка>",
	MobPhase3		= "Воздушное судно",
	YellPull		= "У нас мало времени, друзья! Вы поможете испытать новейшее и величайшее из моих изобретений. И учтите: после того, что вы натворили с XT-002, отказываться просто некрасиво.",
	YellHardPull	= "Так, зачем вы это сделали? Разве вы не видели надпись \"НЕ НАЖИМАЙТЕ ЭТУ КНОПКУ!\"? Ну как мы сумеем завершить испытания при включенном механизме самоликвидации, а?",
	YellPhase2		= "ПРЕВОСХОДНО! Просто восхитительный результат! Целостность обшивки – 98,9 процента! Почти что ни царапинки! Продолжаем!",
	YellPhase3		= "Спасибо, друзья! Благодаря вам я получил ценнейшие сведения! Так, а куда же я дел... – ах, вот куда.",
	YellPhase4		= "Фаза предварительной проверки завершена. Пора начать главный тест!"
}

---------------------
--  General Vezax  --
---------------------
L = DBM:GetModLocalization("GeneralVezax")

L:SetGeneralLocalization{
	name = "Генерал Везакс"
}

L:SetWarningLocalization{
	specWarnAnimus 	= "Саронитовый анимус - смените цель"
}

L:SetTimerLocalization{
	hardmodeSpawn = "Саронитовый анимус"
}

L:SetOptionLocalization{
	specWarnAnimus 	= "Спецпредупреждение для переключения целей на Саронитового анимуса",
	hardmodeSpawn	= "Показать таймер появления Саронитового анимуса (сложный режим)"
}

L:SetMiscLocalization{
	EmoteSaroniteVapors	= "Облако саронитовых паров образовывается поблизости!"
}

------------------
--  Yogg-Saron  --
------------------
L = DBM:GetModLocalization("YoggSaron")

L:SetGeneralLocalization{
	name = "Йогг-Сарон"
}

L:SetWarningLocalization{
	WarningGuardianSpawned 			= "Появился Страж %d",
	WarningCrusherTentacleSpawned	= "Появилось Тяжелое щупальце",
	WarningSanity 					= "Осталось %d Здравомыслия",
	SpecWarnSanity 					= "Осталось %d Здравомыслия",
	SpecWarnMadnessOutNow			= "Доведение до помешательства заканчивается - выбегайте",
	WarnBrainPortalSoon				= "Портал Разума через 10 секунд",
	specWarnBrainPortalSoon			= "Скоро Портал Разума"
}

L:SetTimerLocalization{
	NextPortal	= "Портал Разума"
}

L:SetOptionLocalization{
	WarningGuardianSpawned			= "Показывать предупреждение о появлении Стража",
	WarningCrusherTentacleSpawned	= "Показывать предупреждение о появлении Тяжелого щупальца",
	WarningSanity					= "Показывать предупреждение, когда у Вас мало $spell:63050",
	SpecWarnSanity					= "Спецпредупреждение, когда у Вас очень мало $spell:63050",
	WarnBrainPortalSoon				= "Предупреждать заранее о Портале Разума",
	SpecWarnMadnessOutNow			= "Спецпредупреждение незадолго до окончания $spell:64059",
	specWarnBrainPortalSoon			= "Спецпредупреждение о следующем Портале Разума",
	NextPortal						= "Отсчет времени до следующего Портала Разума"
}

L:SetMiscLocalization{
	YellPull 			= "Скоро мы сразимся с главарем этих извергов! Обратите гнев и ненависть против его прислужников!",
	YellPhase2	 		= "Я – это сон наяву.",
	Sara 				= "Сара"
}

--------------
--  Onyxia  --
--------------
L = DBM:GetModLocalization("Onyxia")

L:SetGeneralLocalization{
	name = "Ониксия"
}

L:SetWarningLocalization{
	WarnWhelpsSoon		= "Скоро дракончики Ониксии"
}

L:SetTimerLocalization{
	TimerWhelps	= "Вызов дракончиков Ониксии"
}

L:SetOptionLocalization{
	TimerWhelps				= "Отсчет времени до дракончиков Ониксии",
	WarnWhelpsSoon			= "Предупреждать заранее о дракончиках Ониксии",
	SoundWTF3				= "Воспроизводить забавное озвучивание легендарного классического рейда на Ониксию (англ.)"
}

L:SetMiscLocalization{
	YellPull = "Вот это сюрприз. Обычно, чтобы найти обед, мне приходится покидать логово.",
	YellP2 = "Эта бессмысленная возня вгоняет меня в тоску. Я сожгу вас всех!",
	YellP3 = "Похоже, вам требуется преподать еще один урок, смертные!"
}

------------------------
--  Northrend Beasts  --
------------------------
L = DBM:GetModLocalization("NorthrendBeasts")

L:SetGeneralLocalization{
	name = "Чудовища Нордскола"
}

L:SetWarningLocalization{
	WarningSnobold		= "Снобольд-вассал появился на >%s<"
}

L:SetTimerLocalization{
	TimerNextBoss		= "Следующий босс",
	TimerEmerge			= "Появление",
	TimerSubmerge		= "Зарывание"
}

L:SetOptionLocalization{
	WarningSnobold				= "Предупреждение о призыве Снобольда-вассала",
	ClearIconsOnIceHowl			= "Снимать все иконки перед Топотом",
	TimerNextBoss				= "Отсчет времени до появления следующего противника",
	TimerEmerge					= "Отсчет времени до появления",
	TimerSubmerge				= "Отсчет времени до зарывания",
	IcehowlArrow				= "Показывать стрелку, когда Ледяной Рев готовится сделать рывок на цель рядом с Вами"
}

L:SetMiscLocalization{
	Charge		= "^%%s глядит на (%S+) и испускает гортанный вой!",
	CombatStart	= "Из самых глубоких и темных пещер Грозовой Гряды был призван Гормок Пронзающий Бивень! В бой, герои!",
	Phase2		= "Приготовьтесь к схватке с близнецами-чудовищами, Кислотной Утробой и Жуткой Чешуей!",
	Phase3		= "В воздухе повеяло ледяным дыханием следующего бойца: на арену выходит Ледяной Рев! Сражайтесь или погибните, чемпионы!",
	Gormok		= "Гормок Пронзающий Бивень",
	Acidmaw		= "Кислотная Утроба",
	Dreadscale	= "Жуткая Чешуя",
	Icehowl		= "Ледяной Рев"
}

---------------------
--  Lord Jaraxxus  --
---------------------
L = DBM:GetModLocalization("Jaraxxus")

L:SetGeneralLocalization{
	name = "Лорд Джараксус"
}

L:SetOptionLocalization{
	IncinerateShieldFrame		= "Показать здоровье босса с индикатором здоровья для Испепеления плоти"
}

L:SetMiscLocalization{
	IncinerateTarget	= "Испепеление плоти: %s",
	FirstPull	= "Сейчас великий чернокнижник Вилфред Непопамс призовет вашего нового противника. Готовьтесь к бою!"
}

-------------------------
--  Faction Champions  --
-------------------------
L = DBM:GetModLocalization("Champions")

L:SetGeneralLocalization{
	name = "Чемпионы фракций"
}

L:SetMiscLocalization{
	AllianceVictory		= "СЛАВА АЛЬЯНСУ!",
	HordeVictory		= "Не щадите никого, герои Орды! ЛОК'ТАР ОГАР!"
}

---------------------
--  Val'kyr Twins  --
---------------------
L = DBM:GetModLocalization("ValkTwins")

L:SetGeneralLocalization{
	name = "Валь'киры-близнецы"
}

L:SetTimerLocalization{
	TimerSpecialSpell	= "Следующая спецспособность"
}

L:SetWarningLocalization{
	WarnSpecialSpellSoon		= "Скоро спецспособность",
	SpecWarnSpecial				= "Смена цвета",
	SpecWarnSwitchTarget		= "Смена цели",
	SpecWarnKickNow				= "Прерывание",
	WarningTouchDebuff			= "Отрицательный эффект на >%s<",
	WarningPoweroftheTwins2		= "Сила близнецов - больше исцеления на >%s<",
}

L:SetMiscLocalization{
	Fjola		= "Фьола Погибель Света",
	Eydis		= "Эйдис Погибель Тьмы"
}

L:SetOptionLocalization{
	TimerSpecialSpell			= "Отсчет времени до перезарядки спецспособности",
	WarnSpecialSpellSoon		= "Предупреждение о следующуюей спецспособность",
	SpecWarnSpecial				= "Спецпредупреждение для смены цветов",
	SpecWarnSwitchTarget		= "Спецпредупреждение для других, когда босс читает заклинание",
	SpecWarnKickNow				= "Спецпредупреждение, когда Вы должы прервать заклинание",
	SpecialWarnOnDebuff			= "Спецпредупреждение, когда отрицательный эффект",
	SetIconOnDebuffTarget		= "Установить метку на получившего отрицательный эффект (героический режим)",
	WarningTouchDebuff			= "Объявлять цели, получившие отрицательный эффект",
	WarningPoweroftheTwins2		= "Объявлять цель под воздействем Силы близнецов"
}

-----------------
--  Anub'arak  --
-----------------
L = DBM:GetModLocalization("Anub'arak_Coliseum")

L:SetGeneralLocalization{
	name 					= "Ануб'арак"
}

L:SetTimerLocalization{
	TimerEmerge				= "Появление через",
	TimerSubmerge			= "Зарывание через",
	timerAdds				= "Призыв помощников через"
}

L:SetWarningLocalization{
	WarnEmerge				= "Ануб'арак появляется",
	WarnEmergeSoon			= "Появление через 10 сек",
	WarnSubmerge			= "Ануб'арак закапывается",
	WarnSubmergeSoon		= "Зарывание через 10 сек",
	specWarnSubmergeSoon	= "Зарывание через 10 сек!",
	warnAdds				= "Новые помощники"
}

L:SetMiscLocalization{
	Emerge				= "вылезает на поверхность!",
	Burrow				= "зарывается в землю!",
	PcoldIconSet		= "Метка холода {rt%d} установлена на: %s",
	PcoldIconRemoved	= "Метка холода снята с: %s"
}

L:SetOptionLocalization{
	WarnEmerge				= "Предупреждение о появлении",
	WarnEmergeSoon			= "Предупреждать заранее о появлении",
	WarnSubmerge			= "Предупреждение о закапывании",
	WarnSubmergeSoon		= "Предупреждать заранее о закапывании",
	specWarnSubmergeSoon	= "Спецпредупреждение о скором закапывании",
	warnAdds				= "Предупреждение о призыве помощников",
	timerAdds				= "Отсчет времени до призыва помощников",
	TimerEmerge				= "Отсчет времени до появления",
	TimerSubmerge			= "Отсчет времени до закапывания",
	AnnouncePColdIcons		= "Объявлять метки целей заклинания $spell:66013 в рейд-чат<br/>(требуются права лидера или помощника)",
	AnnouncePColdIconsRemoved	= "Объявлять также о снятии меток с целей заклинания $spell:66013<br/>(требуются права лидера или помощника)"
}

----------------------
--  Lord Marrowgar  --
----------------------
L = DBM:GetModLocalization("LordMarrowgar")

L:SetGeneralLocalization{
	name = "Лорд Ребрад"
}

-------------------------
--  Lady Deathwhisper  --
-------------------------
L = DBM:GetModLocalization("Deathwhisper")

L:SetGeneralLocalization{
	name = "Леди Смертный Шепот"
}

L:SetTimerLocalization{
	TimerAdds	= "Призыв помощников"
}

L:SetWarningLocalization{
	WarnReanimating				= "Помощник воскрешается",			-- Reanimating an adherent or fanatic
	WarnAddsSoon				= "Скоро призыв помощников"
}

L:SetOptionLocalization{
	WarnAddsSoon				= "Предупреждать заранее о призыве помощников",
	WarnReanimating				= "Предупреждение при воскрешении помощников",	-- Reanimated Adherent/Fanatic spawning
	TimerAdds					= "Отсчет времени до призыва помощников"
}

L:SetMiscLocalization{
	YellReanimatedFanatic	= "Восстань и обрети истинную форму!"
}

----------------------
--  Gunship Battle  --
----------------------
L = DBM:GetModLocalization("GunshipBattle")

L:SetGeneralLocalization{
	name = "Боевой корабль"
}

L:SetWarningLocalization{
	WarnAddsSoon	= "Скоро новые помощники"
}

L:SetOptionLocalization{
	WarnAddsSoon		= "Предупреждать заранее о призыве помощников",
	TimerAdds			= "Отсчет времени до новых помощников"
}

L:SetTimerLocalization{
	TimerAdds			= "Призыв помощников"
}

L:SetMiscLocalization{
	PullAlliance	= "Запускайте двигатели! Летим навстречу судьбе.",
	PullHorde		= "Воспряньте, сыны и дочери Орды! Сегодня мы будем биться со смертельным врагом! ЛОК'ТАР ОГАР!",
	AddsAlliance	= "Разрушители, сержанты, в бой!",
	AddsHorde		= "Пехота, сержанты, в бой!",
	MageAlliance	= "Корабль под обстрелом! Боевого мага сюда, пусть заткнет эти пушки!",
	MageHorde		= "Корабль под обстрелом! Заклинателя сюда, пусть заткнет эти пушки!",
	Hammer 			= "Orgrim's Hammer",--Need to check in detail
	Skybreaker		= "Skybreaker"--Need to check in detail
}

-----------------------------
--  Deathbringer Saurfang  --
-----------------------------
L = DBM:GetModLocalization("Deathbringer")

L:SetGeneralLocalization{
	name = "Саурфанг Смертоносный"
}

L:SetOptionLocalization{
	RunePowerFrame			= "Показывать здоровье босса + индикатор для $spell:72371"
}

L:SetMiscLocalization{
	PullAlliance		= "Все павшие воины Орды, все дохлые псы Альянса – все пополнят армию Короля-лича. Даже сейчас валь'киры воскрешают ваших покойников, чтобы те стали частью Плети!",
	PullHorde			= "Кор'крон, выдвигайтесь! Герои, будьте начеку. Плеть только что..."
}

-----------------
--  Festergut  --
-----------------
L = DBM:GetModLocalization("Festergut")

L:SetGeneralLocalization{
	name = "Тухлопуз"
}

L:SetOptionLocalization{
	AnnounceSporeIcons	= "Объявлять метки целей заклинания $spell:69279 в рейд-чат<br/>(требуются права помощника)",
	AchievementCheck	= "Объявлять о провале достижения 'Масок нет!' в рейд-чат<br/>(требуются права помощника)"
}

L:SetMiscLocalization{
	SporeSet	= "Метка Газообразных спор {rt%d} установлена на: %s",
	AchievementFailed	= ">> ДОСТИЖЕНИЕ ПРОВАЛЕНО: %s получил %d стаков Невосприимчивости к гнили <<"
}

---------------
--  Rotface  --
---------------
L = DBM:GetModLocalization("Rotface")

L:SetGeneralLocalization{
	name = "Гниломорд"
}

L:SetWarningLocalization{
	WarnOozeSpawn				= "Малый слизнюк",
	SpecWarnLittleOoze			= "Малый слизнюк атакует вас - бегите"
}

L:SetOptionLocalization{
	WarnOozeSpawn				= "Предупреждение при появлении Малого слизнюка",
	SpecWarnLittleOoze			= "Спецпредупреждение, когда Вас атакует Малый слизнюк",
}

L:SetMiscLocalization{
	YellSlimePipes1	= "Отличные новости, народ! Я починил трубы для подачи ядовитой слизи!",	-- Профессор Мерзоцид
	YellSlimePipes2	= "Отличные новости, народ! Слизь снова потекла!"	-- Профессор Мерзоцид
}

---------------------------
--  Professor Putricide  --
---------------------------
L = DBM:GetModLocalization("Putricide")

L:SetGeneralLocalization{
	name = "Профессор Мерзоцид"
}

----------------------------
--  Blood Prince Council  --
----------------------------
L = DBM:GetModLocalization("BPCouncil")

L:SetGeneralLocalization{
	name = "Кровавый Совет"
}

L:SetWarningLocalization{
	WarnTargetSwitch		= "Смените цель на: %s",
	WarnTargetSwitchSoon	= "Скоро смена цели"
}

L:SetTimerLocalization{
	TimerTargetSwitch		= "Смена цели"
}

L:SetOptionLocalization{
	WarnTargetSwitch		= "Предупреждение о смене цели",-- Предупреждать, когда нужно нанести урон другому принцу
	WarnTargetSwitchSoon	= "Предупреждать заранее о смене цели",-- Каждые ~47 секунд вы должны дпсить другого принца
	TimerTargetSwitch		= "Отсчет времени до смены цели",
	ActivePrinceIcon		= "Устанавливать метку на наполненного силой Принца (череп)",
}

L:SetMiscLocalization{
	Keleseth			= "Принц Келесет",
	Taldaram			= "Принц Талдарам",
	Valanar				= "Принц Валанар",
	EmpoweredFlames		= "Жаркое пламя тянется к (%S+)!"
}

-----------------------------
--  Blood-Queen Lana'thel  --
-----------------------------
L = DBM:GetModLocalization("Lanathel")

L:SetGeneralLocalization{
	name = "Королева Лана'тель"
}

L:SetMiscLocalization{
	SwarmingShadows			= "Тени собираются и окружают (%S+)!",
	YellFrenzy				= "Я голоден!"
}

-----------------------------
--  Valithria Dreamwalker  --
-----------------------------
L = DBM:GetModLocalization("Valithria")

L:SetGeneralLocalization{
	name = "Валитрия Сноходица"
}

L:SetWarningLocalization{
	WarnPortalOpen	= "Открытие порталов"
}

L:SetTimerLocalization{
	TimerPortalsOpen		= "Открытие порталов",
	TimerPortalsClose		= "Закрытие порталов",
	TimerBlazingSkeleton	= "Исторгающий пламя скелет",
	TimerAbom				= "След. поганище"
}

L:SetOptionLocalization{
	SetIconOnBlazingSkeleton	= "Устанавливать метку на Исторгающего пламя скелета (череп)",
	WarnPortalOpen				= "Предупреждение об открытии порталов",
	TimerPortalsOpen			= "Отсчет времени до открытия порталов",
	TimerPortalsClose			= "Отсчет времени до закрытия порталов",
	TimerBlazingSkeleton		= "Отсчет времени до Исторгающего пламя скелета",
	TimerAbom					= "Отсчет времени до след. Прожорливого поганища (экспериментальный)"
}

L:SetMiscLocalization{
	YellPortals		= "Я открыла портал в Изумрудный Сон. Там вы найдете спасение, герои..."
}

------------------
--  Sindragosa  --
------------------
L = DBM:GetModLocalization("Sindragosa")

L:SetGeneralLocalization{
	name = "Синдрагоса"
}

L:SetWarningLocalization{
	WarnAirphase			= "Воздушная фаза",
	WarnGroundphaseSoon		= "Синдрагоса скоро приземлится"
}

L:SetTimerLocalization{
	TimerNextAirphase		= "След. воздушная фаза",
	TimerNextGroundphase	= "След. наземная фаза",
	AchievementMystic		= "Время для устранения Таинственной энергии"
}

L:SetOptionLocalization{
	WarnAirphase			= "Объявлять воздушную фазу",
	WarnGroundphaseSoon		= "Предупреждать заранее о наземной фазе",
	TimerNextAirphase		= "Отсчет времени до следующей воздушной фазы",
	TimerNextGroundphase	= "Отсчет времени до следующей наземной фазы",
	AnnounceFrostBeaconIcons= "Объявлять метки целей заклинания $spell:70126 в рейд-чат<br/>(требуются права помощника)",
	ClearIconsOnAirphase	= "Снимать все метки перед воздушной фазой",
	AchievementCheck		= "Объявлять предупреждения для достижения 'Таинственная дама'<br/>в рейд-чат (требуются права помощника)",
}

L:SetMiscLocalization{
	YellAirphase		= "Здесь ваше вторжение и окончится! Никто не уцелеет.",
	YellPhase2			= "А теперь почувствуйте всю мощь господина и погрузитесь в отчаяние!",
	YellAirphaseDem		= "Rikk zilthuras rikk zila Aman adare tiriosh ",--Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	YellPhase2Dem		= "Zar kiel xi romathIs zilthuras revos ruk toralar ",--Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	BeaconIconSet		= "Ледяная метка {rt%d} установлена на: %s",
	AchievementWarning	= "Предупреждение: %s получил 5 стаков Таинственной энергии",
	AchievementFailed	= ">> ДОСТИЖЕНИЕ ПРОВАЛЕНО: %s получил %d стаков Таинственной энергии <<"
}

---------------------
--  The Lich King  --
---------------------
L = DBM:GetModLocalization("LichKing")

L:SetGeneralLocalization{
	name = "Король-лич"
}

L:SetWarningLocalization{
	ValkyrWarning			= ">%s< был схвачен!",
	SpecWarnYouAreValkd		= "Вас схватили",
	WarnNecroticPlagueJump	= "Мертвящая чума перепрыгнула на >%s<",
	SpecWarnValkyrLow		= "У Валь'киры меньше 55%"
}

L:SetTimerLocalization{
	TimerRoleplay		= "Ролевая игра",
	PhaseTransition		= "Переходная фаза",
	TimerNecroticPlagueCleanse = "Очищение Мертвящей чумы"
}

L:SetOptionLocalization{
	TimerRoleplay			= "Отсчет времени для ролевой игры",
	WarnNecroticPlagueJump	= "Объявлять цели прыжков $spell:70337",
	TimerNecroticPlagueCleanse	= "Отсчет времени для очищения Мертвящей чумы до первого тика",
	PhaseTransition			= "Отсчет времени для переходной фазы",
	ValkyrWarning			= "Объявлять, кого схватили Валь'киры",
	SpecWarnYouAreValkd		= "Спецпредупреждение, когда Вас схватила Валь'кира",
	AnnounceValkGrabs		= "Объявлять игроков, схваченных Валь'кирами, в рейд-чат<br/>(требуются права помощника)",
	SpecWarnValkyrLow		= "Спецпредупреждение, когда у Валь'киры меньше 55% HP",
	AnnouncePlagueStack		= "Объявлять стаки заклинания $spell:70337 в рейд-чат (10 стаков, далее каждые 5)<br/>(требуются права помощника)"
}

L:SetMiscLocalization{
	LKPull					= "Неужели прибыли наконец хваленые силы Света? Мне бросить Ледяную Скорбь и сдаться на твою милость, Фордринг?",
	LKRoleplay				= "Что движет вами?.. Праведность? Не знаю...",
	ValkGrabbedIcon			= "Валь'кира {rt%d} схватила %s",
	ValkGrabbed				= "Валь'кира схватила %s",
	PlagueStackWarning		= "Предупреждение: %s получил %d стаков Мертвящей чумы",
	AchievementCompleted	= ">> ДОСТИЖЕНИЕ ВЫПОЛНЕНО: %s получил %d стаков Мертвящей чумы <<"
}

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("ICCTrash")

L:SetGeneralLocalization{
	name = "Трэш мобы Ледяной Короны"
}

L:SetWarningLocalization{
	SpecWarnTrapL		= "Ловушка активирована! - Заклятый страж освобожден",
	SpecWarnTrapP		= "Ловушка активирована! - приближаются Мстительные свежеватели",
	SpecWarnGosaEvent	= "Приближаются защитники Синдрагосы!"
}

L:SetOptionLocalization{
	SpecWarnTrapL		= "Спецпредупреждение для активации ловушки",
	SpecWarnTrapP		= "Спецпредупреждение для активации ловушки",
	SpecWarnGosaEvent	= "Спецпредупреждение для активации защитников Синдрагосы"
}

L:SetMiscLocalization{
	WarderTrap1			= "Кто... идет?",
	WarderTrap2			= "Я пробудился...",
	WarderTrap3			= "В покои господина проникли!",
	FleshreaperTrap1	= "Скорей, нападем на них сзади!",
	FleshreaperTrap2	= "Вам не уйти от нас.",
	FleshreaperTrap3	= "Живые? Здесь?!",
	SindragosaEvent		= "Они не должны прорваться к Синдрагосе! Скорее, остановите их!"
}

------------------------
--  The Ruby Sanctum  --
------------------------
--  Baltharus the Warborn  --
-----------------------------
L = DBM:GetModLocalization("Baltharus")

L:SetGeneralLocalization({
	name = "Балтар Рожденный в Битве"
})

L:SetWarningLocalization({
	WarningSplitSoon	= "Скоро разделение"
})

L:SetOptionLocalization({
	WarningSplitSoon	= "Предупреждать заранее о разделении"
})

-------------------------
--  Saviana Ragefire  --
-------------------------
L = DBM:GetModLocalization("Saviana")

L:SetGeneralLocalization({
	name = "Савиана Огненная Пропасть"
})

--------------------------
--  General Zarithrian  --
--------------------------
L = DBM:GetModLocalization("Zarithrian")

L:SetGeneralLocalization({
	name = "Генерал Заритриан"
})

L:SetWarningLocalization({
	WarnAdds	= "Новые помощники",
	warnCleaveArmor	= "%s на >%s< (%s)"
})

L:SetTimerLocalization({
	TimerAdds	= "Новые помощники"
})

L:SetOptionLocalization({
	WarnAdds		= "Объявлять новых помощников",
	TimerAdds		= "Отсчет времени до новых помощников",
	warnCleaveArmor	= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(74367)
})

L:SetMiscLocalization({
	SummonMinions	= "Слуги! Обратите их в пепел!"
})

-------------------------------------
--  Halion the Twilight Destroyer  --
-------------------------------------
L = DBM:GetModLocalization("Halion")

L:SetGeneralLocalization({
	name = "Халион Сумеречный Разрушитель"
})

L:SetWarningLocalization({
	TwilightCutterCast	= "Применение заклинания Лезвие сумерек: 5 сек"
})

L:SetOptionLocalization({
	TwilightCutterCast		= "Предупреждать о применении заклинания $spell:74769",
	AnnounceAlternatePhase	= "Показывать предупреждения и таймеры для обоих миров"
})

L:SetMiscLocalization({
	Halion					= "Халион",
	MeteorCast				= "Небеса в огне!",
	Phase2					= "В мире сумерек вы найдете лишь страдания! Входите, если посмеете!",
	Phase3					= "Я есть свет и я есть тьма! Трепещите, ничтожные, перед посланником Смертокрыла!",
	twilightcutter			= "Во вращающихся сферах пульсирует темная энергия!",
	Kill					= "Это ваша последняя победа. Насладитесь сполна ее вкусом. Ибо когда вернется мой господин, этот мир сгинет в огне!"
})
