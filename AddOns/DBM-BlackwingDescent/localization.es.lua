if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

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
	AcquiringTargetIcon			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(79501),
	ConductorIcon				= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(79888),
	ShadowConductorIcon			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(92053),
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
	TrackingIcon			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(78092)
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
	SetIconOnSlime	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(82935),
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
	FlashFreezeIcon		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(77699),
	BitingChillIcon		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(77760),
	ConsumingFlamesIcon	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(77786)
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
	SetIconOnCinder			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(79339),
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
