if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

---------------
--  Kalecgos --
---------------
L = DBM:GetModLocalization("Kal")

L:SetGeneralLocalization{
	name = "Kalecgos"
}

L:SetWarningLocalization{
	WarnPortal			= "Portal %d: >%s< (grupo %d)",
	SpecWarnWildMagic	= "¡Magia salvaje - %s!"
}

L:SetOptionLocalization{
	WarnPortal			= "Anunciar objetivo de $spell:46021",
	SpecWarnWildMagic	= "Mostrar aviso especial para Magia salvaje",
	ShowFrame			= "Mostrar marco del reino espectral" ,
	FrameClassColor		= "Usar colores de clase en el marco del reino espectral",
	FrameUpwards		= "Expandir marco del reino espectral hacia arriba",
	FrameLocked			= "Bloquear marco del reino espectral",
	RangeFrame			= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT:format(10, 46021)
}

L:SetMiscLocalization{
	Demon				= "Sathrovarr el Corruptor",
	Heal				= "Sanación realizada +100%",
	Haste				= "Celeridad con hechizos +100%",
	Hit					= "Golpe -50%",
	Crit				= "Daño crítico +100%",
	Aggro				= "Generación de amenaza +100%",
	Mana				= "Costes -50%",
	FrameTitle			= "Reino espectral",
	FrameLock			= "Bloquear marco",
	FrameClassColor		= "Usar colores de clase",
	FrameOrientation	= "Expandir hacia arriba",
	FrameHide			= "Ocultar marco",
	FrameClose			= "Cerrar"
}

----------------
--  Brutallus --
----------------
L = DBM:GetModLocalization("Brutallus")

L:SetGeneralLocalization{
	name = "Brutallus"
}

L:SetMiscLocalization{
	Pull			= "¡Ah, más corderos al matadero!"
}

--------------
--  Felmyst --
--------------
L = DBM:GetModLocalization("Felmyst")

L:SetGeneralLocalization{
	name = "Brumavil"
}

L:SetWarningLocalization{
	WarnPhase		= "Fase %s"
}

L:SetTimerLocalization{
	TimerPhase		= "Siguiente fase %s"
}

L:SetOptionLocalization{
	WarnPhase		= "Anunciar cambios de fase",
	TimerPhase		= "Mostrar temporizador para los cambios de fase"
}

L:SetMiscLocalization{
	Air				= "aérea",
	Ground			= "en tierra",
	AirPhase		= "¡Soy más fuerte que nunca!",
	Breath			= "%s respira hondo."
}

-----------------------
--  The Eredar Twins --
-----------------------
L = DBM:GetModLocalization("Twins")

L:SetGeneralLocalization{
	name = "Las gemelas eredar"
}

L:SetOptionLocalization{
	NovaIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(45329),
	ConflagIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(45333),
	RangeFrame		= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT:format(10, 45333)
}

L:SetMiscLocalization{
	Nova			= "dirige Nova de las Sombras hacia (.+)%.",
	Conflag			= "dirige Conflagración hacia (.+)%.",
	Sacrolash		= "Lady Sacrolash",
	Alythess		= "Bruja suprema Alythess"
}

------------
--  M'uru --
------------
L = DBM:GetModLocalization("Muru")

L:SetGeneralLocalization{
	name = "M'uru"
}

L:SetWarningLocalization{
	WarnHuman		= "Humanoides (%d)",
	WarnVoid		= "Centinela del vacío (%d)",
	WarnFiend		= "Maligno oscuro"
}

L:SetTimerLocalization{
	TimerHuman		= "Siguientes humanoides (%s)",
	TimerVoid		= "Siguiente centinela (%s)",
	TimerPhase		= "Entropius"
}

L:SetOptionLocalization{
	WarnHuman		= "Mostrar aviso cuando aparezcan humanoides",
	WarnVoid		= "Mostrar aviso cuando aparezca un Centinela del vacío",
	WarnFiend		= "Mostrar aviso cuando aparezcan Malignos oscuros en Fase 2",
	TimerHuman		= "Mostrar temporizador para los siguientes humanoides",
	TimerVoid		= "Mostrar temporizador para el siguiente Centinela del vacío",
	TimerPhase		= "Mostrar temporizador para la transición a Fase 2"
}

L:SetMiscLocalization{
	Entropius		= "Entropius"
}

----------------
--  Kil'jeden --
----------------
L = DBM:GetModLocalization("Kil")

L:SetGeneralLocalization{
	name = "Kil'jaeden"
}

L:SetWarningLocalization{
	WarnDarkOrb		= "Orbes escudo",
	WarnBlueOrb		= "Orbe azul activado",
	SpecWarnBlueOrb	= "¡Orbe azul activado!",
	SpecWarnDarkOrb	= "¡Orbes escudo!"
}

L:SetTimerLocalization{
	TimerBlueOrb	= "Orbe azules activo"
}

L:SetOptionLocalization{
	WarnDarkOrb		= "Mostrar aviso cuando aparezcan Orbes escudo",
	WarnBlueOrb		= "Mostrar aviso cuando se active un orbe azul",
	SpecWarnDarkOrb	= "Mostrar aviso especial cuando aparezcan Orbes escudo",
	SpecWarnBlueOrb	= "Mostrar aviso especial cuando se active un orbe azul",
	TimerBlueOrb	= "Mostrar temporizador para la activación de los orbes azules",
	RangeFrame		= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT:format(10, 45641),
	BloomIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(45641)
}

L:SetMiscLocalization{
	YellPull		= "Los prescindibles han muerto. ¡Que así sea! ¡Ahora triunfaré donde Sargeras no lo logró! ¡Desangraré este despreciable mundo y me aseguraré mi puesto como verdadero maestro de la Legión Ardiente! ¡El final ha llegado! ¡Dejad que se desvele el misterio de este mundo!",
	OrbYell1		= "¡Canalizaré mi poder en los orbes! ¡Preparaos!",
	OrbYell2		= "¡He otorgado mi poder a otro orbe! ¡Usadlo rápido!",
	OrbYell3		= "¡Otro orbe preparado! ¡Daos prisa!",
	OrbYell4		= "¡He canalizado todo lo que puedo! ¡El poder está en vuestras manos!"

}

-----------------
--  Najentus  --
-----------------
L = DBM:GetModLocalization("Najentus")

L:SetGeneralLocalization{
	name = "Gran señor de la guerra Naj'entus"
}

L:SetOptionLocalization{
	RangeFrame	= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT_SHORT:format(8)
}

L:SetMiscLocalization{
	HealthInfo	= "Salud de los jugadores"
}

----------------
-- Supremus --
----------------
L = DBM:GetModLocalization("Supremus")

L:SetGeneralLocalization{
	name = "Supremus"
}

L:SetWarningLocalization{
	WarnPhase		= "Fase de %s",
	WarnKite		= "Mirada en >%s<"
}

L:SetTimerLocalization{
	TimerPhase		= "Siguiente fase de %s"
}

L:SetOptionLocalization{
	WarnPhase		= "Anunciar cambios de fase",
	WarnKite		= "Anunciar objetivos de Mirada",
	TimerPhase		= "Mostrar temporizador para los cambios de fase",
	KiteIcon		= "Poner icono en el objetivo de Mirada"
}

L:SetMiscLocalization{
	PhaseTank		= "golpea el suelo enfadado!",
	PhaseKite		= "El suelo comienza a abrirse.",
	ChangeTarget	= "adquiere un nuevo objetivo!",
	Kite			= "persecución",
	Tank			= "tanqueo"
}

-------------------------
--  Shape of Akama  --
-------------------------
L = DBM:GetModLocalization("Akama")

L:SetGeneralLocalization{
	name = "Sombra de Akama"
}

-------------------------
--  Teron Gorefiend  --
-------------------------
L = DBM:GetModLocalization("TeronGorefiend")

L:SetGeneralLocalization{
	name = "Teron Sanguino"
}

L:SetTimerLocalization{
	TimerVengefulSpirit		= "Fantasma: %s"
}

L:SetOptionLocalization{
	TimerVengefulSpirit		= "Mostrar temporizador para la duración de la forma de fantasma",
	CrushIcon				= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(40243)
}

----------------------------
--  Gurtogg Bloodboil  --
----------------------------
L = DBM:GetModLocalization("Bloodboil")

L:SetGeneralLocalization{
	name = "Gurtogg Sangre Hirviente"
}

--------------------------
--  Essence Of Souls  --
--------------------------
L = DBM:GetModLocalization("Souls")

L:SetGeneralLocalization{
	name = "Relicario de Almas"
}

L:SetWarningLocalization{
	WarnMana		= "Sin maná en 30 s"
}

L:SetTimerLocalization{
	TimerMana		= "Sin maná"
}

L:SetOptionLocalization{
	WarnMana		= "Mostrar aviso previo para cuando el maná máximo de los jugadores llegue a cero en Fase 2",
	TimerMana		= "Mostrar temporizador para cuando el maná máximo de los jugadores llegue a cero en Fase 2"
}

L:SetMiscLocalization{
	Suffering		= "Esencia de sufrimiento",
	Desire			= "Esencia de deseo",
	Anger			= "Esencia de inquina"
}

-----------------------
--  Mother Shahraz --
-----------------------
L = DBM:GetModLocalization("Shahraz")

L:SetGeneralLocalization{
	name = "Madre Shahraz"
}

L:SetTimerLocalization{
	timerAura	= "%s"
}

L:SetOptionLocalization{
	timerAura	= "Mostrar temporizador para la siguiente Aura centelleante"
}

----------------------
--  Illidari Council  --
----------------------
L = DBM:GetModLocalization("Council")

L:SetGeneralLocalization{
	name = "El Consejo Illidari"
}

L:SetWarningLocalization{
	Immune			= "Malande inmune a %s durante 15 s"
}

L:SetOptionLocalization{
	Immune			= "Mostrar aviso cuando Manalde se vuelva inmune al daño físico o de hechizos"
}

L:SetMiscLocalization{
	Gathios			= "Gathios el Despedazador",
	Malande			= "Lady Malande",
	Zerevor			= "Sumo abisálico Zerevor",
	Veras			= "Veras Sombra Oscura",
	Melee			= "físico",
	Spell			= "hechizos"
}

-------------------------
--  Illidan Stormrage --
-------------------------
L = DBM:GetModLocalization("Illidan")

L:SetGeneralLocalization{
	name = "Illidan Tempestira"
}

L:SetWarningLocalization{
	WarnHuman		= "Fase humanoide",
	WarnDemon		= "Fase demoníaca"
}

L:SetTimerLocalization{
	TimerNextHuman		= "Siguiente fase humanoide",
	TimerNextDemon		= "Siguiente fase demoníaca"
}

L:SetOptionLocalization{
	WarnHuman		= "Anunciar cambio a fase humanoide",
	WarnDemon		= "Anunciar cambio a fase demoníaca",
	TimerNextHuman	= "Mostrar temporizador para la siguiente fase humanoide",
	TimerNextDemon	= "Mostrar temporizador para la siguiente fase demoníaca",
	RangeFrame		= "Mostrar marco de distancia (10 m) en las fases 3 y 4"
}

L:SetMiscLocalization{
	Pull			= "Akama. Tu hipocresía no me sorprende. Debí acabar contigo y con tus malogrados hermanos hace tiempo.",
	Eyebeam			= "¡Mirad los ojos del Traidor!",
	Demon			= "¡Observad el poder...del demonio interior!",--sic
	Phase4			= "¿Esto es todo, mortales? ¿Es esta toda la furia que podéis reunir?"
}

------------------------
--  Rage Winterchill  --
------------------------
L = DBM:GetModLocalization("Rage")

L:SetGeneralLocalization{
	name = "Ira Fríoinvierno"
}

-----------------
--  Anetheron  --
-----------------
L = DBM:GetModLocalization("Anetheron")

L:SetGeneralLocalization{
	name = "Anetheron"
}

----------------
--  Kazrogal  --
----------------
L = DBM:GetModLocalization("Kazrogal")

L:SetGeneralLocalization{
	name = "Kaz'rogal"
}

---------------
--  Azgalor  --
---------------
L = DBM:GetModLocalization("Azgalor")

L:SetGeneralLocalization{
	name = "Azgalor"
}

------------------
--  Archimonde  --
------------------
L = DBM:GetModLocalization("Archimonde")

L:SetGeneralLocalization{
	name = "Archimonde"
}

----------------
-- WaveTimers --
----------------
L = DBM:GetModLocalization("HyjalWaveTimers")

L:SetGeneralLocalization{
	name 		= "Oleadas"
}
L:SetWarningLocalization{
	WarnWave	= "%s",
}
L:SetTimerLocalization{
	TimerWave	= "Siguiente oleada"
}
L:SetOptionLocalization{
	WarnWave		= "Mostrar aviso cuando se aproxime una oleada",
	DetailedWave	= "Mostrar aviso detallado con los tipos y número de enemigos cuando se aproxime una oleada",
	TimerWave		= "Mostrar temporizador para la siguiente oleada"
}
L:SetMiscLocalization{
	HyjalZoneName	= "La Cima Hyjal",
	Thrall			= "Thrall",
	Jaina			= "Lady Jaina Valiente",
	GeneralBoss		= "Se aproxima un jefe",
	RageWinterchill	= "Se aproxima Ira Fríoinvierno",
	Anetheron		= "Se aproxima Anetheron",
	Kazrogal		= "Se aproxima Kazrogal",
	Azgalor			= "Se aproxima Azgalor",
	WarnWave_0		= "Oleada %s/8",
	WarnWave_1		= "Oleada %s/8 - %s %s",
	WarnWave_2		= "Oleada %s/8 - %s %s y %s %s",
	WarnWave_3		= "Oleada %s/8 - %s %s, %s %s y %s %s",
	WarnWave_4		= "Oleada %s/8 - %s %s, %s %s, %s %s y %s %s",
	WarnWave_5		= "Oleada %s/8 - %s %s, %s %s, %s %s, %s %s y %s %s",
	RageGossip		= "Mis compañeros y yo estamos contigo, Lady Valiente.",
	AnetheronGossip	= "Estamos listos para cualquier cosa que Archimonde nos mande, Lady Valiente.",
	KazrogalGossip	= "Estoy contigo, Thrall.",
	AzgalorGossip	= "No tenemos nada que temer.",
	Ghoul			= "Necrófagos",
	Abomination		= "Abominaciones",
	Necromancer		= "Nigromantes",
	Banshee			= "Almas en pena",
	Fiend			= "Malignos de cripta",
	Gargoyle		= "Gárgolas",
	Wyrm			= "Vermis de escarcha",
	Stalker			= "Acechadores viles",
	Infernal		= "Infernales"
}

-----------
--  Alar --
-----------
L = DBM:GetModLocalization("Alar")

L:SetGeneralLocalization{
	name = "Al'ar"
}

L:SetTimerLocalization{
	NextPlatform	= "Siguiente plataforma (max.)"
}

L:SetOptionLocalization{
	NextPlatform	= "Mostrar temporizador para el tiempo máximo que Al'ar puede permanecer en una plataforma"
}

------------------
--  Void Reaver --
------------------
L = DBM:GetModLocalization("VoidReaver")

L:SetGeneralLocalization{
	name = "Atracador del vacío"
}

--------------------------------
--  High Astromancer Solarian --
--------------------------------
L = DBM:GetModLocalization("Solarian")

L:SetGeneralLocalization{
	name = "Gran astromante Solarian"
}

L:SetWarningLocalization{
	WarnSplit		= "Separación de banda",
	WarnSplitSoon	= "Separación de banda en 5 s",
	WarnAgent		= "Agentes",
	WarnPriest		= "Sacerdotes y Solarian"

}

L:SetTimerLocalization{
	TimerSplit		= "Siguiente separación",
	TimerAgent		= "Siguientes agentes",
	TimerPriest		= "Sacerdotes y Solarian"
}

L:SetOptionLocalization{
	WarnSplit		= "Mostrar aviso para la separación de banda",
	WarnSplitSoon	= "Mostrar aviso previo para la separación de banda",
	WarnAgent		= "Mostrar aviso cuando aparezcan Agentes Solarium",
	WarnPriest		= "Mostrar aviso cuando aparezcan los Sacerdotes Solarium y la Gran astromante Solarian",
	TimerSplit		= "Mostrar temporizador para la separación de banda",
	TimerAgent		= "Mostrar temporizador para los siguientes Agentes Solarium",
	TimerPriest		= "Mostrar temporizador para cuando vuelva a aparecer la Gran astromante Solarian con los Sacerdotes Solarium"
}

L:SetMiscLocalization{
	YellSplit1		= "¡Aplastaré vuestros delirios de grandeza!",
	YellSplit2		= "¡Os superamos con creces!",
	YellPhase2		= "Me FUNDO... ¡con el VACÍO!"
}

---------------------------
--  Kael'thas Sunstrider --
---------------------------
L = DBM:GetModLocalization("KaelThas")

L:SetGeneralLocalization{
	name = "Kael'thas Caminante del Sol"
}

L:SetWarningLocalization{
	WarnGaze		= "Mirada en >%s<",
	WarnMobDead		= "%s muerto",
	WarnEgg			= "Huevo de fénix",
	SpecWarnGaze	= "Mirada en ti - ¡huye!",
	SpecWarnEgg		= "Huevo de Fénix - ¡cambia de objetivo!"
}

L:SetTimerLocalization{
	TimerPhase		= "Siguiente fase",
	TimerPhase1mob	= "%s",
	TimerNextGaze	= "Mirada: Cambio de objetivo",
	TimerRebirth	= "Fénix: Renacimiento"
}

L:SetOptionLocalization{
	WarnGaze		= "Anunciar objetivos de la Mirada de Thaladred",
	WarnMobDead		= "Mostrar aviso cuando muera un esbirro en Fase 2",
	WarnEgg			= "Mostrar aviso cuando aparezca un Huevo de fénix",
	SpecWarnGaze	= "Mostrar aviso especial cuando te afecte Mirada",
	SpecWarnEgg		= "Mostrar aviso especial cuando aparezca un Huevo de fénix",
	TimerPhase		= "Mostrar temporizador para la siguiente faseShow time for next phase",
	TimerPhase1mob	= "Mostrar temporizador para cuando se active cada jefe de Fase 1",
	TimerNextGaze	= "Show timer for Thaladred's Gaze target changes",
	TimerRebirth	= "Mostrar temporizador para el renacimiento de los Huevos de fénix",
	GazeIcon		= "Poner icono en el objetivo de la Mirada de Thaladred"
}

L:SetMiscLocalization{
	YellPhase2	= "Como veis, dispongo de un amplio arsenal...",
	YellPhase3	= "Quizás os subestimé. Sería injusto que os enfrentarais a los cuatro consejeros al mismo tiempo, pero... nunca se le ha brindado un trato justo a mi gente. Así que os devuelvo el favor.",
	YellPhase4	= "Desafortunadamente hay veces en las que tienes que hacer las cosas con tus propias manos. ¡Balamore shanal!",
	YellPhase5	= "¡No he llegado hasta aquí para que me detengáis! ¡El futuro que he planeado no se pondrá en peligro! ¡Vais a probar el verdadero poder!",
	YellSang	= "Habéis sobrevivido a algunos de mis mejores consejeros... pero nadie puede resistir el poder del Martillo de Sangre. ¡He aquí Lord Sanguinar!",
	YellCaper	= "Capernian se encargará de que vuestra visita sea breve.",
	YellTelo	= "Bien hecho. Parecéis dignos de probar vuestras habilidades con mi maestro ingeniero Telonicus.",
	EmoteGaze	= "mira a ([^%s]+)!",
	Thaladred	= "Thaladred el Ensombrecedor",
	Sanguinar	= "Lord Sanguinar",
	Capernian	= "Gran astromante Capernian",
	Telonicus	= "Maestro ingeniero Telonicus",
	Bow			= "Arco largo de fibra abisal",
	Axe			= "Devastación",
	Mace		= "Inyector cósmico",
	Dagger		= "Hoja de infinidad",
	Sword		= "Cercenador de distorsión",
	Shield		= "Baluarte de cambio de fase",
	Staff		= "Bastón de desintegración",
	Egg			= "Huevo de fénix"
}

---------------------------
--  Hydross the Unstable --
---------------------------
L = DBM:GetModLocalization("Hydross")

L:SetGeneralLocalization{
	name = "Hydross el Inestable"
}

L:SetWarningLocalization{
	WarnMark 		= "%s: %s",
	WarnPhase		= "Fase de %s",
	SpecWarnMark	= "%s: %s"
}

L:SetTimerLocalization{
	TimerMark	= "Next %s : %s"
}

L:SetOptionLocalization{
	WarnMark		= "Mostrar aviso para las marcas",
	WarnPhase		= "Anunciar cambios de fase",
	SpecWarnMark	= "Mostrar aviso cuando el daño del perjuicio de las marcas esté por encima del 100%",
	TimerMark		= "Mostrar temporizador para las siguientes marcas",
	RangeFrame		= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT_SHORT:format(10)
}

L:SetMiscLocalization{
	Frost	= "Escarcha",
	Nature	= "Naturaleza"
}

-----------------------
--  The Lurker Below --
-----------------------
L = DBM:GetModLocalization("LurkerBelow")

L:SetGeneralLocalization{
	name = "El Rondador de abajo"
}

L:SetWarningLocalization{
	WarnSubmerge		= "Sumersión",
	WarnEmerge			= "Emersión"
}

L:SetTimerLocalization{
	TimerSubmerge		= "Sumersión TdR",
	TimerEmerge			= "Emersión TdR"
}

L:SetOptionLocalization{
	WarnSubmerge		= "Mostrar aviso cuando el jefe se sumerja",
	WarnEmerge			= "Mostrar aviso cuando el jefe regrese a la superficie",
	TimerSubmerge		= "Mostrar temporizador para cuando el jefe de sumerja",
	TimerEmerge			= "Mostrar temporizador para cuando el jefe regrese a la superficie"
}

--------------------------
--  Leotheras the Blind --
--------------------------
L = DBM:GetModLocalization("Leotheras")

L:SetGeneralLocalization{
	name = "Leotheras el Ciego"
}

L:SetWarningLocalization{
	WarnPhase		= "Fase %s"
}

L:SetTimerLocalization{
	TimerPhase	= "Siguiente fase %s "
}

L:SetOptionLocalization{
	WarnPhase		= "Anunciar cambios de fase",
	TimerPhase		= "Mostrar temporizador para la siguiente fase"
}

L:SetMiscLocalization{
	Human		= "humana",
	Demon		= "demoníaca",
	YellDemon	= "Desaparece, elfo pusilánime. ¡Yo mando ahora!",
	YellPhase2	= "¿Qué has hecho? ¡Yo soy el maestro!"
}

-----------------------------
--  Fathom-Lord Karathress --
-----------------------------
L = DBM:GetModLocalization("Fathomlord")

L:SetGeneralLocalization{
	name = "Señor de las profundidades Karathress"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
}

L:SetMiscLocalization{
	Caribdis	= "Guardia de las profundidades Caribdis",
	Tidalvess	= "Guardia de las profundidades Tidalvess",
	Sharkkis	= "Guardia de las profundidades Sharkkis"
}

--------------------------
--  Morogrim Tidewalker --
--------------------------
L = DBM:GetModLocalization("Tidewalker")

L:SetGeneralLocalization{
	name = "Morogrim Levantamareas"
}

L:SetWarningLocalization{
	WarnMurlocs		= "Múrlocs",
	SpecWarnMurlocs	= "Múrlocs"
}

L:SetTimerLocalization{
	TimerMurlocs	= "Siguientes múrlocs"
}

L:SetOptionLocalization{
	WarnMurlocs		= "Mostrar aviso cuando aparezcan múrlocs",
	SpecWarnMurlocs	= "Mostrar aviso especial cuando aparezcan múrlocs",
	TimerMurlocs	= "Mostrar temporizador para los siguientes múrlocs",
	GraveIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(38049)
}

L:SetMiscLocalization{
}

-----------------
--  Lady Vashj --
-----------------
L = DBM:GetModLocalization("Vashj")

L:SetGeneralLocalization{
	name = "Lady Vashj"
}

L:SetWarningLocalization{
	WarnElemental		= "Elemental corrupto (%s) en breve",
	WarnStrider			= "Zancudo (%s) en breve",
	WarnNaga			= "Élite (%s) en breve",
	WarnShield			= "Escudo: %d/4",
	WarnLoot			= "Núcleo máculo en >%s<",
	SpecWarnElemental	= "Elemental corrupto - ¡cambia de objetivo!"
}

L:SetTimerLocalization{
	TimerElementalActive	= "Elemental corrupto activo",
	TimerElemental			= "Siguiente Elemental corrupto (%d)",
	TimerStrider			= "Siguiente Zancudo (%d)",
	TimerNaga				= "Siguiente Élite (%d)"
}

L:SetOptionLocalization{
	WarnElemental		= "Mostrar aviso previo para el siguiente Elemental corrupto",
	WarnStrider			= "Mostrar aviso previo para el siguiente Zancudo Colmillo Torcido",
	WarnNaga			= "Mostrar aviso especial para el siguiente Élite Colmillo Torcido",
	WarnShield			= "Mostrar aviso cuando disminuya el escudo de la fase 2",
	WarnLoot			= "Mostrar aviso cuando un jugador despoje un Núcleo máculo",
	TimerElementalActive	= "Mostrar temporizador para la duración restante de los Elementales corruptos",
	TimerElemental		= "Mostrar temporizador para el siguiente Elemental corrupto",
	TimerStrider		= "Mostrar temporizador para el siguiente Zancudo Colmillo Torcido",
	TimerNaga			= "Mostrar temporizador para el siguiente Élite Colmillo Torcido",
	SpecWarnElemental	= "Mostrar aviso previo especial para cuando aparezca un Elemental corrupto",
	RangeFrame			= "Mostrar marco de distancia (10 m)",
	ChargeIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(38280),
	AutoChangeLootToFFA	= "Cambiar modo de botín a libre en Fase 2"
}

L:SetMiscLocalization{
	DBM_VASHJ_YELL_PHASE2	= "¡Ha llegado el momento! ¡Que no quede ni uno en pie!",
	DBM_VASHJ_YELL_PHASE3	= "Os vendrá bien cubriros.",
	LootMsg					= "([^%s]+).*Hitem:(%d+)"
}

--Maulgar
L = DBM:GetModLocalization("Maulgar")

L:SetGeneralLocalization{
	name = "Su majestad Maulgar"
}


--Gruul the Dragonkiller
L = DBM:GetModLocalization("Gruul")

L:SetGeneralLocalization{
	name = "Gruul el Asesino de Dragones"
}

L:SetWarningLocalization{
	WarnGrowth	= "%s (%d)"
}

L:SetOptionLocalization{
	WarnGrowth	= "Mostrar aviso para $spell:36300"
}


-- Magtheridon
L = DBM:GetModLocalization("Magtheridon")

L:SetGeneralLocalization{
	name = "Magtheridon"
}

L:SetTimerLocalization{
	timerP2	= "Fase 2"
}

L:SetOptionLocalization{
	timerP2	= "Mostrar temporizador para el cambio a Fase 2"
}

L:SetMiscLocalization{
	DBM_MAG_EMOTE_PULL		= "¡Las cuerdas de %s empiezan a aflojarse!",
	DBM_MAG_YELL_PHASE2		= "¡He... sido... liberado!",
	DBM_MAG_YELL_PHASE3		= "¡No me dejaré encerrar tan fácilmente! ¡Que tiemblen las paredes de esta prisión... y se derrumben!"
}

--Attumen
L = DBM:GetModLocalization("Attumen")

L:SetGeneralLocalization{
	name = "Attumen el Montero"
}

L:SetMiscLocalization{
	DBM_ATH_YELL_1		= "¡Ven, Medianoche, vamos a dispersar a estos pusilánimes!"
}


--Moroes
L = DBM:GetModLocalization("Moroes")

L:SetGeneralLocalization{
	name = "Moroes"
}

L:SetWarningLocalization{
	DBM_MOROES_VANISH_FADED	= "Esfumarse ha terminado"
}

L:SetOptionLocalization{
	DBM_MOROES_VANISH_FADED	= "Mostrar aviso cuando termine Esfumarse"
}


-- Maiden of Virtue
L = DBM:GetModLocalization("Maiden")

L:SetGeneralLocalization{
	name = "Doncella de Virtud"
}

-- Romulo and Julianne
L = DBM:GetModLocalization("RomuloAndJulianne")

L:SetGeneralLocalization{
	name = "Romulo y Julianne"
}

L:SetMiscLocalization{
	Event				= "¡Esta noche... vamos a explorar un relato de amor prohibido!",
	RJ_Pull				= "¿Qué demonio sois que me atormentáis de questa manera?",
	DBM_RJ_PHASE2_YELL	= "Adelante, gentil noche, ¡devuélveme a mi Romulo!",
	Romulo				= "Romulo",
	Julianne			= "Julianne"
}


-- Big Bad Wolf
L = DBM:GetModLocalization("BigBadWolf")

L:SetGeneralLocalization{
	name = "El Lobo Feroz"
}

L:SetWarningLocalization{
}

L:SetMiscLocalization{
	DBM_BBW_YELL_1			= "¡Para poseerte mejor!"
}


-- Wizard of Oz
L = DBM:GetModLocalization("Oz")

L:SetGeneralLocalization{
	name = "Mago de Oz"
}

L:SetWarningLocalization{
	DBM_OZ_WARN_TITO		= "Tito",
	DBM_OZ_WARN_ROAR		= "Rugido",
	DBM_OZ_WARN_STRAWMAN	= "Espantapájaros",
	DBM_OZ_WARN_TINHEAD		= "Cabezalata",
	DBM_OZ_WARN_CRONE		= "La Vieja Bruja"
}

L:SetTimerLocalization{
	DBM_OZ_WARN_TITO		= "Tito",
	DBM_OZ_WARN_ROAR		= "Rugido",
	DBM_OZ_WARN_STRAWMAN	= "Espantapájaros",
	DBM_OZ_WARN_TINHEAD		= "Cabezalata"
}

L:SetOptionLocalization{
	AnnounceBosses			= "Show warnings for boss spawns",
	ShowBossTimers			= "Show timers for boss spawns"
}

L:SetMiscLocalization{
	DBM_OZ_YELL_DOROTHEE	= "¡Oh, Tito, solo tenemos que buscar la manera de volver a casa! ¡El viejo zahorí puede ser nuestra única esperanza! Espantapájaros, Rugido, Cabezalata, podeis- esperad... ¡Oh, caray, mirad tenemos visita!",--sic
	DBM_OZ_YELL_ROAR		= "¡No os tengo miedo! ¿Queréis pelea? ¿Eh? ¡Vamos, con las garras a la espalda os reto!",
	DBM_OZ_YELL_STRAWMAN	= "¿Ahora que tengo que hacer contigo? No me puedo decidir.",--sic
	DBM_OZ_YELL_TINHEAD		= "¿Me vendría bien un corazón Digamos, ¿el tuyo?",--sic
	DBM_OZ_YELL_CRONE		= "¡Pronto acabará todo!"--There seems to be two lines, but I only ever see this one in Spanish; the one in the English localization file is the other possible pull line.
}


-- Curator
L = DBM:GetModLocalization("Curator")

L:SetGeneralLocalization{
	name = "Curator"
}

L:SetWarningLocalization{
	warnAdd		= "Centellas astrales"
}

L:SetOptionLocalization{
	warnAdd		= "Mostrar aviso cuando aparezcan las Centellas astrales"
}


-- Terestian Illhoof
L = DBM:GetModLocalization("TerestianIllhoof")

L:SetGeneralLocalization{
	name = "Terestian Pezuña Enferma"
}

L:SetMiscLocalization{
	Kilrek					= "Kil'rek",
	DChains					= "Cadenas demoníacas"
}


-- Shade of Aran
L = DBM:GetModLocalization("Aran")

L:SetGeneralLocalization{
	name = "Sombra de Aran"
}

L:SetWarningLocalization{
	DBM_ARAN_DO_NOT_MOVE	= "Corona de llamas - ¡no te muevas!"
}

L:SetTimerLocalization{
	timerSpecial			= "Facultad especial TdR"
}

L:SetOptionLocalization{
	timerSpecial			= "Mostrar temporizador para el tiempo de reutilización de las facultades especiales",
	DBM_ARAN_DO_NOT_MOVE	= "Mostrar aviso especial para $spell:30004"
}

--Netherspite
L = DBM:GetModLocalization("Netherspite")

L:SetGeneralLocalization{
	name = "Rencor Abisal"
}

L:SetWarningLocalization{
	warningPortal			= "Fase de portales",
	warningBanish			= "Fase de destierro"
}

L:SetTimerLocalization{
	timerPortalPhase	= "Fase de portales",
	timerBanishPhase	= "Fase de destierro"
}

L:SetOptionLocalization{
	warningPortal			= "Anunciar cambio a fase de portales",
	warningBanish			= "Anunciar cambio a fase de destierro",
	timerPortalPhase		= "Mostrar temporizador para la duración de la fase de portales",
	timerBanishPhase		= "Mostrar temporizador para la duración de la fase de destierro"
}

L:SetMiscLocalization{
	DBM_NS_EMOTE_PHASE_2	= "¡%s monta en cólera alimentada por el vacío!",
	DBM_NS_EMOTE_PHASE_1	= "%s cries out in withdrawal, opening gates to the nether."
}

--Chess
L = DBM:GetModLocalization("Chess")

L:SetGeneralLocalization{
	name = "Chess Event"
}

L:SetTimerLocalization{
	timerCheat	= "Medivh hace trampas (TdR)"
}

L:SetOptionLocalization{
	timerCheat	= "Mostrar temporizador para cuando el Eco de Medivh haga trampas"
}

L:SetMiscLocalization{
	EchoCheats	= "¡Eco de Medivh hace trampas!"
}

--Prince Malchezaar
L = DBM:GetModLocalization("Prince")

L:SetGeneralLocalization{
	name = "Príncipe Malchezaar"
}

L:SetMiscLocalization{
	DBM_PRINCE_YELL_P2		= "¡Estúpidos! El tiempo es el fuego en el que arderéis!",--sic
	DBM_PRINCE_YELL_P3		= "¿Cómo podéis esperar rebelaros ante un poder tan aplastante?",
	DBM_PRINCE_YELL_INF1	= "¡Todas las realidades, todas las dimensiones están abiertas a mí!",
	DBM_PRINCE_YELL_INF2	= "¡No solo os enfrentáis a Malechezaar, sino a todas las legiones bajo mi mando!"
}


-- Nightbane
L = DBM:GetModLocalization("NightbaneRaid")

L:SetGeneralLocalization{
	name = "Nocturno"
}

L:SetWarningLocalization{
	DBM_NB_AIR_WARN			= "Fase aérea"
}

L:SetTimerLocalization{
	timerAirPhase			= "Fase aérea"
}

L:SetOptionLocalization{
	DBM_NB_AIR_WARN			= "Anunciar cambio a fase aérea",
	timerAirPhase			= "Mostrar temporizador para la duración de la fase aérea"
}

L:SetMiscLocalization{
	DBM_NB_EMOTE_PULL		= "Un ser antiguo se despierta en la distancia...",
	DBM_NB_YELL_AIR			= "Miserable alimaña. ¡Te exterminaré desde el aire!",
	DBM_NB_YELL_GROUND		= "¡Ya basta! Voy a aterrizar y a aplastarte yo mismo.",
	DBM_NB_YELL_GROUND2		= "¡Insectos! ¡Os enseñaré mi fuerza de cerca!"
}


-- Named Beasts
L = DBM:GetModLocalization("Shadikith")

L:SetGeneralLocalization{
	name = "Shadikith el Planeador"
}

L = DBM:GetModLocalization("Hyakiss")

L:SetGeneralLocalization{
	name = "Hyakiss el Acechador"
}

L = DBM:GetModLocalization("Rokad")

L:SetGeneralLocalization{
	name = "Rokad el Devastador"
}

if WOW_PROJECT_ID == (WOW_PROJECT_MAINLINE or 1) then return end--Anything below here is only needed for classic wrath or classic bc

---------------
--  Nalorakk --
---------------
L = DBM:GetModLocalization("Nalorakk")

L:SetGeneralLocalization{
	name = "Nalorakk"
}

L:SetWarningLocalization{
	WarnBear		= "Forma de oso",
	WarnBearSoon	= "Forma de oso en 5 seg",
	WarnNormal		= "Forma normal",
	WarnNormalSoon	= "Forma normal en 5 seg"
}

L:SetTimerLocalization{
	TimerBear		= "Bär",
	TimerNormal		= "Normale Form"
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
	YellBear 	= "¡Si llamáis a la bestia, vais a recibir más de lo que esperáis!",
	YellNormal	= "¡Dejad paso al Nalorakk!"
}

---------------
--  Akil'zon --
---------------
L = DBM:GetModLocalization("Akilzon")

L:SetGeneralLocalization{
	name = "Akil'zon"
}

---------------
--  Jan'alai --
---------------
L = DBM:GetModLocalization("Janalai")

L:SetGeneralLocalization{
	name = "Jan'alai"
}

L:SetMiscLocalization{
	YellBomb	= "¡Ahora os quemaré!",
	YellAdds	= "¿Dónde está mi criador? ¡A por los huevos!"
}

--------------
--  Halazzi --
--------------
L = DBM:GetModLocalization("Halazzi")

L:SetGeneralLocalization{
	name = "Halazzi"
}

L:SetWarningLocalization{
	WarnSpirit	= "Sale espíritu",
	WarnNormal	= "Desaparece espíritu"
}

L:SetOptionLocalization{
	WarnSpirit	= "Show warning for Spirit phase",--Translate
	WarnNormal	= "Show warning for Normal phase"--Translate
}

L:SetMiscLocalization{
	YellSpirit	= "Lucho con libertad de espíritu...",
	YellNormal	= "¡Espíritu, vuelve a mí!"
}

--------------------------
--  Hex Lord Malacrass --
--------------------------
L = DBM:GetModLocalization("Malacrass")

L:SetGeneralLocalization{
	name = "Señor aojador Malacrass"
}

L:SetMiscLocalization{
	YellPull	= "Las sombras caerán sobre vosotros..."
}

--------------
--  Zul'jin --
--------------
L = DBM:GetModLocalization("ZulJin")

L:SetGeneralLocalization{
	name = "Zul'jin"
}

L:SetMiscLocalization{
	YellPhase2	= "Tengo algunos trucos nuevos... como mi hermano el oso...",
	YellPhase3	= "¡No podéis esconderos del águila!",
	YellPhase4	= "¡Dejad que os presente a mis nuevos hermanos: colmillo y garra!",
	YellPhase5	= "¡No tenéis que mirar al cielo para ver al dracohalcón!"
}
