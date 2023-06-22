if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then
	return
end
local L

-------------------------
-- Kargath Garrafilada --
-------------------------
L = DBM:GetModLocalization(1128)

L:SetTimerLocalization({
	timerSweeperCD	= "Next Arena Sweeper"
})

L:SetOptionLocalization({
	timerSweeperCD	= DBM_CORE_L.AUTO_TIMER_OPTIONS.next:format(177776)
})

------------
-- Tectus --
------------
L = DBM:GetModLocalization(1195)

L:SetMiscLocalization({
	pillarSpawn	= "¡ALZAOS, MONTAÑAS!"
})

------------------
-- Frondaespora --
------------------
L = DBM:GetModLocalization(1196)

L:SetOptionLocalization({
	InterruptCounter	= "Patrón de reinicio del contador de Descomposición",
	Two					= "Cada dos lanzamientos",
	Three				= "Cada tres lanzamientos",
	Four				= "Cada cuatro lanzamientos"
})

---------------------
-- Gemelos ogrones --
---------------------
L = DBM:GetModLocalization(1148)

L:SetOptionLocalization({
	PhemosSpecial		= "Reproducir sonido de cuenta atrás para los tiempos de reutilización de Femos",
	PolSpecial			= "Reproducir sonido de cuenta atrás para los tiempos de reutilización de Pol",
	PhemosSpecialVoice	= "Reproducir alertas de voz del paquete de voces seleccionado para las facultades de Femos",
	PolSpecialVoice		= "Reproducir alertas de voz del paquete de voces seleccionado para las facultades de Pol"
})

-------------
-- Ko'ragh --
-------------
L = DBM:GetModLocalization(1153)

L:SetWarningLocalization({
	specWarnExpelMagicFelFades	= "Expulsar magia: Vil expirando en 5 s - ¡vuelve a tu posición inicial!"
})

L:SetOptionLocalization({
	specWarnExpelMagicFelFades	= "Mostrar aviso especial para volver al punto de inicio cuando $spell:172895 esté a punto de expirar"
})

L:SetMiscLocalization({
	supressionTarget1	= "¡Os aplastaré!",
	supressionTarget2	= "¡Silencio!",
	supressionTarget3	= "¡Callad!",
	supressionTarget4	= "¡Os partiré en dos!"
})

-----------------------
-- Imperador Mar'gok --
-----------------------
L = DBM:GetModLocalization(1197)

L:SetTimerLocalization({
	timerNightTwistedCD	= "Siguientes fieles"
})

L:SetOptionLocalization({
	GazeYellType		= "Gritos para Mirada del abismo",
	Countdown			= "Cuenta atrás hasta que expire",
	Stacks				= "Con cada acumulación",
	timerNightTwistedCD	= "Mostrar temporizador para los siguientes Fieles alterados por las sombras",
})

L:SetMiscLocalization({
	BrandedYell		= "Marca (%d) %d m",
	GazeYell		= "Mirada expirando en %d",
	GazeYell2		= "Mirada (%d) en %s",
	PlayerDebuffs	= "Más cercano para Visión"
})

------------------------
--  Enemigos menores  --
------------------------
L = DBM:GetModLocalization("HighmaulTrash")

L:SetGeneralLocalization({
	name	= "Enemigos menores"
})

-----------
-- Gruul --
-----------
L = DBM:GetModLocalization(1161)

L:SetOptionLocalization({
	MythicSoakBehavior	= "Patrón de agrupamiento para Tajo infernal",
	ThreeGroup			= "3 grupos, 1 acumulación",
	TwoGroup			= "2 grupos, 2 acumulaciones"
})

----------------
-- Tragamenas --
----------------
L = DBM:GetModLocalization(1202)

L:SetOptionLocalization({
	InterruptBehavior	= "Patrón de interrupciones para avisos especiales",
	Smart				= "Avisos en función del número de trombas",
	Fixed				= "Avisos siempre en secuencia de 5 ó 3 trombas (aunque no coincida con las usadas)"
})

---------------------------
-- El Horno de Fundición --
---------------------------
L = DBM:GetModLocalization(1154)

L:SetWarningLocalization({
	warnRegulators			= "Reguladores de calor restantes: %d",
	warnBlastFrequency		= "Frecuencia de Reventar aumentada: aprox. cada %d s",
	specWarnTwoVolatileFire	= "¡Doble Fuego volátil en ti!"
})

L:SetOptionLocalization({
	warnRegulators			= "Anunciar el número de reguladores de calor restantes",
	warnBlastFrequency		= "Anunciar cada vez que aumente la frecuencia de $spell:155209",
	specWarnTwoVolatileFire	= "Mostrar aviso especial cuando te afecten dos $spell:176121 a la vez",
	InfoFrame				= "Mostrar marco de información para $spell:155192 y $spell:155196",
	VFYellType2				= "Gritos para Fuego volátil (dificultad mítica)",
	Countdown				= "Cuenta atrás hasta que expire",
	Apply					= "Solo al aplicarse"
})

L:SetMiscLocalization({
	heatRegulator	= "Regulador de calor",
	Regulator		= "Regulador %d",--Can't use above, too long for infoframe
	bombNeeded		= "%d bomba(s)"
})

--------------------------
-- Operador Thogar --
--------------------------
L = DBM:GetModLocalization(1147)

L:SetWarningLocalization({
	specWarnSplitSoon	= "Separación de banda en 10 s"
})

L:SetOptionLocalization({
	specWarnSplitSoon	= "Mostrar aviso especial 10 s antes de la separación de banda",
	InfoFrameSpeed		= "Marco de información de trenes",
	Immediately			= "Mostrar en cuanto se abran las puertas",
	Delayed				= "Mostrar en cuanto se vaya el tren anterior",
	HudMapUseIcons		= "Usar iconos de banda para el indicador en pantalla en lugar de círculos verdes",
	TrainVoiceAnnounce	= "Alertas de voz para los trenes",
	LanesOnly			= "Solo anunciar vías",
	MovementsOnly		= "Solo anunciar movimientos (dificultad mítica)",
	LanesandMovements	= "Anunciar vías y movimientos (dificultad mítica)"
})

L:SetMiscLocalization({
	Train			= "Tren",
	lane			= "Vía",
	oneTrain		= "1 vía aleatoria: Tren",
	oneRandom		= "en 1 vía aleatoria",
	threeTrains		= "3 vías aleatorias: Tren",
	threeRandom		= "en 3 vías aleatorias",
	helperMessage	= "Este encuentro se puede simplificar en gran medida con el addon 'Thogar Assist' o paquetes de voces de DBM diseñados para anunciar trenes, todos disponibles en Curse."
})

-----------------------------
-- Las Doncellas de Hierro --
-----------------------------
L = DBM:GetModLocalization(1203)

L:SetWarningLocalization({
	specWarnReturnBase	= "¡Volved a tierra!"
})

L:SetOptionLocalization({
	specWarnReturnBase	= "Mostrar aviso especial cuando los jugadores del barco puedan volver a salvo a tierra",
	filterBladeDash3	= "Ocultar aviso especial para $spell:155794 al estar afectado por $spell:170395",
	filterBloodRitual3	= "Ocultar aviso especial para $spell:158078 al estar afectado por $spell:170405"
})

L:SetMiscLocalization({
	shipMessage		= "se prepara para controlar el cañón principal de El Acorator!",
	EarlyBladeDash	= "Demasiado lentos."
})

----------------
-- Puño Negro --
----------------
L = DBM:GetModLocalization(959)

L:SetWarningLocalization({
	specWarnMFDPosition		= "Posición para marcado: %s",
	specWarnSlagPosition	= "Posición para bomba: %s"
})

L:SetOptionLocalization({
	PositionsAllPhases	= "Asignar posiciones para $spell:156096 mediante gritos en todas las fases (en lugar de solo en la fase 3)",
	InfoFrame			= "Mostrar marco de información para $spell:155992 y $spell:156530"
})

L:SetMiscLocalization({
	customMFDSay	= "Marcado %s en %s",
	customSlagSay	= "Bomba %s on %s"
})

------------------------
--  Enemigos menores  --
------------------------
L = DBM:GetModLocalization("BlackrockFoundryTrash")

L:SetGeneralLocalization({
	name	= "Enemigos menores"
})

-----------------------------
-- Asalto a Fuego Infernal --
-----------------------------
L = DBM:GetModLocalization(1426)

L:SetTimerLocalization({
	timerSiegeVehicleCD	= "Siguiente vehículo: %s",
})

L:SetOptionLocalization({
	timerSiegeVehicleCD = "Mostrar temporizador para el siguiente vehículo"
})

L:SetMiscLocalization({
	AddsSpawn1	= "¡Paso, que voy ardiendo!",--Blizzard seems to have disabled these
	AddsSpawn2	= "¡Bomba va!",--Blizzard seems to have disabled these
	BossLeaving	= "Volveré..."
})

------------------------------------
-- Alto Consejo de Fuego Infernal --
------------------------------------
L = DBM:GetModLocalization(1432)

L:SetWarningLocalization({
	reapDelayed	= "Segar tras Rostro de pesadilla"
})

---------------------
-- Kilrogg Mortojo --
---------------------
L = DBM:GetModLocalization(1396)

L:SetMiscLocalization({
	BloodthirstersSoon	= "¡Hermanos, cumplid vuestro destino!"
})

--------------
-- Sanguino --
--------------
L = DBM:GetModLocalization(1372)

L:SetTimerLocalization({
	SoDDPS2		= "Siguiente Sombra (%s)",
	SoDTank2	= "Siguiente Sombra (%s)",
	SoDHealer2	= "Siguiente Sombra (%s)"
})

L:SetOptionLocalization({
	SoDDPS2			= "Mostrar temporizador para la siguiente $spell:179864 que afecte a los DPS",
	SoDTank2		= "Mostrar temporizador para la siguiente $spell:179864 que afecte a los tanques",
	SoDHealer2		= "Mostrar temporizador para la siguiente $spell:179864 que afecte a los sanadores",
	ShowOnlyPlayer	= "Mostrar indicadores en pantalla para $spell:179909 solo si eres uno de los jugadores afectados"
})

--------------------------------
-- Señor de las Sombras Iskar --
--------------------------------
L = DBM:GetModLocalization(1433)

L:SetWarningLocalization({
	specWarnThrowAnzu	=	"¡Pasa el Ojo de Anzu a %s!"
})

L:SetOptionLocalization({
	specWarnThrowAnzu	=	"Mostrar aviso especial cuando debas pasar el $spell:179202"
})

----------------------
-- Señor vil Zakuun --
----------------------
L = DBM:GetModLocalization(1391)

L:SetOptionLocalization({
	SeedsBehavior	= "Patrón de gritos de la banda (requiere líder)",
	Iconed			= "Estrella, Círculo, Diamante, Triángulo, Luna. Para marcadores del mundo.",--Default
	Numbered		= "1, 2, 3, 4, 5. Para posiciones numeradas.",
	DirectionLine	= "Izquierda, Medio izquierda, Medio, Medio derecha, Derecha. Para uso general.",
	FreeForAll		= "Libre. No asigna ninguna posición, pero avisa por gritos."
})

L:SetMiscLocalization({
	DBMConfigMsg	= "Configuración de semillas establecida a %s para que coincida con la del líder de banda.",
	BWConfigMsg		= "El líder de banda está usando BigWigs. Configuración establecida automáticamente a 'numerada'."
})

----------------
-- Xhul'horac --
----------------
L = DBM:GetModLocalization(1447)

L:SetOptionLocalization({
	ChainsBehavior	= "Patrón de avisos de cadenas. El temporizador se ajustará en función del patrón.",
	Cast			= "Solo al objetivo original cuando se inicie el lanzamiento",
	Applied			= "Solo a los objetivos afectados al terminar el lanzamiento",
	Both			= "Objetivo original al iniciarse el lanzamiento, y resto de objetivos cuando termine"
})

-------------------------
-- Socrethar el Eterno --
-------------------------
L = DBM:GetModLocalization(1427)

L:SetOptionLocalization({
	InterruptBehavior	= "Patrón de interrupciones de la banda (requiere líder)",
	Count3Resume		= "Rotación de 3 jugadores que se mantiene cuando desaparece la barrera",--Default
	Count3Reset			= "Rotación de 3 jugadores que se reinicia cuando desaparece la barrera",
	Count4Resume		= "Rotación de 4 jugadores que se mantiene cuando desaparece la barrera",
	Count4Reset			= "Rotación de 4 jugadores que se reinicia cuando desaparece la barrera"
})

---------------
-- Mannoroth --
---------------
L = DBM:GetModLocalization(1395)

L:SetOptionLocalization({
	CustomAssignWrath	= "Poner iconos de $spell:186348 según el rol de los jugadores (requiere líder; puede causar conflictos con BigWigs o versiones antiguas de DBM)"
})

L:SetMiscLocalization({
	felSpire	= "comienza a potenciar la cumbre vil!"
})

----------------
-- Archimonde --
----------------
L = DBM:GetModLocalization(1438)

L:SetWarningLocalization({
	specWarnBreakShackle	= "Tormento encadenado - ¡Rompe el %s!"
})

L:SetOptionLocalization({
	specWarnBreakShackle	= "Mostrar aviso especial cuando te afecte $spell:184964. Este aviso asigna un orden para minimizar el daño sufrido.",
	ExtendWroughtHud3		= "Extender las líneas del indicador de $spell:185014 más allá del objetivo (puede reducir la precisión de la línea)",
	AlternateHudLine		= "Usar textura alternativa para las líneas del indicador en pantalla de $spell:185014",
	NamesWroughtHud			= "Mostrar nombres de jugadores en el indicador en pantalla de $spell:185014",
	FilterOtherPhase		= "Ocultar avisos de eventos que no ocurran en tu fase actual",
	MarkBehavior			= "Patrón de gritos de la banda para Marca de la Legión (requiere líder)",
	Numbered				= "Estrella, Círculo, Diamante, Triángulo. Para marcadores del mundo.",--Default
	LocSmallFront			= "Melé (Estrella/Círculo), Distancia (Diamante/Triángulo). Perj. cortos a melé.",
	LocSmallBack			= "Melé (Estrella/Círculo), Distancia (Diamante/Triángulo). Perj. cortos a distancia.",
	NoAssignment			= "Deshabilitar todos los avisos e indicadores para toda la banda.",
	overrideMarkOfLegion	= "Impedir que el líder de banda cambie tu patrón de Marca de la Legión (solo para expertos seguros de que su configuración no entrará en conflicto con la del líder)"
})

L:SetMiscLocalization({
	phase2point5	= "Contemplad las tropas de la Legión Ardiente y asumid lo fútil que es vuestra resistencia.",--3 seconds faster than CLEU, used as primary, slower CLEU secondary
	First			= "primero",
	Second			= "segundo",
	Third			= "tercero",
	Fourth			= "cuarto",--Just in case, not sure how many targets in 30 man raid
	Fifth			= "quinto"--Just in case, not sure how many targets in 30 man raid
})

------------------------
--  Enemigos menores  --
------------------------
L = DBM:GetModLocalization("HellfireCitadelTrash")

L:SetGeneralLocalization({
	name	=	"Enemigos menores"
})
