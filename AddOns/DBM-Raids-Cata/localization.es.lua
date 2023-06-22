if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

--------------
-- Argaloth --
--------------
L= DBM:GetModLocalization(139)

L:SetOptionLocalization({
	SetIconOnConsuming		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(88954)
})

---------------
-- Occu'thar --
---------------
L= DBM:GetModLocalization(140)

-------------------------------
-- Alizabal, Señora del odio --
-------------------------------
L= DBM:GetModLocalization(339)

L:SetTimerLocalization({
	TimerFirstSpecial		= "Primera facultad especial"
})

L:SetOptionLocalization({
	TimerFirstSpecial		= "Mostrar temporizador para la primera facultad especial ($spell:105067 o $spell:104936) tras $spell:105738"
})

--------------------------------------
--  Sistema de Defensa de Omnitron  --
--------------------------------------
L = DBM:GetModLocalization(169)

L:SetWarningLocalization({
	SpecWarnActivated			= "¡Cambia de objetivo a %s!",
	specWarnGenerator			= "Generador de poder - ¡saca a %s!"
})

L:SetTimerLocalization({
	timerShadowConductorCast	= "Conductor de las Sombras",
	timerArcaneLockout			= "Aniquilador Arcano bloqueado",
	timerArcaneBlowbackCast		= "Retorno Arcano",
	timerNefAblity				= "Mejora de Nefarius TdR"
})

L:SetOptionLocalization({
	timerShadowConductorCast	= "Mostrar temporizador para el lanzamiento de $spell:92048",
	timerArcaneLockout			= "Mostrar temporizador para el bloqueo de lanzamiento de $spell:79710",
	timerArcaneBlowbackCast		= "Mostrar temporizador para el lanzamiento de $spell:91879",
	timerNefAblity				= "Mostrar temporizador para las mejoras de lord Victor Nefarius (dificultad heroica)",
	SpecWarnActivated			= "Mostrar aviso especial cuando se active un jefe",
	specWarnGenerator			= "Mostrar aviso especial cuando un jefe obtenga $spell:79629",
	AcquiringTargetIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79501),
	ConductorIcon				= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79888),
	ShadowConductorIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92053),
	SetIconOnActivated			= "Poner icono en el último jefe activado"
})

L:SetMiscLocalization({
	YellTargetLock				= "¡Sombras atrapantes! ¡Apartaos de mí!"
})

------------------
--  Faucemagma  --
------------------
L = DBM:GetModLocalization(170)

L:SetWarningLocalization({
	SpecWarnInferno	= "Ensamblaje osario llameante en breve (unos 4 s)"
})

L:SetOptionLocalization({
	SpecWarnInferno	= "Mostrar aviso especial previo para $spell:92154 (unos 4 s)",
	RangeFrame		= "Mostrar marco de distancia en fase 2 (5 m)"
})

L:SetMiscLocalization({
	Slump			= "¡%s cae hacia delante y deja expuestas sus tenazas!",
	HeadExposed		= "¡%s acaba empalado en el pincho y deja expuesta la cabeza!",
	YellPhase2		= "¡Inconcebible! ¡Existe la posibilidad de que venzáis a mi gusano de lava! Quizás yo pueda... desequilibrar la balanza."
})

-----------------
--  Atramedes  --
-----------------
L = DBM:GetModLocalization(171)

L:SetOptionLocalization({
	InfoFrame				= "Mostrar marco de información para $journal:3072",
	TrackingIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(78092)
})

L:SetMiscLocalization({
	NefAdd					= "¡Atramedes, los héroes están justo AHÍ!",
	Airphase				= "¡Sí, corred! Con cada paso, vuestros corazones se aceleran. El latido, fuerte y clamoroso... Casi ensordecedor. ¡No podéis escapar!"
})

-----------------
--  Chimaeron  --
-----------------
L = DBM:GetModLocalization(172)

L:SetOptionLocalization({
	RangeFrame		= "Mostrar marco de distancia (6 m)",
	SetIconOnSlime	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82935),
	InfoFrame		= "Mostrar marco de información de salud (por debajo de 10mil)"
})

L:SetMiscLocalization({
	HealthInfo	= "Información de salud"
})

----------------
--  Maloriak  --
----------------
L = DBM:GetModLocalization(173)

L:SetWarningLocalization({
	WarnPhase			= "Fase %s"
})

L:SetTimerLocalization({
	TimerPhase			= "Siguiente fase"
})

L:SetOptionLocalization({
	WarnPhase			= "Mostrar aviso para cuál es la siguiente fase",
	TimerPhase			= "Mostrar temporizador para la siguiente fase",
	RangeFrame			= "Mostrar marco de distancia (6 m) durante la fase azul",
	SetTextures			= "Desactivar automáticamente la opción gráfica de texturas proyectadas durante la fase oscura (se reactivará automáticamente al cambiar de fase)",
	FlashFreezeIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(77699),
	BitingChillIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(77760),
	ConsumingFlamesIcon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(77786)
})

L:SetMiscLocalization({
	YellRed				= "rojo|r a la caldera!",--Partial matchs, no need for full strings unless you really want em, mod checks for both.
	YellBlue		= "azul|r a la caldera!",
	YellGreen		= "verde|r a la caldera!",
	YellDark		= "oscura|r en el caldero!"
})

----------------------------
--  El final de Nefarian  --
----------------------------
L = DBM:GetModLocalization(174)

L:SetWarningLocalization({
	OnyTailSwipe			= "Latigazo de cola (Onyxia)",
	NefTailSwipe			= "Latigazo de cola (Nefarian)",
	OnyBreath				= "Aliento (Onyxia)",
	NefBreath				= "Aliento (Nefarian)",
	specWarnShadowblazeSoon	= "%s",
	warnShadowblazeSoon		= "%s"
})

L:SetTimerLocalization({
	timerNefLanding			= "Nefarian aterriza",
	OnySwipeTimer			= "Latigazo de cola (Onyxia) TdR",
	NefSwipeTimer			= "Latigazo de cola (Nefarian) TdR",
	OnyBreathTimer			= "Aliento (Onyxia) TdR",
	NefBreathTimer			= "Aliento (Nefarian) TdR"
})

L:SetOptionLocalization({
	OnyTailSwipe			= "Mostrar aviso para $spell:77827 de Onyxia",
	NefTailSwipe			= "Mostrar aviso para $spell:77827 de Nefarian",
	OnyBreath				= "Mostrar aviso para $spell:77826 de Onyxia",
	NefBreath				= "Mostrar aviso para $spell:77826 de Nefarian",
	specWarnCinderMove		= "Mostrar aviso especial para apartarte si te afecta $spell:79339 (5 s antes de la explosión)",
	warnShadowblazeSoon		= "Mostrar aviso previo con cuenta atrás para $spell:81031 (5 s antes, y solo tras el primer grito con tal de que sea preciso)",
	specWarnShadowblazeSoon	= "Mostrar aviso especial previo para $spell:81031 (5 s antes la primera vez, y 1 s antes tras el primer grito con tal de que sea preciso)",
	timerNefLanding			= "Mostrar temporizador para el aterrizaje de Nefarian",
	OnySwipeTimer			= "Mostrar temporizador para el tiempo de reutilización de $spell:77827 de Onyxia",
	NefSwipeTimer			= "Mostrar temporizador para el tiempo de reutilización de $spell:77827 de Nefarian",
	OnyBreathTimer			= "Mostrar temporizador para el tiempo de reutilización de $spell:77826 de Onyxia",
	NefBreathTimer			= "Mostrar temporizador para el tiempo de reutilización de $spell:77826 de Nefarian",
	InfoFrame				= "Mostrar marco de información para $journal:3284",
	SetWater				= "Desactivar automáticamente la opción de cámara de colisión con el agua al iniciar el encuentro (se reactivará automáticamente al terminar el encuentro)",
	SetIconOnCinder			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79339),
	RangeFrame				= "Mostrar marco de distancia (10 m) para $spell:79339 (muestra a todos los jugadores si tienes el perjuicio, o solo a los jugadores con el perjuicio si no estás afectado)"
})

L:SetMiscLocalization({
	NefAoe					= "¡El aire crepita cargado de electricidad!",
	YellPhase2				= "¡Os maldigo, mortales! ¡Ese cruel menosprecio por las posesiones de uno debe ser castigado con fuerza extrema!",
	YellPhase3				= "He intentado ser un buen anfitrión, pero ¡no morís! Es hora de dejarnos de tonterías y simplemente... ¡MATAROS A TODOS!",
	YellShadowBlaze			= "¡Carne a ceniza!",
	ShadowBlazeExact		= "Chispa de llamarada de las Sombras en %d s",
	ShadowBlazeEstimate		= "Chispa de llamarada de las Sombras en breve (unos 5 s)"
})

------------------------
--  Enemigos menores  --
------------------------
L = DBM:GetModLocalization("BWDTrash")

L:SetGeneralLocalization({
	name = "Enemigos menores"
})

--------------------------
--  Halfus Rompevermis  --
--------------------------
L = DBM:GetModLocalization(156)

L:SetOptionLocalization({
	ShowDrakeHealth		= "Mostrar salud de los dragonantes liberados (requiere que la opción de mostrar marco de salud del jefe esté habilitada)"
})

---------------------------
--  Theralion y Valiona  --
---------------------------
L = DBM:GetModLocalization(157)

L:SetOptionLocalization({
	TBwarnWhileBlackout		= "Mostrar aviso para $spell:86369 durante $spell:86788",
	TwilightBlastArrow		= "Mostrar flecha cuando $spell:86369 ocurra cerca de ti",
	RangeFrame				= "Mostrar marco de distancia (10 m)",
	BlackoutShieldFrame		= "Mostrar salud del jefe en una barra durante $spell:86788",
	BlackoutIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(86788),
	EngulfingIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(86622)
})

L:SetMiscLocalization({
	Trigger1				= "Aliento profundo",
	BlackoutTarget			= "Desmayo: %s"
})

-------------------------------
--  Consejo de ascendientes  --
-------------------------------
L = DBM:GetModLocalization(158)

L:SetWarningLocalization({
	specWarnBossLow			= "%s por debajo del 30%% - ¡siguiente fase en breve!",
	SpecWarnGrounded		= "Obtén Toma de tierra",
	SpecWarnSearingWinds	= "Obtén Vientos espirales"
})

L:SetTimerLocalization({
	timerTransition			= "Cambio de fase"
})

L:SetOptionLocalization({
	specWarnBossLow			= "Mostrar aviso especial cuando los jefes estén por debajo del 30% de salud",
	SpecWarnGrounded		= "Mostrar aviso especial cuando no te afecte el perjuicio de $spell:83581 (unos 10 s antes del lanzamiento)",
	SpecWarnSearingWinds	= "Mostrar aviso especial cuando no te afecte el perjuicio de $spell:83500 (unos 10 s antes del lanzamiento)",
	timerTransition			= "Mostrar temporizador para los cambios de fase",
	RangeFrame				= "Mostrar marco de distancia automáticamente cuando sea necesario",
	yellScrewed				= "Gritar cuando te afecten $spell:83099 y $spell:92307 a la vez",
	InfoFrame				= "Mostrar marco de información de jugadores sin $spell:83581 o $spell:83500",
	HeartIceIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82665),
	BurningBloodIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82660),
	LightningRodIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(83099),
	GravityCrushIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(84948),
	FrostBeaconIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92307),
	StaticOverloadIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92067),
	GravityCoreIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92075)
})

L:SetMiscLocalization({
	Quake			= "El suelo bajo tus pies empieza a temblar ominosamente...",
	Thundershock	= "El aire circundante chisporrotea de energía...",
	Switch			= "¡Basta de tonterías!",--"We will handle them!" comes 3 seconds after this one
	Phase3			= "Una exhibición impresionante...",--"BEHOLD YOUR DOOM!" is about 13 seconds after
	Kill			= "Imposible....",
	blizzHatesMe	= "¡Señal de Escarcha y Pararrayos en mí! ¡Apartaos o morid!",--Very bad situation.
	WrongDebuff		= "Sin %s"
})

----------------
--  Cho'gall  --
----------------
L = DBM:GetModLocalization(167)

L:SetOptionLocalization({
	CorruptingCrashArrow	= "Mostrar flecha cuando $spell:81685 ocurra cerca de ti",
	InfoFrame				= "Mostrar marco de información para $journal:3165",
	RangeFrame				= "Mostrar marco de distancia (5 m) para $journal:3165",
	SetIconOnWorship		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(91317)
})

----------------
--  Sinestra  --
----------------
L = DBM:GetModLocalization(168)

L:SetWarningLocalization({
	WarnOrbSoon			= "¡Cercenadora Crepuscular en %d s!",
	SpecWarnOrbs		= "¡Han aparecido los orbes! ¡Cuidado!",
	warnWrackJump		= "%s salta a >%s<",
	warnAggro			= "Jugadores con amenaza (candidatos para orbes): >%s<",
	SpecWarnAggroOnYou	= "¡Tienes amenaza! ¡Cuidado con los orbes!"
})

L:SetTimerLocalization({
	TimerEggWeakening	= "Caparazón Crepuscular desaparece",
	TimerEggWeaken		= "Caparazón Crepuscular se regenera",
	TimerOrbs			= "Cercenadora Crepuscular TdR"
})

L:SetOptionLocalization({
	WarnOrbSoon			= "Mostrar aviso previo para los orbes de $spell:92852 (5 s antes del lanzamiento y tras cada segundo; puede resultar molesto)",
	warnWrackJump		= "Anunciar objetivos de $spell:89421 tras cada salto",
	warnAggro			= "Anunciar jugadores con amenaza cuando aparecen los orbes (posibles objetivos de los orbes)",
	SpecWarnAggroOnYou	= "Mostrar anuncio especial si tienes amenaza cuando aparecen los orbes (posibles objetivos de los orbes)",
	SpecWarnOrbs		= "Mostrar aviso especial cuando aparezcan los orbes",
	TimerEggWeakening	= "Mostrar temporizador para cuando desaparezca $spell:87654",
	TimerEggWeaken		= "Mostrar temporizador para cuando se regenere $spell:87654",
	TimerOrbs			= "Mostrar temporizador para siguientes orbes (estimación; puede no ser preciso)",
	SetIconOnOrbs		= "Poner iconos en jugadores con amenaza cuando aparecen los orbes (posibles objetivos de los orbes)",
	InfoFrame			= "Mostrar marco de información de jugadores con amenaza"
})

L:SetMiscLocalization({
	YellDragon			= "¡Comed, hijos! ¡Alimentaos de sus magros cuerpos!",
	YellEgg				= "¿Confundes esto con debilidad? ¡Insensato!",
	HasAggro			= "tiene amenaza"
})

------------------------
--  Enemigos menores  --
------------------------
L = DBM:GetModLocalization("BoTrash")

L:SetGeneralLocalization({
	name =	"Enemigos menores"
})

----------------------------
-- El Cónclave del Viento --
----------------------------
L = DBM:GetModLocalization(154)

L:SetWarningLocalization({
	warnSpecial			= "Céfiro, Huracán y Tormenta de granizo activados",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial		= "¡Facultades especiales activas!",
	warnSpecialSoon		= "¡Facultades especiales en 10 s!"
})

L:SetTimerLocalization({
	timerSpecial		= "Facultades especiales TdR",
	timerSpecialActive	= "Facultades especiales activas"
})

L:SetOptionLocalization({
	warnSpecial			= "Mostrar aviso cuando se lancen $spell:84638, $spell:84643 y $spell:84644",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial		= "Mostrar aviso especial cuando se lancen las facultades especiales",
	timerSpecial		= "Mostrar temporizador para el tiempo de reutilización de las facultades especiales",
	timerSpecialActive	= "Mostrar temporizador para la duración de las facultades especiales",
	warnSpecialSoon		= "Mostrar aviso previo 10 s antes de las facultades especiales",
	OnlyWarnforMyTarget	= "Mostrar solo avisos y temporizadores para el objetivo y foco actuales (oculta el resto, incluso el de inicio de encuentro)"
})

L:SetMiscLocalization({
	gatherstrength	= "empieza a extraer fuerza"
})

-------------
-- Al'Akir --
-------------
L = DBM:GetModLocalization(155)

L:SetTimerLocalization({
	TimerFeedback 	= "Rebote (%d)"
})

L:SetOptionLocalization({
	LightningRodIcon= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(89668),
	TimerFeedback	= "Mostrar temporizador para la duración de $spell:87904",
	RangeFrame		= "Mostrar marco de distancia (20 m) cuando estés afectado por $spell:89668"
})

-----------------
-- Beth'tilac --
-----------------
L= DBM:GetModLocalization(192)

L:SetMiscLocalization({
	EmoteSpiderlings 	= "¡Las arañitas emergen de su nido!"
})

---------------------
-- Lord Piroclasto --
---------------------
L= DBM:GetModLocalization(193)

---------------
-- Alysrazor --
---------------
L= DBM:GetModLocalization(194)

L:SetWarningLocalization({
	WarnPhase			= "Fase %d",
	WarnNewInitiate		= "Iniciado de garfas llameantes (%s)"
})

L:SetTimerLocalization({
	TimerPhaseChange	= "Fase %d",
	TimerHatchEggs		= "Siguientes huevos",
	timerNextInitiate	= "Siguiente iniciado (%s)"
})

L:SetOptionLocalization({
	WarnPhase			= "Mostrar aviso especial para cambios de fase",
	WarnNewInitiate		= "Mostrar aviso cuando aparezca un Iniciado de garfas llameantes",
	timerNextInitiate	= "Mostrar temporizador para el siguiente Iniciado de garfas llameantes",
	TimerPhaseChange	= "Mostrar temporizador para el cambio de fase",
	TimerHatchEggs		= "Mostrar temporizador para la eclosión de huevos"
})

L:SetMiscLocalization({
	YellPull		= "¡Mortales, ahora sirvo a un nuevo amo!",
	YellPhase2		= "¡Estos cielos son MÍOS!",
	LavaWorms		= "¡Gusanos de lava ígneos surgen del suelo!",--Might use this one day if i feel it needs a warning for something. Or maybe pre warning for something else (like transition soon)
	East			= "este",
	West			= "oeste",
	Both			= "ambos"
})

-------------
-- Shannox --
-------------
L= DBM:GetModLocalization(195)

---------------------------------------
-- Baleroc, el Guardián de la Puerta --
---------------------------------------
L= DBM:GetModLocalization(196)

L:SetWarningLocalization({
	warnStrike	= "%s (%d)"
})

L:SetTimerLocalization({
	timerStrike			= "Siguiente %s",
	TimerBladeActive	= "%s",
	TimerBladeNext		= "Siguiente hoja"
})

L:SetOptionLocalization({
	ResetShardsinThrees	= "Reiniciar contador de $spell:99259 en secuencias de 3 s (25 jugadores) ó 2 s (10 jugadores)",
	warnStrike			= "Mostrar aviso para $spell:99353 y $spell:99351",
	timerStrike			= "Mostrar temporizador para el siguiente $spell:99353 o $spell:99351",
	TimerBladeActive	= "Mostrar temporizador para la duración de la hoja activa",
	TimerBladeNext		= "Mostrar temporizador para el siguiente cambio de hoja"
})

---------------------------
-- Mayordomo Corzocelada --
---------------------------
L= DBM:GetModLocalization(197)

L:SetTimerLocalization({
	timerNextSpecial	= "Siguiente %s (%d)"
})

L:SetOptionLocalization({
	timerNextSpecial			= "Mostrar temporizador para la siguiente habilidad especial",
	RangeFrameSeeds				= "Mostrar marco de distancia (12 m) para $spell:98450",
	RangeFrameCat				= "Mostrar marco de distancia (10 m) para $spell:98374"
})

--------------
-- Ragnaros --
--------------
L= DBM:GetModLocalization(198)

L:SetWarningLocalization({
	warnRageRagnarosSoon	= "%s en %s en 5 s",--Spellname on targetname
	warnSplittingBlow		= "%s en %s",--Spellname in Location
	warnEngulfingFlame		= "%s en %s",--Spellname in Location
	warnEmpoweredSulf		= "%s en 5 s"--The spell has a 5 second channel, but tooltip doesn't reflect it so cannot auto localize
})

L:SetTimerLocalization({
	timerRageRagnaros		= "%s en %s",--Spellname on targetname
	TimerPhaseSons			= "Acaba el intermedio"--Revisar
})

L:SetOptionLocalization({
	warnRageRagnarosSoon		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.prewarn:format(101109),
	warnSplittingBlow			= "Mostrar avisos de ubicación para $spell:98951",
	warnEngulfingFlame			= "Mostrar avisos de ubicación para $spell:99171 en dificultad normal",
	warnEngulfingFlameHeroic	= "Mostrar avisos de ubicación para $spell:99171 en dificultad heroica",
	warnSeedsLand				= "Mostrar temporizador y aviso para $spell:98520 en función de cuando aterricen las semillas en lugar de cuando ocurra el lanzamiento",
	warnEmpoweredSulf			= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.cast:format(100604),
	timerRageRagnaros			= DBM_CORE_L.AUTO_TIMER_OPTIONS.cast:format(101109),
	TimerPhaseSons				= "Mostrar temporizador de duración para los intermedios de Hijos de la llama",
	InfoHealthFrame				= "Mostrar marco de información de salud (por debajo de 100mil)",
	MeteorFrame					= "Mostrar marco de información de objetivos de $spell:99849",
	AggroFrame					= "Mostrar marco de información de jugadores sin amenaza durante $journal:2647"
})

L:SetMiscLocalization({
	East				= "Este",
	West				= "Oeste",
	Middle				= "Medio",
	North				= "Norte",
	South				= "Sur",
	HealthInfo			= "Por debajo de 100mil de salud",
	HasNoAggro			= "Sin amenaza",
	MeteorTargets		= "¡Meteoritos!",--Keep rollin' rollin' rollin' rollin'.
	TransitionEnded1	= "¡Basta! Yo terminaré esto.",--More reliable then adds method.
	TransitionEnded2	= "Sulfuras será vuestro fin.",
	TransitionEnded3	= "¡De rodillas, mortales! Esto termina ahora.",
	Defeat				= "¡Pronto!... Habéis venido demasiado pronto...",
	Phase4				= "Demasiado pronto..."
})

------------------------
--  Enemigos menores  --
------------------------
L = DBM:GetModLocalization("FirelandsTrash")

L:SetGeneralLocalization({
	name = "Enemigos menores"
})

----------------
--  Volcanus  --
----------------
L = DBM:GetModLocalization("Volcanus")

L:SetGeneralLocalization({
	name = "Volcanus"
})

L:SetTimerLocalization({
	timerStaffTransition	= "Fin del intermedio"
})

L:SetOptionLocalization({
	timerStaffTransition	= "Mostrar temporizador para el cambio de fase"
})

L:SetMiscLocalization({
	StaffEvent			= "¡Cuando la toca %S+, la rama de Nordrassil reacciona de forma violenta!",--Reg expression pull match
	StaffTrees			= "¡Antárboles ardientes emergen del suelo para ayudar al protector!",--Might add a spec warning for this later.
	StaffTransition		= "¡Las llamas que consumen al protector atormentado se extinguen!"
})

----------------
--  Thyrinar  --
----------------
L = DBM:GetModLocalization("NexusLegendary")

L:SetGeneralLocalization({
	name = "Thyrinar"
})

-------------
-- Morchok --
-------------
L= DBM:GetModLocalization(311)

L:SetWarningLocalization({
	KohcromWarning	= "%s: %s"--Bossname, spellname. At least with this we can get boss name from casts in this one, unlike a timer started off the previous bosses casts.
})

L:SetTimerLocalization({
	KohcromCD		= "Kohcrom imita %s",--Universal single local timer used for all of his mimick timers
})

L:SetOptionLocalization({
	KohcromWarning	= "Mostrar aviso para las facultades imitadas por $journal:4262",
	KohcromCD		= "Mostrar temporizador para la siguiente habilidad imitada por $journal:4262",
	RangeFrame		= "Mostrar marco de distancia (5 m) para el logro 'No te pegues a mí'"
})

L:SetMiscLocalization({
})

--------------------------------
-- Señor de la guerra Zon'ozz --
--------------------------------
L= DBM:GetModLocalization(324)

L:SetOptionLocalization({
	ShadowYell			= "Gritar cuando te afecte $spell:103434 (dificultad heroica)",
	CustomRangeFrame	= "Opciones del marco de distancia (dificultad heroica)",
	Never				= "Desactivado",
	Normal				= "Marco de distancia normal",
	DynamicPhase2		= "Perjuicio durante la fase 2",
	DynamicAlways		= "Perjuicio durante todo el combate"
})

L:SetMiscLocalization({
	voidYell	= "Gul'kafh an'qov N'Zoth."--Start translating the yell he does for Void of the Unmaking cast, the latest logs from DS indicate blizz removed the event that detected casts. sigh.
})

-------------------------
-- Yor'sahj el Velador --
-------------------------
L= DBM:GetModLocalization(325)

L:SetWarningLocalization({
	warnOozesHit	= "%s absorbe %s"
})

L:SetTimerLocalization({
	timerOozesActive	= "Glóbulos atacables",
	timerOozesReach		= "Glóbulos llegan a Yor'sahj"
})

L:SetOptionLocalization({
	warnOozesHit		= "Anunciar cuando los glóbulos lleguen al jefe",
	timerOozesActive	= "Mostrar temporizador para cuando los glóbulos se vuelvan atacables",
	timerOozesReach		= "Mostrar temporizador para cuando los glóbulos lleguen a a Yor'sahj",
	RangeFrame			= "Mostrar marco de distancia (4 m) para $spell:104898 (dificultad normal/heroica)"
})

L:SetMiscLocalization({
	Black			= "|cFF424242negro|r",
	Purple			= "|cFF9932CDpúrpura|r",
	Red				= "|cFFFF0404rojo|r",
	Green			= "|cFF088A08verde|r",
	Blue			= "|cFF0080FFazul|r",
	Yellow			= "|cFFFFA901amarillo|r"
})

--------------------------------
-- Hagara la Vinculatormentas --
--------------------------------
L= DBM:GetModLocalization(317)

L:SetWarningLocalization({
	WarnPillars				= "%s: %d restantes",
	warnFrostTombCast		= "%s en 8 s"
})

L:SetTimerLocalization({
	TimerSpecial			= "Primera habilidad especial"
})

L:SetOptionLocalization({
	WarnPillars				= "Anunciar el número de $journal:3919 y $journal:4069 restantes",
	TimerSpecial			= "Mostrar temporizador para el primer lanzamiento de habilidad especial",
	RangeFrame				= "Mostrar marco de distancia para $spell:105269 (3 m) y $journal:4327 (10 m)",
	AnnounceFrostTombIcons	= "Anunciar iconos de los objetivos de $spell:104451 en el chat de banda (requiere líder o ayudante)",
	warnFrostTombCast		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.cast:format(104448),
	SetIconOnFrostTomb		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(104451),
	SetIconOnFrostflake		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(109325),
	SpecialCount			= "Reproducir sonido de cuenta atrás para $spell:105256 y $spell:105465",
	SetBubbles				= "Desactivar bocadillos de chat automáticamente cuando $spell:104451 esté disponible (se restaurarán cuando termine el encuentro)"
})

L:SetMiscLocalization({
	TombIconSet				= "Icono {rt%d} para Tumba de hielo en %s"
})

---------------
-- Ultraxion --
---------------
L= DBM:GetModLocalization(331)

L:SetWarningLocalization({
	specWarnHourofTwilightN		= "%s (%d) en 5 s"--spellname Count
})

L:SetTimerLocalization({
	TimerCombatStart	= "Ultraxion atacable"
})

L:SetOptionLocalization({
	TimerCombatStart	= "Mostrar temporizador para el diálogo de Ultraxion",
	ResetHoTCounter		= "Patrón del contador de Hora del Crepúsculo",--$spell doesn't work in this function apparently so use typed spellname for now.
	Never				= "No reiniciar nunca",
	ResetDynamic		= "Reiniciar en secuencias de 3 (heroica) o 2 (normal)",
	Reset3Always		= "Reiniciar siempre en secuencias de 3",
	SpecWarnHoTN		= "Mostrar aviso especial cuando falten 5 s para Hora del Crepúsculo (si el patrón del contador está configurado en 'No reiniciar nunca', se ajustará al patrón de secuencias de 3)",
	One					= "1 (ej. 1 4 7)",
	Two					= "2 (ej. 2 5)",
	Three				= "3 (ej. 3 6)"
})

L:SetMiscLocalization({
	Pull				= "Percibo que se avecina una gran alteración del equilibrio. ¡Su caos inunda mi mente!"
})

------------------
-- Cuerno Negro --
------------------
L= DBM:GetModLocalization(332)

L:SetWarningLocalization({
	SpecWarnElites	= "¡Élites Crepusculares!"
})

L:SetTimerLocalization({
	TimerAdd			= "Siguientes élites"
})

L:SetOptionLocalization({
	TimerAdd			= "Mostrar temporizador para los siguientes élites Crepusculares",
	SpecWarnElites		= "Mostrar aviso especial cuando aparezcan los élites Crepusculares",
	SetTextures			= "Desactivar automáticamente la opción gráfica de texturas proyectadas durante la fase 1 (se restaurará al iniciarse la fase 2)"
})

L:SetMiscLocalization({
	SapperEmote			= "¡Un draco desciende para dejar a un zapador Crepuscular en la cubierta!",
	GorionaRetreat			= "grita de dolor y se retira al remolino de nubes."
})

----------------------------
-- Espinazo de Alamuerte  --
----------------------------
L= DBM:GetModLocalization(318)

L:SetWarningLocalization({
	warnSealArmor			= "%s",
	SpecWarnTendril			= "¡Ponte a salvo!"
})

L:SetOptionLocalization({
	warnSealArmor			= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.cast:format(105847),
	SpecWarnTendril			= "Mostrar aviso especial cuando no tengas el perjuicio de $spell:105563",
	InfoFrame				= "Mostrar marco de información de jugadores sin $spell:105563",
	SetIconOnGrip			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(105490),
	ShowShieldInfo			= "Mostrar barra de absorción para $spell:105479 (ignora la opción de marco de salud del jefe)"
})

L:SetMiscLocalization({
	Pull			= "¡Las placas! ¡Se está deshaciendo! ¡Destrozad las placas y tendremos una oportunidad de derribarlo!",
	NoDebuff		= "Sin %s",
	PlasmaTarget	= "Plasma ardiente: %s",
	DRoll			= "a punto de girar",
	DLevels			= "se estabiliza."
})

--------------------------
-- Locura de Alamuerte  --
--------------------------
L= DBM:GetModLocalization(333)

L:SetOptionLocalization({
	RangeFrame			= "Mostrar marco de distancia dinámico según el estado del perjuicio $spell:108649 (dificultad heroica)",
	SetIconOnParasite	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(108649)
})

L:SetMiscLocalization({
	Pull				= "No habéis hecho nada. Destruiré vuestro mundo."
})

------------------------
--  Enemigos menores  --
------------------------
L = DBM:GetModLocalization("DSTrash")

L:SetGeneralLocalization({
	name =	"Enemigos menores"
})

L:SetWarningLocalization({
	DrakesLeft			= "Acometedores Crepusculares restantes: %d"
})

L:SetTimerLocalization({
	timerRoleplay		= "Diálogo",
	TimerDrakes			= "%s"--spellname from mod
})

L:SetOptionLocalization({
	DrakesLeft			= "Anunciar el número de Acometedores Crepusculares restantes",
	TimerDrakes			= "Mostrar temporizador para $spell:109904"
})

L:SetMiscLocalization({
	firstRP				= "¡Alabados sean los Titanes, han regresado!",
	UltraxionTrash		= "Me alegra volver a verte, Alexstrasza. He estado ocupado en mi ausencia.",
	UltraxionTrashEnded = "Simples crías, experimentos, un medio para un fin mayor. Verás el resultado de las investigaciones de mi nidada."
})
