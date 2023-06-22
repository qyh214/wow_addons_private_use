if GetLocale() ~= "ruRU" then return end

local L

---------------
--  Kalecgos --
---------------
L = DBM:GetModLocalization("Kal")

L:SetGeneralLocalization{
	name = "Калесгос"
}

L:SetWarningLocalization{
	WarnPortal			= "Портал #%d : >%s< (Group %d)",
	SpecWarnWildMagic	= "Wild Magic - %s!"--Translate
}

L:SetTimerLocalization{
	TimerNextPortal		= "Портал (%d)"
}

L:SetOptionLocalization{
	WarnPortal			= "Show warning for $spell:46021 target",--Translate
	SpecWarnWildMagic	= "Show special warning for Wild Magic",--Translate
	TimerNextPortal		= "Show timer for portals",--Translate
	RangeFrame			= "Show range frame (10 yards)",--Translate
	ShowFrame			= "Show Spectral Realm frame" ,--Translate
	FrameClassColor		= "Use class colors in Spectral Realm frame",--Translate
	FrameUpwards		= "Expand Spectral Realm frame upwards",--Translate
	FrameLocked			= "Set Spectral Realm frame not movable"--Translate
}

L:SetMiscLocalization{
	Demon				= "Сатроварр Осквернитель",
	Heal				= "+100% хила",
	Haste				= "+100% время каста",
	Hit					= "-50% hit chance",
	Crit				= "+100% крит дамага",
	Aggro				= "+100% threat",
	Mana				= "-50% spell costs",
	FrameTitle			= "Spectral Realm",--Translate
	FrameLock			= "Закрепить рамку",
	FrameClassColor		= "Use class colors",--Translate
	FrameOrientation	= "Expand upwards",--Translate
	FrameHide			= "Скрыть рамку",
	FrameClose			= "Close"--Translate
}

----------------
--  Brutallus --
----------------
L = DBM:GetModLocalization("Brutallus")

L:SetGeneralLocalization{
	name = "Бруталл"
}

L:SetMiscLocalization{
	Pull			= "О, а вот и новые агнцы идут на заклание!"
}

--------------
--  Felmyst --
--------------
L = DBM:GetModLocalization("Felmyst")

L:SetGeneralLocalization{
	name = "Пророк Скверны"
}

L:SetWarningLocalization{
	WarnPhase		= "%s Phase",--Translate
	WarnPhaseSoon	= "%s Phase in 10 sec",--Translate
	WarnBreath		= "Глубокий Вздох (%d)"
}

L:SetTimerLocalization{
	TimerPhase		= "Next %s Phase",
	TimerBreath		= "Глубокий Вздох"
}

L:SetOptionLocalization{
	WarnPhase		= "Show warning for next phase",--Translate
	WarnPhaseSoon	= "Show pre-warning for next phase",--Translate
	WarnBreath		= "Show warning for Deep Breath",--Translate
	TimerPhase		= "Show time for next phase",--Translate
	TimerBreath		= "Show timer for Deep Breath cooldown",--Translate
	YellOnEncaps	= "Yell on $spell:45665"
}

L:SetMiscLocalization{
	Air				= "Air",--Translate
	Ground			= "Ground",--Translate
	YellEncaps		= "Encapsulate on me! Run away!",--Change to generic so we don't have to translate?
	AirPhase		= "I am stronger than ever before!",--Translate
	Breath			= "%s глубоко вздыхает."
}

-----------------------
--  The Eredar Twins --
-----------------------
L = DBM:GetModLocalization("Twins")

L:SetGeneralLocalization{
	name = "Близнецы"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
	NovaIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(45329),
	ConflagIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(45333),
	RangeFrame		= "Show range frame (10 yards)",--Translate
	NovaWhisper		= "Send whisper to $spell:45329 target (requires Raid Leader)",--Translate
	ConflagWhisper	= "Send whisper to $spell:45333 target (requires Raid Leader)",--Translate
}

L:SetMiscLocalization{
	NovaWhisper		= "Shadow Nova on you!",--Translate
	ConflagWhisper	= "Conflagration on you!",--Translate
	Nova			= "Sacrolash directs Shadow Nova at (.+)%.",--Verify
	Conflag			= "Алайтесс воздействует на"--Verify
}

------------
--  M'uru --
------------
L = DBM:GetModLocalization("Muru")

L:SetGeneralLocalization{
	name = "М'ару"
}

L:SetWarningLocalization{
	WarnHuman		= "Humanoids (%d)",--Translate
	WarnHumanSoon	= "Humanoids in 5 sec (%d)",--Translate
	WarnVoid		= "Void Sentinel (%d)",--Translate
	WarnVoidSoon	= "Void Sentinel in 5 sec (%d)",--Translate
	WarnFiend		= "Dark Fiend spawned"--Translate
}

L:SetTimerLocalization{
	TimerHuman		= "Humanoids (%s)",--Translate
	TimerVoid		= "Leerenwandler (%s)",
	TimerPhase		= "Энтропий"
}

L:SetOptionLocalization{
	WarnHuman		= "Show warning for Humanoids",--Translate
	WarnHumanSoon	= "Show pre-warning for Humanoids",--Translate
	WarnVoid		= "Show warning for Void Sentinels",--Translate
	WarnVoidSoon	= "Show pre-warning for Void Sentinels",--Translate
	WarnFiend		= "Show warning for Fiends in phase 2",--Translate
	TimerHuman		= "Show timer for Humanoids",--Translate
	TimerVoid		= "Show timer for Void Sentinels",--Translate
	TimerPhase		= "Show time for Phase 2 transition"--Translate
}

L:SetMiscLocalization{
	Entropius		= "Энтропий"
}

----------------
--  Kil'jeden --
----------------
L = DBM:GetModLocalization("Kil")

L:SetGeneralLocalization{
	name = "Кил'джеден"
}

L:SetWarningLocalization{
	WarnDarkOrb		= "Dark Orbs Spawned",--Translate
	WarnBlueOrb		= "Dragon Orb activated",--Translate
	SpecWarnDarkOrb	= "Dark Orbs Spawned!",--Translate
	SpecWarnBlueOrb	= "Dragon Orbs Activated!"--Translate
}

L:SetTimerLocalization{
	TimerBlueOrb	= "Dragon Orbs activate"--Translate
}

L:SetOptionLocalization{
	WarnDarkOrb		= "Show warning for Dark Orbs",--Translate
	WarnBlueOrb		= "Show warning for Dragon Orbs",--Translate
	SpecWarnDarkOrb	= "Show special warning for Dark Orbs",--Translate
	SpecWarnBlueOrb	= "Show special warning for Dragon Orbs",--Translate
	TimerBlueOrb	= "Show timer form Dragon Orbs activate",--Translate
	RangeFrame		= "Show range frame (10 yards)",--Translate
	BloomIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(45641),
	YellOnBloom		= "Yell on $spell:45641",--Translate
	BloomWhisper	= "Send whisper to $spell:45641 target (requires Raid Leader)"--Translate
}

L:SetMiscLocalization{
	YellPull		= "Жалкие твари уничтожены. Да будет так! Я сделаю то, что не удалось Саргерасу. Я выпущу кровь из этого мерзкого мира и стану истинным повелителем Пылающего Легиона! Конец близок! Да свершится падение этого мира!",
	YellBloom		= "Fire Bloom on me!",--Translate
	BloomWhisper	= "Fire Bloom on you!",--Translate
	OrbYell1		= "I will channel my powers into the orbs! Be ready!",--Translate
	OrbYell2		= "I have empowered another orb! Use it quickly!",--Translate
	OrbYell3		= "Another orb is ready! Make haste!",--Translate
	OrbYell4		= "I have channeled all I can! The power is in your hands!"--Translate

}

-----------------
--  Najentus  --
-----------------
L = DBM:GetModLocalization("Najentus")

L:SetGeneralLocalization{
	name = "Верховный Полководец Надж'ентус"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
	RangeFrame	= "Show range frame (10)"--Translate
}

L:SetMiscLocalization{
}

----------------
-- Supremus --
----------------
L = DBM:GetModLocalization("Supremus")

L:SetGeneralLocalization{
	name = "Супремус"
}

L:SetWarningLocalization{
	WarnPhase		= "%s Phase",--Translate
	WarnPhaseSoon	= "%s Phase in 10",--Translate
	WarnKite		= "Gaze on >%s<"--Translate
}

L:SetTimerLocalization{
	TimerPhase		= "Next %s phase"--Translate
}

L:SetOptionLocalization{
	WarnPhase		= "Show warning for next phase",--Translate
	WarnPhaseSoon	= "Show pre-warning for next phase",--Translate
	WarnKite		= "Announce Kite targets",--Translate
	TimerPhase		= "Show time for next phase",--Translate
	KiteIcon		= "Set icon on Kite target",--Translate
	KiteWhisper		= "Send whisper to Kite target (requires Raid Leader)"--Translate
}

L:SetMiscLocalization{
	PhaseTank		= "в гневе ударяет по земле!",--Check if Backwards
	PhaseKite		= "Земля начинает раскалываться!",--Check if Backwards
	ChangeTarget	= "атакует новую цель!",
	Kite			= "Kite",--Translate
	Tank			= "Tank"--Translate
}

-------------------------
--  Shape of Akama  --
-------------------------
L = DBM:GetModLocalization("Akama")

L:SetGeneralLocalization{
	name = "Тень Акамы"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
}

L:SetMiscLocalization{
}

-------------------------
--  Teron Gorefiend  --
-------------------------
L = DBM:GetModLocalization("TeronGorefiend")

L:SetGeneralLocalization{
	name = "Терон Кровожад"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
	TimerVengefulSpirit		= "Ghost : %s"--Translate
}

L:SetOptionLocalization{
	TimerVengefulSpirit		= "Show timer for Ghost durations",--Translate
	CrushIcon				= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(40243)
}

L:SetMiscLocalization{
}

----------------------------
--  Gurtogg Bloodboil  --
----------------------------
L = DBM:GetModLocalization("Bloodboil")

L:SetGeneralLocalization{
	name = "Гуртогг Кипящая Кровь"
}

L:SetWarningLocalization{
	WarnRageEnd		= "Fel Rage End",--Translate
}

L:SetTimerLocalization{
	TimerRageEnd	= "Fel Rage End"--Translate
}

L:SetOptionLocalization{
	WarnRageEnd		= "Show warning for $spell:40604 ends",--Translate
	TimerRageEnd	= "Show timer for $spell:40604 ends"--Translate
}

L:SetMiscLocalization{
}

--------------------------
--  Essence Of Souls  --
--------------------------
L = DBM:GetModLocalization("Souls")

L:SetGeneralLocalization{
	name = "Воплощение Душ"
}

L:SetWarningLocalization{
	WarnEnrage		= "Озверение",
	WarnEnrageSoon	= "Озверение скоро",
	WarnEnrageEnd	= "Озверение закончилось",
	WarnMana		= "Ноль маны через 30 сек"
}

L:SetTimerLocalization{
	TimerEnrage		= "Озверение",
	TimerNextEnrage	= "Next Озверение",--Translate
	TimerMana		= "Mana 0"--Translate
}

L:SetOptionLocalization{
	WarnEnrage		= "Show warning for Enrage",--Translate
	WarnEnrageSoon	= "Show pre-warning for Enrage",--Translate
	WarnEnrageEnd	= "Show warning when Enrage ends",--Translate
	WarnMana		= "Show warning from zero mana in Phase 2",--Translate
	TimerEnrage		= "Show timer for Enrage",--Translate
	TimerNextEnrage	= "Show timer for next Enrage",--Translate
	TimerMana		= "Show timer for zero mana in Phase 2",--Translate
	SpiteWhisper	= "Send whisper to $spell:41376 targets (requires Raid Leader)"--Translate
}

L:SetMiscLocalization{
	Enrage			= "%s впадает в ярость!",
	SpiteWhisper	= "Злоба на Вас!",
	Suffering		= "Essence of Suffering",--Translate
	Desire			= "Essence of Desire",--Translate
	Anger			= "Essence of Anger"--Translate
}

-----------------------
--  Mother Shahraz --
-----------------------
L = DBM:GetModLocalization("Shahraz")

L:SetGeneralLocalization{
	name = "Матушка Шахраз"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
}

----------------------
--  Illidari Council  --
----------------------
L = DBM:GetModLocalization("Council")

L:SetGeneralLocalization{
	name = "Совет Иллидари"
}

L:SetWarningLocalization{
	WarnFadeSoon	= "Vanish fades in 5 sec",--Translate
	WarnFaded		= "Vanish faded",--Translate
	WarnDevAura		= "Devotion Aura for 30 sec",--Translate
	WarnResAura		= "Resistance Aura for 30 sec",--Translate
	Immune			= "Malande - %s immune for 15 sec"--Translate
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
	WarnFadeSoon	= "Show warning 5 seconds before $spell:41476 fades",--Translate
	WarnFaded		= "Show warning when $spell:41476 fades",--Translate
	WarnDevAura		= "Show warning for $spell:41452",--Translate
	WarnResAura		= "Show warning for $spell:41453",--Translate
	Immune			= "Show warning when Manalde becomes spell or melee immune"--Translate
}

L:SetMiscLocalization{
	Gathios			= "Гатиос Изувер",
	Malande			= "Леди Маланда",
	Zerevor			= "Верховный пустомант Зеревор",
	Veras			= "Верас Глубокий Мрак",
	Melee			= "Melee",--Translate
	Spell			= "Spell",--Translate
	PoisonWhisper	= "Deadly Poison on you!"--Translate
}

-------------------------
--  Illidan Stormrage --
-------------------------
L = DBM:GetModLocalization("Illidan")

L:SetGeneralLocalization{
	name = "Иллидан Ярость Бури"
}

L:SetWarningLocalization{
	WarnPhase2Soon	= "Фаза 2 скоро",
	WarnPhase4Soon	= "Фаза 4 скоро",
	WarnHuman		= "Обычная Фаза",
	WarnHumanSoon	= "Обычная Фаза скоро",
	WarnDemon		= "Демона Фаза",
	WarnDemonSoon	= "Демона Фаза скоро"
}

L:SetTimerLocalization{
	TimerCombatStart	= "Combat starts",--Translate
	TimerNextHuman		= "Next Обычная Фаза",--Translate
	TimerNextDemon		= "Next Демона Фаза"--Translate
}

L:SetOptionLocalization{
	WarnPhase2Soon	= "Show pre-warning for Phase 2 transition (at ~75%)",--Translate
	WarnPhase4Soon	= "Show pre-warning for Phase 4 transition (at ~35%)",--Translate
	WarnHuman		= "Show warning for Human Phase",--Translate
	WarnHumanSoon	= "Show pre-warning for Human Phase",--Translate
	WarnDemon		= "Show warning for Demon Phase",--Translate
	WarnDemonSoon	= "Show pre-warning for Demon Phase",--Translate
	TimerCombatStart= "Show time for start of combat",--Translate
	TimerNextHuman	= "Show time for Next Human Phase",--Translate
	TimerNextDemon	= "Show time for Demon Human Phase",--Translate
	RangeFrame		= "Show range frame (10 yards) in Phase 3 and 4"--Translate
}

L:SetMiscLocalization{
	Pull			= "Акама! Твое двуличие меня не удивляет. Мне давным-давно стоило уничтожить тебя и твоих уродливых собратьев.",
	Eyebeam			= "Посмотри в глаза Предателя!",
	Demon			= "Узрите мощь демона!",
	Phase4			= "Это все, смертные? Это и есть вся ваша ярость?",
	ParasiteWhisper	= "Shadowfiends on you!"--Translate
}

------------------------
--  Rage Winterchill  --
------------------------
L = DBM:GetModLocalization("Rage")

L:SetGeneralLocalization{
	name = "Лютый Хлад"
}

-----------------
--  Anetheron  --
-----------------
L = DBM:GetModLocalization("Anetheron")

L:SetGeneralLocalization{
	name = "Анетерон"
}

----------------
--  Kazrogal  --
----------------
L = DBM:GetModLocalization("Kazrogal")

L:SetGeneralLocalization{
	name = "Каз'рогал"
}

---------------
--  Azgalor  --
---------------
L = DBM:GetModLocalization("Azgalor")

L:SetGeneralLocalization{
	name = "Азгалор"
}

------------------
--  Archimonde  --
------------------
L = DBM:GetModLocalization("Archimonde")

L:SetGeneralLocalization{
	name = "Архимонд"
}

----------------
-- WaveTimers --
----------------
L = DBM:GetModLocalization("HyjalWaveTimers")

L:SetGeneralLocalization{
	name 		= "Треш-мобы"
}
L:SetWarningLocalization{
	WarnWave	= "%s",
	WarnWaveSoon= "Скоро следующая волна"
}
L:SetTimerLocalization{
	TimerWave	= "Следующая волна"
}
L:SetOptionLocalization{
	WarnWave		= "Warn when a new wave is incoming",--Translate
	WarnWaveSoon	= "Warn when a new wave is incoming soon",--Translate
	DetailedWave	= "Detailed warning when a new wave is incoming (which mobs)",--Translate
	TimerWave		= "Show a timer for next wave"--Translate
}
L:SetMiscLocalization{
	HyjalZoneName	= "Вершина Хиджала",
	Thrall			= "Тралл",
	Jaina			= "Леди Джайна Праудмур",
	RageWinterchill	= "Лютый Хлад",
	Anetheron		= "Анетерон",
	Kazrogal		= "Каз'рогал",
	Azgalor			= "Азгалор",
	WarnWave_0		= "Волна %s/8",
	WarnWave_1		= "Волна %s/8 - %s %s",
	WarnWave_2		= "Волна %s/8 - %s %s и %s %s",
	WarnWave_3		= "Волна %s/8 - %s %s, %s %s и %s %s",
	WarnWave_4		= "Волна %s/8 - %s %s, %s %s, %s %s и %s %s",
	WarnWave_5		= "Волна %s/8 - %s %s, %s %s, %s %s, %s %s и %s %s",
	RageGossip		= "Мои спутники и я – с вами, леди Праудмур.",
	AnetheronGossip	= "Мы готовы встретить любого, кого пошлет Архимонд.",
	KazrogalGossip	= "Я с тобой, Тралл.",
	AzgalorGossip	= "Нам нечего бояться.",
	Ghoul			= "Вурдалака",
	Abomination		= "Поганища",
	Necromancer		= "Некроманта",
	Banshee			= "Банши",
	Fiend			= "Некрорахнида",
	Gargoyle		= "Горгульи",
	Wyrm			= "Ледяной змей",
	Stalker			= "Ловчих Скверны",
	Infernal		= "Инфернала"
}

-----------
--  Alar --
-----------
L = DBM:GetModLocalization("Alar")

L:SetGeneralLocalization{
	name = "Ал'ар"
}

L:SetTimerLocalization{
	NextPlatform	= "Следующая платформа"
}

L:SetOptionLocalization{
	NextPlatform	= "Show timer for when Al'ar changes platforms"
}

------------------
--  Void Reaver --
------------------
L = DBM:GetModLocalization("VoidReaver")

L:SetGeneralLocalization{
	name = "Страж Бездны"
}

--------------------------------
--  High Astromancer Solarian --
--------------------------------
L = DBM:GetModLocalization("Solarian")

L:SetGeneralLocalization{
	name = "Верховный звездочет Солариан"
}

L:SetWarningLocalization{
	WarnSplit		= "*** Приспешники на подходе ***",
	WarnSplitSoon	= "*** Разделение через 5 секунд ***",
	WarnAgent		= "*** Пособники появились ***",
	WarnPriest		= "*** Жрецы и Солариан появились ***"

}

L:SetTimerLocalization{
	TimerSplit		= "Разделение",
	TimerAgent		= "Пособники",
	TimerPriest		= "Жрецы и Солариан"
}

L:SetOptionLocalization{--Translate
	WarnSplit		= "Show warning for Split",
	WarnSplitSoon	= "Show pre-warning for Split",
	WarnAgent		= "Show warning for Agents spawn",
	WarnPriest		= "Show warning for Priests and Solarian spawn",
	TimerSplit		= "Show timer for Split",
	TimerAgent		= "Show timer for Agents spawn",
	TimerPriest		= "Show timer for Priests and Solarian spawn",
	WrathWhisper	= "Сообщить шепотом цели, если Гнев на нем"
}

L:SetMiscLocalization{
	WrathWhisper	= "Гнев на вас!",
	YellSplit1		= "I will crush your delusions of grandeur!",--Translate
	YellSplit2		= "You are hopelessly outmatched!",--Translate
	YellPhase2		= "I become"--Translate
}

---------------------------
--  Kael'thas Sunstrider --
---------------------------
L = DBM:GetModLocalization("KaelThas")

L:SetGeneralLocalization{
	name = "Кель'тас Солнечный Скиталец"
}

L:SetWarningLocalization{
	WarnGaze		= "*** Таладред бросает взор на >%s< ***",
	WarnMobDead		= "%s down",--Translate
	WarnEgg			= "*** Феникс убит - появляется яйцо ***",
	SpecWarnGaze	= "Бегите!",
	SpecWarnEgg		= "*** Феникс убит - появляется яйцо ***"
}

L:SetTimerLocalization{
	TimerPhase		= "Next Phase",--Translate
	TimerPhase1mob	= "%s",
	TimerNextGaze	= "Восстановление взгляда",
	TimerRebirth	= "Возрождение"
}

L:SetOptionLocalization{--Translate
	WarnGaze		= "Show warning for Thaladred's Gaze target",
	WarnMobDead		= "Show warning for Phase 2 mob down",
	WarnEgg			= "Show warning when Phoenix Egg spawn",
	SpecWarnGaze	= "Show special warning when Gaze on you",
	SpecWarnEgg		= "Show special warning when Phoenix Egg spawn",
	TimerPhase		= "Show time for next phase",
	TimerPhase1mob	= "Show time for Phase 1 mob active",
	TimerNextGaze	= "Show timer for Thaladred's Gaze target changes",
	TimerRebirth	= "Show timer for Phoenix Egg rebirth remaining",
	GazeWhisper		= "Сообщить шепотом цели, если Таладред на нем",
	GazeIcon		= "Установить метку на цель Таладред"
}

L:SetMiscLocalization{
	YellPhase2	= "As you see, I have many weapons in my arsenal....",--Translate
	YellPhase3	= "Perhaps I underestimated you. It would be unfair to make you fight all four advisors at once, but... fair treatment was never shown to my people. I'm just returning the favor.",--Translate
	YellPhase4	= "Alas, sometimes one must take matters into one's own hands. Balamore shanal!",--Translate
	YellPhase5	= "I have not come this far to be stopped! The future I have planned will not be jeopardized! Now you will taste true power!!",--Translate
	YellSang	= "You have persevered against some of my best advisors... but none can withstand the might of the Blood Hammer. Behold, Lord Sanguinar!",--Translate
	YellCaper	= "Capernian will see to it that your stay here is a short one.",--Translate
	YellTelo	= "Well done, you have proven worthy to test your skills against my master engineer, Telonicus.",--Translate
	EmoteGaze	= "sets eyes on ([^%s]+)!",--Translate
	GazeWhisper	= "Таладред бросает взор на ВАС! Бегите!",
	Thaladred	= "Таладред Светокрад",
	Sanguinar	= "Лорд Сангвинар",
	Capernian	= "Великий Звездочет Каперниан",
	Telonicus	= "Старший инженер Телоникус",
	Bow			= "Netherstrand Longbow",--Translate
	Axe			= "Devastation",--Translate
	Mace		= "Cosmic Infuser",--Translate
	Dagger		= "Infinity Blades",--Translate
	Sword		= "Warp Slicer",--Translate
	Shield		= "Phaseshift Bulwark",--Translate
	Staff		= "Staff of Disintegration",--Translate
	Egg			= "Яйцо феникса"
}

---------------------------
--  Hydross the Unstable --
---------------------------
L = DBM:GetModLocalization("Hydross")

L:SetGeneralLocalization{
	name = "Гидросс Нестабильный"
}

L:SetWarningLocalization{
	WarnMark 		= "%s : %s",
	WarnPhase		= "%s Phase",--Translate
	SpecWarnMark	= "%s : %s"
}

L:SetTimerLocalization{
	TimerMark	= "Next %s : %s"--Translate
}

L:SetOptionLocalization{
	WarnMark		= "Объявить знаки",
	WarnPhase		= "Объявить фазы",
	SpecWarnMark	= "Show warning when Marks debuff damage over 100%",--Translate
	TimerMark		= "Show timer for next Marks"--Translate
}

L:SetMiscLocalization{
	Frost	= "Гидросса",
	Nature	= "порчи"
}

-----------------------
--  The Lurker Below --
-----------------------
L = DBM:GetModLocalization("LurkerBelow")

L:SetGeneralLocalization{
	name = "Скрытень из глубин"
}

L:SetWarningLocalization{
	WarnSubmerge		= "Погружение",
	WarnSubmergeSoon	= "Погружение in 10 sec",--Verify
	WarnEmerge			= "Появление",
	WarnEmergeSoon		= "Появление in 10 sec"--Verify
}

L:SetTimerLocalization{
	TimerSubmerge		= "Погружение",
	TimerEmerge			= "Появление"
}

L:SetOptionLocalization{
	WarnSubmerge		= "Show warning when submerge",--Translate
	WarnSubmergeSoon	= "Show pre-warning for submerge",--Translate
	WarnEmerge			= "Show warning when emerge",--Translate
	WarnEmergeSoon		= "Show pre-warning for emerge",--Translate
	TimerSubmerge		= "Show time for submerge",--Translate
	TimerEmerge			= "Show time for emerge"--Translate
}

L:SetMiscLocalization{
	Spout	= "Скрытень из глубин глубоко вздыхает!"
}

--------------------------
--  Leotheras the Blind --
--------------------------
L = DBM:GetModLocalization("Leotheras")

L:SetGeneralLocalization{
	name = "Леотерас Слепец"
}

L:SetWarningLocalization{
	WarnPhase		= "%s Phase",--Translate
	WarnPhaseSoon	= "%s Phase in 5 sec"--Translate
}

L:SetTimerLocalization{
	TimerPhase	= "Next %s Phase"--Translate
}

L:SetOptionLocalization{
	WarnPhase		= "Show warning for next phase",--Translate
	WarnPhaseSoon	= "Show pre-warning for next phase",--Translate
	TimerPhase		= "Show time for next phase"--Translate
}

L:SetMiscLocalization{
	Human		= "Human",--Translate
	Demon		= "Demon",--Translate
	YellDemon	= "Be gone, trifling elf%.%s*I am in control now!",--Translate
	YellPhase2	= "No... no! What have you done? I am the master! Do you hear me? I am... aaggh! Can't... contain him."--Translate
}

-----------------------------
--  Fathom-Lord Karathress --
-----------------------------
L = DBM:GetModLocalization("Fathomlord")

L:SetGeneralLocalization{
	name = "Повелитель глубин Каратресс"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
}

L:SetMiscLocalization{
	Caribdis	= "Fathom-Guard Caribdis",--Translate
	Tidalvess	= "Fathom-Guard Tidalvess",--Translate
	Sharkkis	= "Fathom-Guard Sharkkis"--Translate
}

--------------------------
--  Morogrim Tidewalker --
--------------------------
L = DBM:GetModLocalization("Tidewalker")

L:SetGeneralLocalization{
	name = "Морогрим Волноступ"
}

L:SetWarningLocalization{
	WarnMurlocs		= "Мурлоки",
	SpecWarnMurlocs	= "Мурлоки!"
}

L:SetTimerLocalization{
	TimerMurlocs	= "Мурлоки"
}

L:SetOptionLocalization{
	WarnMurlocs		= "Объявить Мурлоки",
	SpecWarnMurlocs	= "Show special warning when Murlocs spawning",--Translate
	TimerMurlocs	= "Show timer for Murlocs spawning",--Translate
	GraveIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(38049)
}

L:SetMiscLocalization{
}

-----------------
--  Lady Vashj --
-----------------
L = DBM:GetModLocalization("Vashj")

L:SetGeneralLocalization{
	name = "Леди Вайш"
}

L:SetWarningLocalization{
	WarnElemental		= "Нечистый элементаль через 5 секунд (%s)",
	WarnStrider			= "Долгоног через 5 секунд (%s)",
	WarnNaga			= "Нага через 5 секунд (%s)",
	WarnShield			= "Магический барьер - деактивировано %d/4",
	WarnLoot			= ">%s< получил порченую магму",
	SpecWarnElemental	= "Нечистый элементаль через 5 секунд!"
}

L:SetTimerLocalization{
	TimerElemental		= "Нечистый элементаль (%d)",--Verify
	TimerStrider		= "Долгоног (%d)",--Verify
	TimerNaga			= "Нага (%d)"--Verify
}

L:SetOptionLocalization{
	WarnElemental		= "Show pre-warning for next Tainted Elemental",--Translate
	WarnStrider			= "Show pre-warning for next Strider",--Translate
	WarnNaga			= "Show pre-warning for next Naga",--Translate
	WarnShield			= "Show warning for Phase 2 shield down",--Translate
	WarnLoot			= "Объявить наличие порченой магмы",
	TimerElemental		= "Show time for next Tainted Elemental",--Translate
	TimerStrider		= "Show time for next Strider",--Translate
	TimerNaga			= "Show time for next Strider",--Translate
	SpecWarnElemental	= "Show special warning when Tainted Elemental coming",--Translate
	ChargeIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(38280),
	AutoChangeLootToFFA		= "Смена режима добычи на Каждый за себя в фазе 2"
}

L:SetMiscLocalization{
	DBM_VASHJ_YELL_PHASE2				= "Время пришло! Не оставляйте никого в живых!",
	LootMsg			= "([^%s]+).*Hitem:(%d+)"
}

--Maulgar
L = DBM:GetModLocalization("Maulgar")

L:SetGeneralLocalization{
	name = "Король Молгар"
}


--Gruul the Dragonkiller
L = DBM:GetModLocalization("Gruul")

L:SetGeneralLocalization{
	name = "Груул Драконобой"
}

L:SetWarningLocalization{
	WarnGrowth	= "%s (%d)"
}

L:SetOptionLocalization{
	WarnGrowth		= "Показывать предупреждение для $spell:36300",
	RangeDistance	= "Фрейм дистанции для |cff71d5ff|Hspell:33654|hДробление|h|r",
	Smaller			= "Маленькая дистанция (11)",
	Safe			= "Безопасная дистанция (18)"
}

-- Magtheridon
L = DBM:GetModLocalization("Magtheridon")

L:SetGeneralLocalization{
	name = "Магтеридон"
}

L:SetTimerLocalization{
	timerP2	= "Phase 2"
}

L:SetOptionLocalization{
	timerP2	= "Show timer for start of phase 2"
}

L:SetMiscLocalization{
	DBM_MAG_EMOTE_PULL		= "начинает ослабевать!",
	DBM_MAG_YELL_PHASE2		= "Я… освобожден!",
	DBM_MAG_YELL_PHASE3		= "I will not be taken so easily! Let the walls of this prison tremble... and fall!"
}

--Attumen
L = DBM:GetModLocalization("Attumen")

L:SetGeneralLocalization{
	name = "Аттумен Охотник"
}

L:SetMiscLocalization{
	DBM_ATH_YELL_1		= "Давай, Полночь, разгоним этот сброд!"
}


--Moroes
L = DBM:GetModLocalization("Moroes")

L:SetGeneralLocalization{
	name = "Мороуз"
}

L:SetWarningLocalization{
	DBM_MOROES_VANISH_FADED	= "Исчезновение рассеивается"
}

L:SetOptionLocalization{
	DBM_MOROES_VANISH_FADED	= "Show vanish fade warning"
}


-- Maiden of Virtue
L = DBM:GetModLocalization("Maiden")

L:SetGeneralLocalization{
	name = "Благочестивая дева"
}


-- Romulo and Julianne
L = DBM:GetModLocalization("RomuloAndJulianne")

L:SetGeneralLocalization{
	name = "Ромуло и Джулианна"
}

L:SetMiscLocalization{
	DBM_RJ_PHASE2_YELL	= "Ночь, добрая и строгая, приди! Верни мне моего Ромуло!",
	Romulo				= "Ромуло",
	Julianne			= "Джулианна"
}


-- Big Bad Wolf
L = DBM:GetModLocalization("BigBadWolf")

L:SetGeneralLocalization{
	name = "Злой и страшный серый волк"
}

L:SetMiscLocalization{
	DBM_BBW_YELL_1			= "Так вам и надо!"
}


-- Curator
L = DBM:GetModLocalization("Curator")

L:SetGeneralLocalization{
	name = "Смотритель"
}


-- Terestian Illhoof
L = DBM:GetModLocalization("TerestianIllhoof")

L:SetGeneralLocalization{
	name = "Терестиан Больное Копыто"
}

L:SetMiscLocalization{
	Kilrek					= "Kil'rek",
	DChains					= "Demon Chains"
}


-- Shade of Aran
L = DBM:GetModLocalization("Aran")

L:SetGeneralLocalization{
	name = "Тень Арана"
}

L:SetWarningLocalization{
	DBM_ARAN_DO_NOT_MOVE	= "Не двигайтесь!"
}

L:SetOptionLocalization{
	DBM_ARAN_DO_NOT_MOVE	= "Show special warning for $spell:30004"
}


--Netherspite
L = DBM:GetModLocalization("Netherspite")

L:SetGeneralLocalization{
	name = "Пустогнев"
}

L:SetWarningLocalization{
	DBM_NS_WARN_PORTAL_SOON	= "Фаза порталов через 5 секунд",
	DBM_NS_WARN_BANISH_SOON	= "Фаза изгнания через 5 секунд",
	warningPortal			= "Фаза порталов",
	warningBanish			= "Фаза изгнания"
}

L:SetTimerLocalization{
	timerPortalPhase	= "Фаза порталов",
	timerBanishPhase	= "Фаза изгнания"
}

L:SetOptionLocalization{
	DBM_NS_WARN_PORTAL_SOON	= "Show pre-warning for Portal phase",
	DBM_NS_WARN_BANISH_SOON	= "Show pre-warning for Banish phase",
	warningPortal			= "Show warning for Portal phase",
	warningBanish			= "Show warning for Banish phase",
	timerPortalPhase		= "Show timer for Portal Phase duration",
	timerBanishPhase		= "Show timer for Banish Phase duration"
}

L:SetMiscLocalization{
	DBM_NS_EMOTE_PHASE_2	= "%s goes into a nether-fed rage!",
	DBM_NS_EMOTE_PHASE_1	= "%s cries out in withdrawal, opening gates to the nether."
}


--Prince Malchezaar
L = DBM:GetModLocalization("Prince")

L:SetGeneralLocalization{
	name = "Принц Малчезар"
}

L:SetMiscLocalization{
	DBM_PRINCE_YELL_P2		= "Простофили! Время – это пламя, в котором вы сгорите!",
	DBM_PRINCE_YELL_P3		= "Как ты можешь надеяться выстоять против такой ошеломляющей мощи?",
	DBM_PRINCE_YELL_INF1	= "Все миры, все измерения открыты мне!",
	DBM_PRINCE_YELL_INF2	= "Вас ждет не один Малчезаар, но и легионы, которыми я командую!"
}


-- Nightbane
L = DBM:GetModLocalization("NightbaneRaid")

L:SetGeneralLocalization{
	name = "Ночная Погибель"
}

L:SetWarningLocalization{
	DBM_NB_DOWN_WARN 		= "Наземная фаза через 15 секунд",
	DBM_NB_DOWN_WARN2 		= "Наземная фаза через 5 секунд",
	DBM_NB_AIR_WARN			= "Воздушная фаза"
}

L:SetTimerLocalization{
	timerNightbane			= "Nightbane incoming",
	timerAirPhase			= "Воздушная фаза"
}

L:SetOptionLocalization{
	DBM_NB_AIR_WARN			= "Show warning for Air Phase",
	PrewarnGroundPhase		= "Show pre-warnings for Ground Phase",
	timerNightbane			= "Show timer for Nightbane summon",
	timerAirPhase			= "Show timer for Air Phase duration"
}

L:SetMiscLocalization{
	DBM_NB_EMOTE_PULL		= "Древнее существо пробуждается вдалеке…",
	DBM_NB_YELL_AIR			= "Жалкий гнус! Я изгоню тебя из воздуха!",
	DBM_NB_YELL_GROUND		= "Довольно! Я сойду на землю и сам раздавлю тебя!",
	DBM_NB_YELL_GROUND2		= "Ничтожества! Я вам покажу мою силу поближе!"
}


-- Wizard of Oz
L = DBM:GetModLocalization("Oz")

L:SetGeneralLocalization{
	name = "Страна Оз"
}

L:SetOptionLocalization{
	AnnounceBosses			= "Show warnings for boss spawns",
	ShowBossTimers			= "Show timers for boss spawns"
}

L:SetMiscLocalization{
	DBM_OZ_WARN_TITO		= "*** Тито ***",
	DBM_OZ_WARN_ROAR		= "*** Хохотун ***",
	DBM_OZ_WARN_STRAWMAN	= "*** Балбес ***",
	DBM_OZ_WARN_TINHEAD		= "*** Медноголовый ***",
	DBM_OZ_WARN_CRONE		= "*** Ведьма ***",
	DBM_OZ_YELL_DOROTHEE	= "О, Тито, нам просто надо найти дорогу домой!",
	DBM_OZ_YELL_ROAR		= "I'm not afraid a' you! Do you wanna' fight? Huh, do ya'? C'mon! I'll fight ya' with both paws behind my back!",
	DBM_OZ_YELL_STRAWMAN	= "Now what should I do with you? I simply can't make up my mind.",
	DBM_OZ_YELL_TINHEAD		= "I could really use a heart. Say, can I have yours?",
	DBM_OZ_YELL_CRONE		= "Woe to each and every one of you, my pretties!"
}


-- Named Beasts
L = DBM:GetModLocalization("Shadikith")

L:SetGeneralLocalization{
	name = "Shadikith the Glider"
}

L = DBM:GetModLocalization("Hyakiss")

L:SetGeneralLocalization{
	name = "Hyakiss the Lurker"
}

L = DBM:GetModLocalization("Rokad")

L:SetGeneralLocalization{
	name = "Rokad the Ravager"
}

if WOW_PROJECT_ID == (WOW_PROJECT_MAINLINE or 1) then return end--Anything below here is only needed for classic wrath or classic bc

---------------
--  Nalorakk --
---------------
L = DBM:GetModLocalization("Nalorakk")

L:SetGeneralLocalization{
	name = "Налоракк"
}

L:SetWarningLocalization{
	WarnBear		= "Форма медведя",
	WarnBearSoon	= "Форма медведя через 5 секунд",
	WarnNormal		= "Обычная форма",
	WarnNormalSoon	= "Обычная форма через 5 секунд"
}

L:SetTimerLocalization{
	TimerBear		= "Форма медведя",
	TimerNormal		= "Обычная форма"
}

L:SetOptionLocalization{
	WarnBear		= "Show warning for Bear form",--Translate
	WarnBearSoon	= "Show pre-warning for Bear form",--Translate
	WarnNormal		= "Show warning for Normal form",--Translate
	WarnNormalSoon	= "Show pre-warning for Normal form",--Translate
	TimerBear		= "Show timer for Bear form",--Translate
	TimerNormal		= "Show timer for Normal form"--Translate
}

L:SetMiscLocalization{
	YellBear 	= "Если вызвать чудовище, то мало не покажется, точно говорю!",
	YellNormal	= "Пропустите Налоракка!"
}

---------------
--  Akil'zon --
---------------
L = DBM:GetModLocalization("Akilzon")

L:SetGeneralLocalization{
	name = "Акил'зон"
}

---------------
--  Jan'alai --
---------------
L = DBM:GetModLocalization("Janalai")

L:SetGeneralLocalization{
	name = "Джан'алаи"
}

L:SetMiscLocalization{
	YellBomb	= "Сгиньте в огне!",
	YellAdds	= "Где мои Наседки? Пора за яйца приниматься!"
}

--------------
--  Halazzi --
--------------
L = DBM:GetModLocalization("Halazzi")

L:SetGeneralLocalization{
	name = "Халаззи"
}

L:SetWarningLocalization{
	WarnSpirit	= "Призывает дух",
	WarnNormal	= "Дух исчезает"
}

L:SetOptionLocalization{
	WarnSpirit	= "Show warning for Spirit phase",--Translate
	WarnNormal	= "Show warning for Normal phase"--Translate
}

L:SetMiscLocalization{
	YellSpirit	= "Со мною дикий дух...",
	YellNormal	= "О дух, вернись ко мне!"
}

--------------------------
--  Hex Lord Malacrass --
--------------------------
L = DBM:GetModLocalization("Malacrass")

L:SetGeneralLocalization{
	name = "Повелитель проклятий Малакрасс"
}

L:SetMiscLocalization{
	YellPull	= "На вас падет тень..."
}

--------------
--  Zul'jin --
--------------
L = DBM:GetModLocalization("ZulJin")

L:SetGeneralLocalization{
	name = "Зул'джин"
}

L:SetMiscLocalization{
	YellPhase2	= "Выучил новый фокус… прямо как братишка-медведь...",
	YellPhase3	= "От орла нигде не скрыться!",
	YellPhase4	= "Позвольте представить моих двух братцев: клык и коготь!",
	YellPhase5	= "Для того чтобы увидеть дракондора, в небо смотреть необязательно!"
}
