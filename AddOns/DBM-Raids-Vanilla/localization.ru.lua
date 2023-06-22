if GetLocale() ~= "ruRU" then return end

local L

------------
-- Skeram --
------------
L = DBM:GetModLocalization("Skeram")

L:SetGeneralLocalization{
	name = "Пророк Скерам"
}

----------------
-- Three Bugs --
----------------
L = DBM:GetModLocalization("ThreeBugs")

L:SetGeneralLocalization{
	name = "Семейство жуков"
}
L:SetMiscLocalization{
	Yauj = "Принцесса Яудж",
	Vem = "Вем",
	Kri = "Лорд Кри"
}

-------------
-- Sartura --
-------------
L = DBM:GetModLocalization("Sartura")

L:SetGeneralLocalization{
	name = "Боевой страж Сартура"
}

--------------
-- Fankriss --
--------------
L = DBM:GetModLocalization("Fankriss")

L:SetGeneralLocalization{
	name = "Фанкрисс Непреклонный"
}
--------------
-- Viscidus --
--------------
L = DBM:GetModLocalization("Viscidus")

L:SetGeneralLocalization{
	name = "Нечистотон"
}
L:SetWarningLocalization{
	WarnFreeze	= "Заморожен: %d/3",
	WarnShatter	= "Shatter: %d/3"
}
L:SetOptionLocalization{
	WarnFreeze	= "Announce Freeze status",
	WarnShatter	= "Announce Shatter status"
}
L:SetMiscLocalization{
	Phase4 	= "Нечистотон начинает раскалываться!",
	Phase5 	= "Нечистотон едва держится!",
	Phase6 	= "Explodes."
}
-------------
-- Huhuran --
-------------
L = DBM:GetModLocalization("Huhuran")

L:SetGeneralLocalization{
	name = "Принцесса Хухуран"
}
---------------
-- Twin Emps --
---------------
L = DBM:GetModLocalization("TwinEmpsAQ")

L:SetGeneralLocalization{
	name = "Императоры-близнецы"
}
L:SetMiscLocalization{
	Veklor = "Император Век'лор",
	Veknil = "Император Век'нилаш"
}

------------
-- C'Thun --
------------
L = DBM:GetModLocalization("CThun")

L:SetGeneralLocalization{
	name = "К'Тун"
}
L:SetWarningLocalization{
	WarnEyeTentacle 	= "Появляются глазные отростки!",
	WarnClawTentacle2	= "Появляется когтещупальце!",
	WarnGiantEyeTentacle	= "Появляется гигантский глазной отросток!",
	WarnGiantClawTentacle	= "Появляется гигантское когтещупальце!",
	WarnWeakened 		= "К'Тун ослаблен! Бейте его!"
}
L:SetTimerLocalization{
	TimerEyeTentacle	= "Глазных отроски",
	TimerGiantEyeTentacle	= "Гигантский глазной отросток",
	TimerClawTentacle	= "Когтещупальце",
	TimerGiantClawTentacle	= "Гигантское когтещупальце",
	TimerWeakened		= "К'Тун ослаблен"
}
L:SetOptionLocalization{
	RangeFrame	= "Показывать окно дистанции"
}
----------------
-- Ouro --
----------------
L = DBM:GetModLocalization("Ouro")

L:SetGeneralLocalization{
	name = "Оуро"
}
L:SetWarningLocalization{
	WarnSubmerge		= "Закапывание",
	WarnEmerge			= "Появление",
	WarnSubmergeSoon	= "Скоро закапывание",
	WarnEmergeSoon		= "Скоро появление"
}
L:SetTimerLocalization{
	TimerSubmerge		= "Закапывание",
	TimerEmerge			= "Появление"
}
L:SetOptionLocalization{
	WarnSubmerge		= "Показывать предупреждение о закапывании",
	WarnSubmergeSoon	= "Предупреждать заранее о закапывании",
	TimerSubmerge		= "Показывать таймер до закапывания",
	WarnEmerge			= "Показывать предупреждение о появлении",
	WarnEmergeSoon		= "Предупреждать заранее о появлении",
	TimerEmerge			= "Показывать таймер до появления"
}

---------------
-- Kurinnaxx --
---------------
L = DBM:GetModLocalization("Kurinnaxx")

L:SetGeneralLocalization{
	name 		= "Куриннакс"
}
L:SetWarningLocalization{
	WarnWound	= "%s на >%s< (%s)"
}
L:SetOptionLocalization{
	WarnWound	= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(25646)
}
------------
-- Rajaxx --
------------
L = DBM:GetModLocalization("Rajaxx")

L:SetGeneralLocalization{
	name 		= "Генерал Раджакс"
}
L:SetWarningLocalization{
	WarnWave	= "Волна %s",
	WarnBoss	= "Появление босса"
}
L:SetOptionLocalization{
	WarnWave	= "Показывать предупреждение о следующей волне"
}
L:SetMiscLocalization{
	Wave1		= "Они пришли. Постарайся не дать себя убить, ",
	Wave3		= "Час возмездия близок! Да охватит мрак сердца наших врагов!",
	Wave4		= "Мы не будем больше ждать за запертыми дверьми и каменными стенами! Мы не будем больше отказываться от возмездия! Даже драконы содрогнутся перед нашим гневом!",
	Wave5		= "Пусть наши враги трепещут! Смерть им!",
	Wave6		= "Олений Шлем будет скулить и молить о пощаде, в точности как его сопливый сынок! Тысячелетняя несправедливость сегодня закончится!",
	Wave7		= "Фэндрал! Твой час пробил! Иди же, прячься в Изумрудном Сне и молись, чтобы мы до тебя не добрались!",
	Wave8		= "Настырная тварь! Я сам тебя убью!"
}

----------
-- Moam --
----------
L = DBM:GetModLocalization("Moam")

L:SetGeneralLocalization{
	name 		= "Моам"
}

----------
-- Buru --
----------
L = DBM:GetModLocalization("Buru")

L:SetGeneralLocalization{
	name 		= "Буру Ненасытный"
}
L:SetWarningLocalization{
	WarnPursue		= "Преследует >%s<",
	SpecWarnPursue	= "Преследует вас!"
}
L:SetOptionLocalization{
	WarnPursue		= "Называть преследуемые цели",
	SpecWarnPursue	= "Показывать специальное предупреждение, когда преследование на вас"
}
L:SetMiscLocalization{
	PursueEmote 	= "%s sets eyes on %s!"
}

-------------
-- Ayamiss --
-------------
L = DBM:GetModLocalization("Ayamiss")

L:SetGeneralLocalization{
	name 		= "Аямисса Охотница"
}

--------------
-- Ossirian --
--------------
L = DBM:GetModLocalization("Ossirian")

L:SetGeneralLocalization{
	name 		= "Оссириан Неуязвимый"
}
L:SetWarningLocalization{
	WarnVulnerable	= "%s"
}
L:SetTimerLocalization{
	TimerVulnerable	= "%s"
}
L:SetOptionLocalization{
	WarnVulnerable	= "Объявлять слабость",
	TimerVulnerable	= "Показывать таймер до слабости"
}

----------------
-- AQ20 Trash --
----------------
L = DBM:GetModLocalization("AQ20Trash")

L:SetGeneralLocalization{
	name = "AQ20 Trash"
}

-----------------
--  Razorgore  --
-----------------
L = DBM:GetModLocalization("Razorgore")

L:SetGeneralLocalization{
	name = "Бритвосмерт Неукротимый"
}
L:SetTimerLocalization{
	TimerAddsSpawn	= "Появление аддов"
}
L:SetOptionLocalization{
	TimerAddsSpawn	= "Показывать таймер до первого появления аддов"
}

-------------------
--  Vaelastrasz  --
-------------------
L = DBM:GetModLocalization("Vaelastrasz")

L:SetGeneralLocalization{
	name = "Валестраз Порочный"
}

-----------------
--  Broodlord  --
-----------------
L = DBM:GetModLocalization("Broodlord")

L:SetGeneralLocalization{
	name = "Предводитель драконов Разящий Бич"
}

---------------
--  Firemaw  --
---------------
L = DBM:GetModLocalization("Firemaw")

L:SetGeneralLocalization{
	name = "Огнечрев"
}

---------------
--  Ebonroc  --
---------------
L = DBM:GetModLocalization("Ebonroc")

L:SetGeneralLocalization{
	name = "Черноскал"
}

----------------
--  Flamegor  --
----------------
L = DBM:GetModLocalization("Flamegor")

L:SetGeneralLocalization{
	name = "Пламегор"
}

-----------------------
--  Vulnerabilities  --
-----------------------
-- Chromaggus, Death Talon Overseer and Death Talon Wyrmguard
L = DBM:GetModLocalization("TalonGuards")

L:SetGeneralLocalization{
	name = "Стражи Когтя Смерти"
}
L:SetWarningLocalization{
	WarnVulnerable		= "Уязвимость к %s"
}
L:SetOptionLocalization{
	WarnVulnerable		= "Показывать предупреждение об уязвимости к заклинаниям"
}
L:SetMiscLocalization{
	Fire		= "Огню",
	Nature		= "силам Природы",
	Frost		= "магии Льда",
	Shadow		= "Темной магии",
	Arcane		= "Тайной магии",
	Holy		= "Светлой магии"
}

------------------
--  Chromaggus  --
------------------
L = DBM:GetModLocalization("Chromaggus")

L:SetGeneralLocalization{
	name = "Хромаггус"
}
L:SetWarningLocalization{
	WarnBreathSoon	= "Скоро дыхание",
	WarnBreath		= "%s",
	WarnVulnerable	= "Уязвимость к %s",
	WarnPhase2Soon	= "Скоро 2-ая фаза"
}
L:SetTimerLocalization{
	TimerBreathCD	= "%s восстановление",
	TimerBreath		= "Применение %s",
	TimerVulnCD		= "Восстановление уязвимости"
}
L:SetOptionLocalization{
	WarnBreathSoon	= "Предварительное предупреждение Дыхания Хромаггуса",
	WarnBreath		= "Показывать предупреждение о дыханиях Хромаггуса",
	WarnVulnerable	= "Показывать предупреждение об уязвимости к заклинаниям",
	TimerBreathCD	= "Показывать время восстановления дыханий",
	TimerBreath		= "Показывать применение Дыхания",
	TimerVulnCD		= "Показывать восстановление уязвимости",
	WarnPhase2Soon	= "Предупреждать о второй фазе"
}
L:SetMiscLocalization{
	Breath1		= "Первое Дыхание",
	Breath2		= "Второе Дыхание",
	VulnEmote	= "%s уходит, мерцая.",
	Vuln		= "Уязвимость",
	Fire		= "Огню",
	Nature		= "силам Природы",
	Frost		= "магии Льда",
	Shadow		= "Темной магии",
	Arcane		= "Тайной магии",
	Holy		= "Светлой магии"
}

----------------
--  Nefarian  --
----------------
L = DBM:GetModLocalization("Nefarian-Classic")

L:SetGeneralLocalization{
	name = "Нефариан"
}
L:SetWarningLocalization{
	WarnAddsLeft		= "Осталось %d убийств",
	WarnClassCallSoon	= "Скоро вызов класса",
	WarnClassCall		= "Дебафф на %s",
	specwarnClassCall	= "Классовый зов на тебе!"
}
L:SetTimerLocalization{
	TimerClassCall		= "%s зов заканчивается"
}
L:SetOptionLocalization{
	TimerClassCall		= "Показывать таймер классовых вызовов",
	WarnClassCallSoon	= "Предупреждение классовых вызовов",
	WarnClassCall		= "Объявлять классовый вызов",
	specwarnClassCall	= "Показывать специальное предупреждение, когда вы подвержены классовому зову"
}
L:SetMiscLocalization{
	YellP2		= "Браво, слуги мои! Смертные утрачивают мужество! Поглядим же, как они справятся с истинным Повелителем Черной горы!!!",
	YellP3		= "Не может быть! Восстаньте, мои прислужники! Послужите господину еще раз!",
	YellShaman	= "Шаманы, покажите, на что способны ваши тотемы!",
	YellPaladin	= "Паладины… Я слышал, у вас несколько жизней. Докажите.",
	YellDruid	= "Друиды и их дурацкие превращения… Ну что ж, поглядим!",
	YellPriest	= "Жрецы! Если вы собираетесь продолжать так лечить, то давайте хоть немного разнообразим процесс!",
	YellWarrior	= "Воины! Я знаю, вы можете бить сильнее! Ну-ка, покажите!",
	YellRogue	= "Rogues? Stop hiding and face me!",
	YellWarlock	= "Чернокнижники, ну не беритесь вы за волшебство, которого сами не понимаете! Видите, что получилось?",
	YellHunter	= "Охотники со своими жалкими пугачами!",
	YellMage	= "И маги тоже? Осторожнее надо быть, когда играешь с магией…"
}

----------------
--  Lucifron  --
----------------
L = DBM:GetModLocalization("Lucifron")

L:SetGeneralLocalization{
	name = "Люцифрон"
}

----------------
--  Magmadar  --
----------------
L = DBM:GetModLocalization("Magmadar")

L:SetGeneralLocalization{
	name = "Магмадар"
}

----------------
--  Gehennas  --
----------------
L = DBM:GetModLocalization("Gehennas")

L:SetGeneralLocalization{
	name = "Гееннас"
}

------------
--  Garr  --
------------
L = DBM:GetModLocalization("Garr-Classic")

L:SetGeneralLocalization{
	name = "Гарр (Classic)"
}

--------------
--  Geddon  --
--------------
L = DBM:GetModLocalization("Geddon")

L:SetGeneralLocalization{
	name = "Барон Геддон"
}

----------------
--  Shazzrah  --
----------------
L = DBM:GetModLocalization("Shazzrah")

L:SetGeneralLocalization{
	name = "Шаззрах"
}

----------------
--  Sulfuron  --
----------------
L = DBM:GetModLocalization("Sulfuron")

L:SetGeneralLocalization{
	name = "Предвестник Сульфурон"
}

----------------
--  Golemagg  --
----------------
L = DBM:GetModLocalization("Golemagg")

L:SetGeneralLocalization{
	name = "Големагг Испепелитель"
}

-----------------
--  Majordomo  --
-----------------
L = DBM:GetModLocalization("Majordomo")

L:SetGeneralLocalization{
	name = "Мажордом Экзекутус"
}

----------------
--  Ragnaros  --
----------------
L = DBM:GetModLocalization("Ragnaros-Classic")

L:SetGeneralLocalization{
	name = "Рагнарос (Classic)"
}
L:SetWarningLocalization{
	WarnSubmerge		= "Погружение",
	WarnSubmergeSoon	= "Скоро погружение",
	WarnEmerge			= "Появление",
	WarnEmergeSoon		= "Скоро появление"
}
L:SetTimerLocalization{
	TimerCombatStart	= "Начало боя",
	TimerSubmerge		= "Погружение",
	TimerEmerge			= "Появление"
}
L:SetOptionLocalization{
	TimerCombatStart	= "Показывать время до начала боя",
	WarnSubmerge		= "Показывать предупреждение о погружении",
	WarnSubmergeSoon	= "Показывать предварительное предупреждение о погружении",
	TimerSubmerge		= "Показывать время до погружения",
	WarnEmerge			= "Показывать предупреждение о появлении",
	WarnEmergeSoon		= "Показывать предварительное предупреждение о появлении",
	TimerEmerge			= "Показывать время до появления"
}
L:SetMiscLocalization{
	Submerge	= "ПРИДИТЕ, МОИ СЛУГИ! ЗАЩИТИТЕ СВОЕГО ХОЗЯИНА!",
	Pull		= "Нахальные щенки! Вы сами обрекли себя на смерть! Узрите же Повелителя в гневе!"
}

-------------------
--  Venoxis  --
-------------------
L = DBM:GetModLocalization("Venoxis")

L:SetGeneralLocalization{
	name = "Верховный жрец Веноксис"
}

-------------------
--  Jeklik  --
-------------------
L = DBM:GetModLocalization("Jeklik")

L:SetGeneralLocalization{
	name = "Верховная жрица Джеклик"
}

-------------------
--  Marli  --
-------------------
L = DBM:GetModLocalization("Marli")

L:SetGeneralLocalization{
	name = "Верховная жрица Мар'ли"
}

-------------------
--  Thekal  --
-------------------
L = DBM:GetModLocalization("Thekal")

L:SetGeneralLocalization{
	name = "Верховный жрец Текал"
}

L:SetWarningLocalization({
	WarnSimulKill	= "Первый адд пал - воскрешение через ~15 сек."
})

L:SetTimerLocalization({
	TimerSimulKill	= "Воскрешение"
})

L:SetOptionLocalization({
	WarnSimulKill	= "Объявлять о смерти первого адда",
	TimerSimulKill	= "Показывать время до воскрешения жреца"
})

L:SetMiscLocalization({
	PriestDied	= "%s умирает.",
	YellPhase2	= "Ширвалла, наполни меня своим ГНЕВОМ!",
	YellKill	= "Хаккар больше не властен надо мной! Наконец-то я обрел покой!",
	Thekal		= "Верховный жрец Текал",
	Zath		= "Ревнитель Зат",
	LorKhan		= "Ревнитель Лор'Кхан"
})

-------------------
--  Arlokk  --
-------------------
L = DBM:GetModLocalization("Arlokk")

L:SetGeneralLocalization{
	name = "Верховная жрица Арлокк"
}

-------------------
--  Hakkar  --
-------------------
L = DBM:GetModLocalization("Hakkar")

L:SetGeneralLocalization{
	name = "Хаккар"
}

-------------------
--  Bloodlord  --
-------------------
L = DBM:GetModLocalization("Bloodlord")

L:SetGeneralLocalization{
	name = "Мандокир Повелитель Крови"
}
L:SetMiscLocalization{
	Bloodlord 	= "Мандокир Повелитель Крови",
	Ohgan		= "Охган",
	GazeYell	= "Я за тобой слежу"
}

-------------------
--  Edge of Madness  --
-------------------
L = DBM:GetModLocalization("EdgeOfMadness")

L:SetGeneralLocalization{
	name = "Грань Безумия"
}
L:SetMiscLocalization{
	Hazzarah = "Хазза'рах",
	Renataki = "Ренатаки",
	Wushoolay = "Вушулай",
	Grilek = "Гри'лек"
}

-------------------
--  Gahz'ranka  --
-------------------
L = DBM:GetModLocalization("Gahzranka")

L:SetGeneralLocalization{
	name = "Газ'ранка"
}

-------------------
--  Jindo  --
-------------------
L = DBM:GetModLocalization("Jindo")

L:SetGeneralLocalization{
	name = "Мастер проклятий Джин'до"
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
	Breath = "%s под воздействием Глубокого вдоха...",
	YellPull = "Вот это сюрприз. Обычно, чтобы найти обед, мне приходится покидать логово.",
	YellP2 = "Эта бессмысленная возня вгоняет меня в тоску. Я сожгу вас всех!",
	YellP3 = "Похоже, вам требуется преподать еще один урок, смертные!"
}

-------------------
--  Anub'Rekhan  --
-------------------
L = DBM:GetModLocalization("Anub'Rekhan")

L:SetGeneralLocalization({
	name = "Ануб'Рекан"
})

L:SetWarningLocalization({
	SpecialLocust		= "Жуки-трупоеды",
	WarningLocustFaded	= "Жуки-трупоеды исчезают"
})

L:SetOptionLocalization({
	SpecialLocust		= "Cпец-предупреждение для Жуков-трупоедов",
	WarningLocustFaded	= "Предупреждение для исчезновения Жуков-трупоедов",
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
	WarningEmbraceExpire	= "Предупреждение, когда Объятие Вдовы исчезает",
	WarningEmbraceExpired	= "Предупреждение, когда Объятие Вдовы закончится"
})

L:SetMiscLocalization({
	Pull					= "Склонитесь передо мной, черви!"--Not actually pull trigger, but often said on pull
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
	WarningTeleportSoon	= "Телепортация через 20 секунд"
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
	Pull				= "Смерть чужакам!"
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
	Pull				= "Теперь вы принадлежите мне!"
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
	WarningChargeChanged	= "Предупреждение, когда ваша полярность изменена",
	WarningChargeNotChanged	= "Предупреждение, когда ваша полярность не изменена",
	AirowsEnabled			= "Отображать стрелки (обычная \"2-сторонняя\" стратегия)",
	ArrowsRightLeft			= "Стрелки влево/вправо для \"4-сторонней\" стратегии",
	ArrowsInverse			= "Обратная \"4-сторонняя\" стратегия (вправо, если полярность изменена, влево, если нет)"
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
	TimerWave			= "Отсчет времени до волны",
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
	SpecialWarningMarkOnPlayer	= "Спец-предупреждение, когда >4 знаков на вас"
})

L:SetTimerLocalization({
})

L:SetWarningLocalization({
	WarningMarkSoon				= "Знак %d через 3 секунды",
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
	TimerLanding		= "Отсчет времени до приземления",
	TimerIceBlast		= "Отсчет времени до Ледяного дыхания",
	WarningDeepBreath	= "Специальное объявление Ледяного Дыхания",
	WarningIceblock		= "Кричать, когда вы в Ледяной глыбе"
})

L:SetMiscLocalization({
	EmoteBreath			= "%s делает глубокий вдох.",
	WarningYellIceblock	= "Я в Ледяной глыбе!"
})

L:SetWarningLocalization({
	WarningAirPhaseSoon	= "Воздушная фаза через 10 секунд",
	WarningAirPhaseNow	= "Воздушная фаза",
	WarningLanded		= "Сапфирон приземляется",
	WarningDeepBreath	= "Ледяное дыхание"
})

L:SetTimerLocalization({
	TimerAir		= "Воздушная фаза",
	TimerLanding	= "Приземление",
	TimerIceBlast	= "Ледяное дыхание"
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
	specwarnP2Soon		= "Спец-предупреждение за 10 секунд до вступления Кел'Тузада в бой",
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
