if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

---------------------------------
-- Archavon el Vigía de Piedra --
---------------------------------
L = DBM:GetModLocalization("Archavon")

L:SetGeneralLocalization({
	name = "Archavon el Vigía de Piedra"
})

L:SetWarningLocalization({
	WarningGrab	= "Archavon agarra a >%s<"
})

L:SetTimerLocalization({
	ArchavonEnrage	= "Rabia (Archavon)"
})

L:SetMiscLocalization({
	TankSwitch	= "%%s se abalanza sobre (%S+)"
})

L:SetOptionLocalization({
	WarningGrab		= "Anunciar objetivo de $spell:58666",
	ArchavonEnrage	= "Mostrar temporizador para $spell:26662"
})

------------------------------------
-- Emalon el Vigía de la Tormenta --
------------------------------------
L = DBM:GetModLocalization("Emalon")

L:SetGeneralLocalization{
	name = "Emalon el Vigía de la Tormenta"
}

L:SetTimerLocalization{
	timerMobOvercharge	= "Explosión de Sobrecarga",
	EmalonEnrage		= "Rabia (Emalon)"
}

L:SetOptionLocalization{
	timerMobOvercharge	= "Mostrar temporizador para la explosión del Esbirro tempestuoso afectado por Sobrecarga",
	EmalonEnrage		= "Mostrar temporizador para $spell:26662"
}

------------------------------------
-- Koralon el Vigía de las Llamas --
------------------------------------
L = DBM:GetModLocalization("Koralon")

L:SetGeneralLocalization{
	name = "Koralon el Vigía de las Llamas"
}

L:SetTimerLocalization{
	KoralonEnrage	= "Rabia (Koralon)"
}

L:SetOptionLocalization{
	KoralonEnrage		= "Mostrar temporizador para $spell:26662"
}

L:SetMiscLocalization{
	Meteor	= "¡%s lanza Puños meteóricos!"
}

-------------------------------
-- Toravon el Vigía de Hielo --
-------------------------------
L = DBM:GetModLocalization("Toravon")

L:SetGeneralLocalization{
	name = "Toravon el Vigía de Hielo"
}

L:SetTimerLocalization{
	ToravonEnrage	= "Rabia (Toravon)"
}

L:SetMiscLocalization{
	ToravonEnrage	= "Mostrar temporizador para $spell:26662"
}

-----------------
-- Anub'Rekhan --
-----------------
L = DBM:GetModLocalization("Anub'Rekhan")

L:SetGeneralLocalization({
	name = "Anub'Rekhan"
})

L:SetWarningLocalization({
	SpecialLocust		= "Enjambre de langostas",
	WarningLocustFaded	= "Enjambre de langostas ha terminado"
})

L:SetOptionLocalization({
	SpecialLocust		= "Mostrar aviso especial para $spell:28785",
	WarningLocustFaded	= "Mostrar aviso cuando termine $spell:28785",
	ArachnophobiaTimer	= "Mostrar temporizador para el logro 'Aracnofobia'"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "Logro: Aracnofobia",
	Pull1				= "¡Eso, corred! ¡Así la sangre circula más rápido!",
	Pull2				= "Solo un bocado..."
})

-------------------------
-- Gran Viuda Faerlina --
-------------------------
L = DBM:GetModLocalization("Faerlina")

L:SetGeneralLocalization({
	name = "Gran Viuda Faerlina"
})

L:SetWarningLocalization({
	WarningEmbraceExpire	= "Abrazo de la viuda expirando en 5 s",
	WarningEmbraceExpired	= "Abrazo de la viuda ha expirado"
})

L:SetOptionLocalization({
	WarningEmbraceExpire	= "Mostrar aviso previo para cuando expire Abrazo de la viuda",
	WarningEmbraceExpired	= "Mostrar aviso cuando expire Abrazo de la viuda"
})

L:SetMiscLocalization({
	Pull					= "¡Arrodíllate ante mí, sabandija!"--Not actually pull trigger, but often said on pull
})

-------------
-- Maexxna --
-------------
L = DBM:GetModLocalization("Maexxna")

L:SetGeneralLocalization({
	name = "Maexxna"
})

L:SetWarningLocalization({
	WarningSpidersSoon	= "Arañitas de Maexxna en 5 s",
	WarningSpidersNow	= "Arañitas de Maexxna"
})

L:SetTimerLocalization({
	TimerSpider	= "Siguientes arañitas"
})

L:SetOptionLocalization({
	WarningSpidersSoon	= "Mostrar aviso previo para cuando aparezcan Arañitas de Maexxna",
	WarningSpidersNow	= "Mostrar aviso cuando aparezcan Arañitas de Maexxna",
	TimerSpider			= "Mostrar temporizador para las siguientes Arañitas de Maexxna"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "Logro: Aracnofobia"
})

-----------------------
-- Noth el Pesteador --
-----------------------
L = DBM:GetModLocalization("Noth")

L:SetGeneralLocalization({
	name = "Noth el Pesteador"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "Teletransporte",
	WarningTeleportSoon	= "Teletransporte en 20 s"
})

L:SetTimerLocalization({
	TimerTeleport		= "Teletransporte: Balcón",
	TimerTeleportBack	= "Teletransporte: Suelo"
})

L:SetOptionLocalization({
	WarningTeleportNow	= "Mostrar aviso para Teletransporte",
	WarningTeleportSoon	= "Mostrar aviso previo para Teletransporte",
	TimerTeleport		= "Mostrar temporizador para el siguiente Teletransporte: Balcón",
	TimerTeleportBack	= "Mostrar temporizador para Teletransporte: Suelo"
})

L:SetMiscLocalization({
	Pull				= "¡Muere, intruso!"
})

----------------------
-- Heigan el Impuro --
----------------------
L = DBM:GetModLocalization("Heigan")

L:SetGeneralLocalization({
	name = "Heigan el Impuro"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "Teletransporte",
	WarningTeleportSoon	= "Teletransporte en %d s"
})

L:SetTimerLocalization({
	TimerTeleport	= "Teletransporte"
})

L:SetOptionLocalization({
	WarningTeleportNow	= "Mostrar aviso para Teletransporte",
	WarningTeleportSoon	= "Mostrar aviso previo para Teletransporte",
	TimerTeleport		= "Mostrar aviso para Teletransporte"
})

L:SetMiscLocalization({
	Pull				= "Ahora me perteneces."
})

-------------
-- Loatheb --
-------------
L = DBM:GetModLocalization("Loatheb")

L:SetGeneralLocalization({
	name = "Loatheb"
})

L:SetWarningLocalization({
	WarningHealSoon	= "Sanación posible en 3 s",
	WarningHealNow	= "¡Sanad ahora!"
})

L:SetOptionLocalization({
	WarningHealSoon		= "Mostrar aviso previo para la franja de sanación",
	WarningHealNow		= "Mostrar aviso para la franja de sanación"
})

---------------
-- Remendejo --
---------------
L = DBM:GetModLocalization("Patchwerk")

L:SetGeneralLocalization({
	name = "Remendejo"
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	yell1 = "¡Remendejo quiere jugar!",
	yell2 = "¡Remendejo es la encarnación de guerra de Kel'Thuzad!"
})

---------------
-- Grobbulus --
---------------
L = DBM:GetModLocalization("Grobbulus")

L:SetGeneralLocalization({
	name = "Grobbulus"
})

-----------
-- Gluth --
-----------
L = DBM:GetModLocalization("Gluth")

L:SetGeneralLocalization({
	name = "Gluth"
})

--------------
-- Thaddius --
--------------
L = DBM:GetModLocalization("Thaddius")

L:SetGeneralLocalization({
	name = "Thaddius"
})

L:SetMiscLocalization({
	Yell	= "¡Stalagg aplasta!",
	Emote	= "¡%s se sobrecarga!",
	Emote2	= "¡Espiral Tesla se sobrecarga!",
	Boss1	= "Feugen",
	Boss2	= "Stalagg",
	Charge1 = "negativo",
	Charge2 = "positivo"
})

L:SetOptionLocalization({
	WarningChargeChanged	= "Mostrar aviso especial cuando tu polaridad cambie",
	WarningChargeNotChanged	= "Mostrar aviso especial cuando tu polaridad no cambie",
	AirowEnabled			= "Mostrar flechas (estrategia típica de dos grupos)",
	ArrowsRightLeft			= "Mostrar flechas de izquierda y derecha (estrategia de cuatro grupos; muestra la flecha izquierda si cambia la polaridad, y la derecha si no cambia)",
	ArrowsInverse			= "Mostrar flechas de izquierda y derecha inversas (estrategia de cuatro grupos; muestra la flecha derecha si cambia la polaridad, y la izquierda si no cambia)"
})

L:SetWarningLocalization({
	WarningChargeChanged	= "Polaridad cambiada a %s",
	WarningChargeNotChanged	= "Tu polaridad no ha cambiado"
})

--------------------------
-- Instructor Razuvious --
--------------------------
L = DBM:GetModLocalization("Razuvious")

L:SetGeneralLocalization({
	name = "Instructor Razuvious"
})

L:SetMiscLocalization({
	Yell1 = "¡No tengáis piedad!",
	Yell2 = "¡El tiempo de practicar ha pasado! ¡Quiero ver lo que habéis aprendido!",
	Yell3 = "¡Poned en práctica lo que os he enseñado!",
	Yell4 = "Un barrido con pierna... ¿Tienes algún problema?"
})

L:SetOptionLocalization({
	WarningShieldWallSoon	= "Mostrar aviso previo para cuando termine $spell:29061"
})

L:SetWarningLocalization({
	WarningShieldWallSoon	= "Barrera de huesos termina en 5 s"
})

--------------------------
-- Gothik el Cosechador --
--------------------------
L = DBM:GetModLocalization("Gothik")

L:SetGeneralLocalization({
	name = "Gothik el Cosechador"
})

L:SetOptionLocalization({
	TimerWave			= "Mostrar temporizador para la siguiente oleada de esbirros",
	TimerPhase2			= "Mostrar temporizador para el cambio a Fase 2",
	WarningWaveSoon		= "Mostrar aviso previo para la siguiente oleada de esbirros",
	WarningWaveSpawned	= "Mostrar aviso cuando comience una oleada de esbirros",
	WarningRiderDown	= "Mostrar aviso cuando muera un Jinete inflexible",
	WarningKnightDown	= "Mostrar aviso cuando muera un Caballero de la Muerte inflexible"
})

L:SetTimerLocalization({
	TimerWave	= "Oleada %d",
	TimerPhase2	= "Fase 2"
})

L:SetWarningLocalization({
	WarningWaveSoon		= "Oleada %d: %s en 3 s",
	WarningWaveSpawned	= "Oleada %d: %s",
	WarningRiderDown	= "Jinete muerto",
	WarningKnightDown	= "Caballero muerto",
	WarningPhase2		= "Fase 2"
})

L:SetMiscLocalization({
	yell			= "Tú mismo has buscado tu final.",
	WarningWave1	= "%d %s",
	WarningWave2	= "%d %s y %d %s",
	WarningWave3	= "%d %s, %d %s y %d %s",
	Trainee			= "practicantes",
	Knight			= "caballeros",
	Rider			= "jinetes"
})

------------------------
-- Los Cuatro Jinetes --
------------------------
L = DBM:GetModLocalization("Horsemen")

L:SetGeneralLocalization({
	name = "Los Cuatro Jinetes"
})

L:SetOptionLocalization({
	WarningMarkSoon				= "Mostrar aviso previo para las marcas",
	WarningMarkNow				= "Mostrar aviso para las marcas",
	SpecialWarningMarkOnPlayer	= "Mostrar aviso especial cuando estés afectado por más de cuatro marcas"
})

L:SetTimerLocalization({
})

L:SetWarningLocalization({
	WarningMarkSoon				= "Marca %d en 3 s",
	WarningMarkNow				= "Marca %d",
	SpecialWarningMarkOnPlayer	= "%s: %s"
})

L:SetMiscLocalization({
	Korthazz	= "Señor feudal Korth'azz",
	Rivendare	= "Barón Osahendido",
	Blaumeux	= "Lady Blaumeux",
	Zeliek		= "Sir Zeliek"
})

---------------
-- Sapphiron --
---------------
L = DBM:GetModLocalization("Sapphiron")

L:SetGeneralLocalization({
	name = "Sapphiron"
})

L:SetOptionLocalization({
	WarningAirPhaseSoon	= "Mostrar aviso previo para el cambio a fase aérea",
	WarningAirPhaseNow	= "Anunciar cambio a fase aérea",
	WarningLanded		= "Anunciar cambio a fase en tierra",
	TimerAir			= "Mostrar temporizador para el cambio a fase aérea",
	TimerLanding		= "Mostrar temporizador para el cambio a fase en tierra",
	WarningIceblock		= "Gritar cuando te afecte $spell:28522"
})

L:SetMiscLocalization({
	EmoteBreath			= "%s respira hondo.",
	WarningYellIceblock	= "¡Soy un bloque de hielo!"
})

L:SetWarningLocalization({
	WarningAirPhaseSoon	= "Fase aérea en 10 s",
	WarningAirPhaseNow	= "Fase aérea",
	WarningLanded		= "Fase en tierra"
})

L:SetTimerLocalization({
	TimerAir		= "Fase aérea",
	TimerLanding	= "Fase en tierra"
})

----------------
-- Kel'Thuzad --
----------------

L = DBM:GetModLocalization("Kel'Thuzad")

L:SetGeneralLocalization({
	name = "Kel'Thuzad"
})

L:SetOptionLocalization({
	TimerPhase2			= "Mostrar temporizador para el cambio a Fase 2",
	specwarnP2Soon		= "Mostrar aviso especial 10 s antes del cambio a Fase 2",
	warnAddsSoon		= "Mostrar aviso previo para cuando aparezcan los Guardianes de Corona de Hielo"
})

L:SetMiscLocalization({
	Yell = "¡Esbirros, sirvientes, soldados de la fría oscuridad! ¡Obedeced la llamada de Kel'Thuzad!"
})

L:SetWarningLocalization({
	specwarnP2Soon	= "Fase 2 en 10 s",
	warnAddsSoon	= "Guardianes de Corona de Hielo en breve"
})

L:SetTimerLocalization({
	TimerPhase2	= "Fase 2"
})

---------------------------
-- El Sagrario Obsidiana --
---------------------------
-------------
-- Shadron --
-------------
L = DBM:GetModLocalization("Shadron")

L:SetGeneralLocalization({
	name = "Shadron"
})

--------------
-- Tenebron --
--------------
L = DBM:GetModLocalization("Tenebron")

L:SetGeneralLocalization({
	name = "Tenebron"
})

--------------
-- Vesperon --
--------------
L = DBM:GetModLocalization("Vesperon")

L:SetGeneralLocalization({
	name = "Vesperon"
})

----------------
-- Sartharion --
----------------
L = DBM:GetModLocalization("Sartharion")

L:SetGeneralLocalization({
	name = "Sartharion"
})

L:SetWarningLocalization({
	WarningTenebron			= "Tenebron se aproxima",
	WarningShadron			= "Shadron se aproxima",
	WarningVesperon			= "Vesperon se aproxima",
	WarningFireWall			= "Fire Wall",
	WarningVesperonPortal	= "Vesperon's portal",
	WarningTenebronPortal	= "Tenebron's portal",
	WarningShadronPortal	= "Shadron's portal"
})

L:SetTimerLocalization({
	TimerTenebron	= "Tenebron llega",
	TimerShadron	= "Shadron llega",
	TimerVesperon	= "Vesperon llega"
})

L:SetOptionLocalization({
	AnnounceFails			= "Anunciar jugadores que reciban daño de &spell:57491 y $spell:57579 en el chat de banda (requiere líder o ayudante)",
	TimerTenebron			= "Mostrar temporizador para la llegada de Tenebron",
	TimerShadron			= "Mostrar temporizador para la llegada de Shadron",
	TimerVesperon			= "Mostrar temporizador para la llegada de Vesperon",
	WarningFireWall			= "Mostrar aviso especial para $spell:57491",
	WarningTenebron			= "Anunciar cuando Tenebron se aproxime",
	WarningShadron			= "Anunciar cuando Shadron se aproxime",
	WarningVesperon			= "Anunciar cuando Vesperon se aproxime",
	WarningTenebronPortal	= "Mostrar aviso especial cuando aparezca el portal de Tenebron",
	WarningShadronPortal	= "Mostrar aviso especial cuando aparezca el portal de Shadron",
	WarningVesperonPortal	= "Mostrar aviso especial cuando aparezca el portal de Vesperon"
})

L:SetMiscLocalization({
	Wall			= "¡La lava se arremolina alrededor de %s!",
	Portal			= "%s comienza a abrir un Portal Crepuscular",
	NameTenebron	= "Tenebron",
	NameShadron		= "Shadron",
	NameVesperon	= "Vesperon",
	FireWallOn		= "Tsunami de llamas: %s",
	VoidZoneOn		= "Fisura de las Sombras: %s",
	VoidZones		= "Fallos en Fisura de las Sombras (en este intento): %s",
	FireWalls		= "Fallos en Tsunami de llamas (en este intento): %s"
})

-------------
-- Malygos --
-------------
L = DBM:GetModLocalization("Malygos")

L:SetGeneralLocalization({
	name = "Malygos"
})

L:SetMiscLocalization({
	YellPull	= "Habéis agotado mi paciencia. ¡Me desharé de vosotros!",
	EmoteSpark	= "¡Un Chispazo toma forma a partir de una falla cercana!",
	YellPhase2	= "Esperaba acabar con vuestras vidas rápidamente",
	YellBreath	= "¡No lo conseguiréis mientras me quede aliento!",
	YellPhase3	= "Ahora aparecen vuestros benefactores, ¡pero llegan demasiado tarde!"
})

------------------------
-- Leviatán de llamas --
------------------------
L = DBM:GetModLocalization("FlameLeviathan")

L:SetGeneralLocalization{
	name = "Flame Leviathan"
}

L:SetMiscLocalization{
	YellPull	= "Entidades hostiles detectadas. Protocolo de evaluación de amenaza activado. Objetivo principal fijado. Tiempo restante para re-evaluación: 30 segundos.",
	Emote		= "%%s persigue a (%S+)%."
}

L:SetWarningLocalization{
	PursueWarn				= "Persiguiendo a >%s<",
	warnNextPursueSoon		= "Cambio de objetivo en 5 s",
	SpecialPursueWarnYou	= "El leviatán te persigue - ¡huye!",
	warnWardofLife			= "Guarda de vida"
}

L:SetOptionLocalization{
	SpecialPursueWarnYou	= "Mostrar aviso especial cuando te afecte $spell:62374",
	PursueWarn				= "Anunciar objetivos de $spell:62374",
	warnNextPursueSoon		= "Mostrar aviso previo para el siguiente $spell:62374",
	warnWardofLife			= "Mostrar aviso especial cuando aparezcan Guardas de vida"
}

------------------------------------
-- Ignis el Maestro de la Caldera --
------------------------------------
L = DBM:GetModLocalization("Ignis")

L:SetGeneralLocalization{
	name = "Ignis the Furnace Master"
}

L:SetOptionLocalization{
	SlagPotIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(63477)
}

----------------
-- Tajoescama --
----------------
L = DBM:GetModLocalization("Razorscale")

L:SetGeneralLocalization{
	name = "Razorscale"
}

L:SetWarningLocalization{
	warnTurretsReadySoon		= "Última torreta lista en 20 s",
	warnTurretsReady			= "Última torreta lista"
}

L:SetTimerLocalization{
	timerTurret1	= "Torreta 1",
	timerTurret2	= "Torreta 2",
	timerTurret3	= "Torreta 3",
	timerTurret4	= "Torreta 4",
	timerGrounded	= "En tierra"
}

L:SetOptionLocalization{
	warnTurretsReadySoon		= "Mostrar aviso previo para cuando las torretas estén listas",
	warnTurretsReady			= "Mostrar aviso cuando las torretas estén listas",
	timerTurret1				= "Mostrar temporizador para la primera torreta",
	timerTurret2				= "Mostrar temporizador para la segunda torreta",
	timerTurret3				= "Mostrar temporizador para la tercera torreta (25 jugadores)",
	timerTurret4				= "Mostrar temporizador para la cuarta torreta (25 jugadores)",
	timerGrounded			    = "Mostrar temporizador para la duración de la fase en tierra"
}

L:SetMiscLocalization{
	YellAir				        = "Danos un momento para que nos preparemos para construir las torretas.",
	YellAir2			        = "Listos para salir, ¡impedid que esos enanos se peguen a nuestra espalda!",
	YellGround				    = "¡Moveos! ¡No seguirá mucho más en el suelo!",
	EmotePhase2			        = "¡%%s ha aterrizado permanentemente!",
}

-----------------------
-- Desarmador XA-002 --
-----------------------
L = DBM:GetModLocalization("XT002")

L:SetGeneralLocalization{
	name = "Desarmador XA-002"
}

---------------------------
-- La Asamblea de Hierro --
---------------------------
L = DBM:GetModLocalization("IronCouncil")

L:SetGeneralLocalization{
	name = "La Asamblea de Hierro"
}

L:SetOptionLocalization{
	AlwaysWarnOnOverload		= "Mostrar siempre aviso para $spell:63481 (de lo contrario, solo se muestra cuando eres el objetivo)"
}

L:SetMiscLocalization{
	Steelbreaker		= "Rompeacero",
	RunemasterMolgeim	= "Maestro de runas Molgeim",
	StormcallerBrundir 	= "Clamatormentas Brundir"
}

---------------------------
-- Algalon el Observador --
---------------------------
L = DBM:GetModLocalization("Algalon")

L:SetGeneralLocalization{
	name = "Algalon el Observador"
}

L:SetTimerLocalization{
	NextCollapsingStar		= "Siguiente Estrella en colapso",
	TimerCombatStart		= "Comienza el encuentro"
}

L:SetWarningLocalization{
	WarnPhase2Soon			= "Fase 2 en breve",
	warnStarLow				= "Estrella en colapso a poca salud"
}

L:SetOptionLocalization{
	WarningPhasePunch		= "Anunciar objetivos de $spell:64412",
	NextCollapsingStar		= "Mostrar temporizador para la siguiente Estrella en colapso",
	TimerCombatStart		= "Mostrar temporizador para el inicio del encuentro",
	WarnPhase2Soon			= "Mostrar aviso previo para el cambio a Fase 2 (cuando el jefe llegue al 23% de salud)",
	warnStarLow				= "Mostrar aviso especial cuando una Estrella en colapso tenga la salud baja (25%)"
}

L:SetMiscLocalization{
	YellPull				= "Vuestros actos carecen de lógica. Se ha calculado cualquier posible resultado de este encuentro. El Panteón recibirá el mensaje del Observador sean cuales sean las consecuencias.",
	YellKill				= "He visto mundos hundirse en las llamas de los Creadores, como se desvanecían sus habitantes sin apenas un gemido. He visto sistemas planetarios enteros crearse y ser arrasados en lo que vuestros mortales corazones laten una sola vez. Y mi corazón permaneció desprovisto de emoción... de empatía. Yo... no... sentí... nada. Millones de vidas malgastadas ¿Acaso compartían vuestra tenacidad? ¿Amaban la vida como vosotros?",
	Emote_CollapsingStar	= "¡%s comienza a invocar estrellas en colapso!",
	Phase2					= "¡Observad las herramientas de la creación!",
	FirstPull				= "Mirad vuestro mundo a través de mis ojos: un universo tan vasto que es inconmensurable, incompresible incluso para vuestras grandes mentes."
}

--------------
-- Kologarn --
--------------
L = DBM:GetModLocalization("Kologarn")

L:SetGeneralLocalization{
	name = "Kologarn"
}

L:SetTimerLocalization{
	timerLeftArm		= "Brazo izquierdo reaparece",
	timerRightArm		= "Brazo derecho reaparece",
	achievementDisarmed	= "Logro: Desarmado"
}

L:SetOptionLocalization{
	timerLeftArm			= "Mostrar temporizador para la regeneración del Brazo izquierdo",
	timerRightArm			= "Mostrar temporizador para la regeneración del Brazo derecho",
	achievementDisarmed		= "Mostrar temporizador para el logro 'Desarmado'"
}

L:SetMiscLocalization{
	Yell_Trigger_arm_left	= "¡No es más que un arañazo!",
	Yell_Trigger_arm_right	= "¡Una herida superficial!",
	Health_Body				= "Kologarn",
	Health_Right_Arm		= "Brazo derecho",
	Health_Left_Arm			= "Brazo izquierdo",
	FocusedEyebeam			= "sus ojos en ti",
	YellBeam				= "¡Haz ocular enfocado en mi!"
}

-------------
-- Auriaya --
-------------
L = DBM:GetModLocalization("Auriaya")

L:SetGeneralLocalization{
	name = "Auriaya"
}

L:SetMiscLocalization{
	Defender = "Defensor feral (%d)",
	YellPull = "¡Es mejor dejar ciertas cosas tal como están!"
}

L:SetTimerLocalization{
	timerDefender	= "Defensor feral activo"
}

L:SetWarningLocalization{
	WarnCatDied		= "Defensor feral muerto (%d vidas restantes)",
	WarnCatDiedOne	= "Defensor feral muerto (1 vida restante)"
}

L:SetOptionLocalization{
	WarnCatDied		= "Mostrar aviso cuando muera el Defensor feral",
	WarnCatDiedOne	= "Mostrar aviso cuando el Defensor feral solo tenga una vida restante",
	timerDefender	= "Mostrar temporizador para cuando aparezca o reviva el Defensor feral"
}

-----------
-- Hodir --
-----------
L = DBM:GetModLocalization("Hodir")

L:SetGeneralLocalization{
	name = "Hodir"
}

L:SetMiscLocalization{
	Pull		= "¡Sufriréis por esta intromisión!",
	YellKill	= "Estoy... estoy libre de sus garras... al fin."
}

------------
-- Thorim --
------------
L = DBM:GetModLocalization("Thorim")

L:SetGeneralLocalization{
	name = "Thorim"
}

L:SetTimerLocalization{
	TimerHardmode	= "Modo difícil"
}

L:SetOptionLocalization{
	TimerHardmode	= "Mostrar temporizador para el modo difícil",
	AnnounceFails	= "Anunciar jugadores que reciban daño de $spell:62017 en el chat de banda (requiere líder o ayudante)"
}

L:SetMiscLocalization{
	YellPhase1	= "¡Intrusos! Vosotros, mortales que osáis interferir en mi diversión, pagaréis... Un momento...",
	YellPhase2	= "Gusanos impertinentes, ¿cómo osáis desafiarme en mi pedestal? ¡Os machacaré con mis propias manos!",
	YellKill	= "¡Guardad las armas! ¡Me rindo!",
	ChargeOn	= "Carga relámpago: %s",
	Charge		= "Fallos en Carga relámpago (en este intento): %s"
}

-----------
-- Freya --
-----------
L = DBM:GetModLocalization("Freya")

L:SetGeneralLocalization{
	name = "Freya"
}

L:SetMiscLocalization{
	SpawnYell		= "¡Hijos, ayudadme!",
	WaterSpirit		= "Espíritu de agua antiguo",
	Snaplasher		= "Quiebrazotador",
	StormLasher		= "Azotador de tormenta",
	YellKill		= "Su control sobre mí se disipa. Vuelvo a ver con claridad. Gracias, héroes.",
}

L:SetWarningLocalization{
	WarnSimulKill	= "Primer esbirro muerto - Resurrección en ~12 segundos"
}

L:SetTimerLocalization{
	TimerSimulKill	= "Resurrección"
}

L:SetOptionLocalization{
	WarnSimulKill	= "Anunciar primer esbirro muerto",
	TimerSimulKill	= "Mostrar temporizador para la resurrección de esbirros"
}

------------------------
-- Ancestros de Freya --
------------------------
L = DBM:GetModLocalization("Freya_Elders")

L:SetGeneralLocalization{
	name = "Ancestros de Freya"
}

-------------
-- Mimiron --
-------------
L = DBM:GetModLocalization("Mimiron")

L:SetGeneralLocalization{
	name = "Mimiron"
}

L:SetWarningLocalization{
	MagneticCore		= ">%s< tiene Núcleo magnético",
	WarningShockBlast	= "Explosión de choque - ¡aléjate!",
	WarnBombSpawn		= "Bombabot"
}

L:SetTimerLocalization{
	TimerHardmode	= "Autodestrucción",
	TimeToPhase2	= "Fase 2",
	TimeToPhase3	= "Fase 3",
	TimeToPhase4	= "Fase 4"
}

L:SetOptionLocalization{
	TimeToPhase2			= "Mostrar temporizador para el cambio a Fase 2",
	TimeToPhase3			= "Mostrar temporizador para el cambio a Fase 3",
	TimeToPhase4			= "Mostrar temporizador para el cambio a Fase 4",
	MagneticCore			= "Anunciar jugadores que despojen Núcleos magnéticos",
	WarnBombSpawn			= "Mostrar aviso cuando aparezcan Bombabots",
	TimerHardmode			= "Mostrar temporizador para la autodestrucción del modo difícil",
	ShockBlastWarningInP1	= "Mostrar aviso especial para $spell:63631 en Fase 1",
	ShockBlastWarningInP4	= "Mostrar aviso especial para $spell:63631 en Fase 4"
}

L:SetMiscLocalization{
	MobPhase1		= "Mk II de leviatán",
	MobPhase2		= "VX-001",
	MobPhase3		= "Unidad de mando aérea",
	YellPull		= "¡No tenemos mucho tiempo, amigos! Vais a ayudarme a probar mi última y mayor creación. Ahora, antes de que cambiéis de parecer, recordad que en cierta forma, me lo debéis después del desastre que causasteis con el XA-002.",
	YellHardPull	= "Secuencia de autodestrucción iniciada",
	YellPhase2		= "¡Contemplad el cañón de asalto antipersonal VX-001! Puede que queráis poneros a cubierto.",
	YellPhase3		= "¡Gracias amigos! ¡Vuestros esfuerzos me han proporcionado unos datos fantásticos! Veamos, ¿dónde puse?...ah, ahí está.",
	YellPhase4		= "Fase de prueba preliminar completada. ¡Ahora comienza la verdadera prueba!"
}

-------------------
-- General Vezax --
-------------------
L = DBM:GetModLocalization("GeneralVezax")

L:SetGeneralLocalization{
	name = "General Vezax"
}

L:SetTimerLocalization{
	hardmodeSpawn = "Animus de saronita"
}

L:SetWarningLocalization{
	SpecialWarningShadowCrash		= "Fragor de sombra en ti - ¡aléjate de los demás!",
	SpecialWarningShadowCrashNear	= "Fragot de sombra cerca de ti - ¡apártate!",
	SpecialWarningLLNear			= "Marca de los Ignotos en %s cerca de ti"
}

L:SetOptionLocalization{
	SpecialWarningShadowCrash		= "Mostrar aviso especial para $spell:62660",
	SpecialWarningShadowCrashNear	= "Mostrar aviso especial cuando $spell:62660 ocurra cerca de ti",
	SpecialWarningLLNear			= "Mostrar aviso especial cuando $spell:63276 ocurra cerca de ti",
	hardmodeSpawn					= "Mostrar temporizador para cuando aparezca el Animus de saronita (modo difícil)",
	CrashArrow						= "Mostrar flecha cuando $spell:62660 ocurra cerca de ti"
}

L:SetMiscLocalization{
	EmoteSaroniteVapors	= "¡Cerca se forma una nube de vapores de saronita!",
	YellLeech			= "¡Drenar vida en mí!",
	YellCrash			= "¡Fragor de sombra en mí!"
}

----------------
-- Yogg-Saron --
----------------
L = DBM:GetModLocalization("YoggSaron")

L:SetGeneralLocalization{
	name = "Yogg-Saron"
}

L:SetWarningLocalization{
	WarningGuardianSpawned 			= "Guardián (%d)",
	WarningCrusherTentacleSpawned	= "Tentáculo triturador",
	WarningSanity 					= "%d de Cordura restante",
	SpecWarnSanity 					= "%d de Cordura restante",
	SpecWarnGuardianLow				= "Guardián a poca salud - ¡deja de atacar!",
	SpecWarnMadnessOutNow			= "Inducir a la locura en breve - ¡sal ya!",
	WarnBrainPortalSoon				= "Portales en 3 s",
	SpecWarnFervor					= "Fervor de Sara en ti",
	SpecWarnFervorCast				= "Fervor de Sara se está lanzando en ti",
	specWarnBrainPortalSoon			= "Portal en breve"
}

L:SetTimerLocalization{
	NextPortal	= "Siguientes portales"
}

L:SetOptionLocalization{
	WarningGuardianSpawned			= "Mostrar aviso cuando aparezca un Guardián de Yogg-Saron",
	WarningCrusherTentacleSpawned	= "Mostrar aviso cuando aparezca un Tentáculo triturador",
	WarningSanity					= "Mostrar aviso cuando te quede poca $spell:63050",
	SpecWarnSanity					= "Mostrar aviso especial cuando te quede muy poca $spell:63050",
	SpecWarnGuardianLow				= "Mostrar aviso especial cuando a un Guardián de Yogg-Saron le quede poca vida (solo para DPS)",
	WarnBrainPortalSoon				= "Mostrar aviso previo para los siguientes portales",
	SpecWarnMadnessOutNow			= "Mostrar aviso especial cuando $spell:64059 esté a punto de lanzarse",
	SpecWarnFervorCast				= "Mostrar aviso especial cuando te estén lanzando $spell:63138",
	specWarnBrainPortalSoon			= "Mostrar aviso especial para los siguientes portales",
	NextPortal						= "Mostrar temporizador para los siguientes portales",
	MaladyArrow						= "Mostrar flecha cuando $spell:63881 ocurra cerca de ti"
}

L:SetMiscLocalization{
	YellPull 			= "¡Pronto llegará la hora de golpear la cabeza del monstruo! ¡Centrad vuestra ira y odio en sus esbirros!",
	YellPhase2	 		= "Soy un sueño lúcido.",
	Sara 				= "Sara"
}

--------------
--  Onyxia  --
--------------
L = DBM:GetModLocalization("Onyxia")

L:SetGeneralLocalization{
	name = "Onyxia"
}

L:SetWarningLocalization{
	WarnWhelpsSoon		= "Crías de Onyxia en breve"
}

L:SetTimerLocalization{
	TimerWhelps	= "Crías de Onyxia"
}

L:SetOptionLocalization{
	TimerWhelps				= "Mostrar temporizador para las siguientes Crías de Onyxia",
	WarnWhelpsSoon			= "Mostrar aviso previo para las siguientes Crías de Onyxia",
	SoundWTF3				= "Reproducir sonidos graciosos de cierta banda legendaria"
}

L:SetMiscLocalization{
	YellPull = "Qué casualidad. Generalmente, debo salir de mi guarida para poder comer.",
	YellP2 = "Este ejercicio sin sentido me aburre. ¡Os inceneraré a todos desde arriba!",
	YellP3 = "¡Parece ser que vais a necesitar otra lección, mortales!"
}

-------------------------------
-- Las bestias de Rasganorte --
-------------------------------
L = DBM:GetModLocalization("NorthrendBeasts")

L:SetGeneralLocalization{
	name = "Las bestias de Rasganorte"
}

L:SetWarningLocalization{
	WarningSnobold		= "Vasallo snóbold en >%s<"
}

L:SetTimerLocalization{
	TimerNextBoss		= "Siguiente jefe",
	TimerEmerge			= "Emersión",
	TimerSubmerge		= "Sumersión"
}

L:SetOptionLocalization{
	WarningSnobold		= "Mostrar aviso cuando aparezca un Vasallo snóbold",
	ClearIconsOnIceHowl	= "Quitar todos los iconos antes de cada carga",
	TimerNextBoss		= "Mostrar temporizador para el siguiente jefe",
	TimerEmerge			= "Mostrar temporizador para cuando Fauceácida y Aterraescama regresen a la superficie",
	TimerSubmerge		= "Mostrar temporizador para cuando Fauceácida y Aterraescama se sumerjan en la tierra",
	IcehowlArrow		= "Mostrar flecha cuando Aullahielo vaya a cargar hacia ti"
}

L:SetMiscLocalization{
	Charge		= "¡Aullahielo mira a (%S+) y emite un bramido!",
	CombatStart	= "Desde las cavernas más oscuras y profundas de Las Cumbres Tormentosas: ¡Gormok el Empalador! ¡A luchar, héroes!",
	Phase2		= "Preparaos, héroes, para los temibles gemelos: ¡Fauceácida y Aterraescama! ¡A la arena!",
	Phase3		= "El propio aire se congela al presentar a nuestro siguiente combatiente: ¡Aullahielo! ¡Matad o morid, campeones!",
	Gormok		= "Gormok el Empalador",
	Acidmaw		= "Fauceácida",
	Dreadscale	= "Aterraescama",
	Icehowl		= "Aullahielo"
}

-------------------
-- Lord Jaraxxus --
-------------------
L = DBM:GetModLocalization("Jaraxxus")

L:SetGeneralLocalization{
	name = "Lord Jaraxxus"
}

L:SetOptionLocalization{
	IncinerateShieldFrame		= "Mostrar salud del jefe en una barra de vida durante Incinerar carne"
}

L:SetMiscLocalization{
	IncinerateTarget	= "Incinerar carne: %s",
	FirstPull	= "El gran brujo Wilfred Chispobang invocará al siguiente contrincante. Esperad a que aparezca."
}

-----------------------------
-- Campeones de la facción --
-----------------------------
L = DBM:GetModLocalization("Champions")

local champions = "Campeones de la facción"
if UnitFactionGroup("player") == "Alliance" then
	champions = "Campeones de la Horda"
elseif UnitFactionGroup("player") == "Horde" then
	champions = "Campeones de la Alianza"
end

L:SetGeneralLocalization{
	name = champions
}

L:SetMiscLocalization{
	AllianceVictory    = "¡GLORIA A LA ALIANZA!",
	HordeVictory       = "Eso solo ha sido una muestra de lo que os depara el futuro. ¡POR LA HORDA!"
}

---------------------
-- Gemelas Val'kyr --
---------------------
L = DBM:GetModLocalization("ValkTwins")

L:SetGeneralLocalization{
	name = "Gemelas Val'kyr"
}

L:SetTimerLocalization{
	TimerSpecialSpell	= "Siguiente facultad especial"
}

L:SetWarningLocalization{
	WarnSpecialSpellSoon		= "Facultad especial en breve",
	SpecWarnSpecial				= "Cambia de color",
	SpecWarnSwitchTarget		= "Cambia de objetivo",
	SpecWarnKickNow				= "Interrumpe ahora",
	WarningTouchDebuff			= "Perjuicio en >%s<",
	WarningPoweroftheTwins2		= "Poder de las Gemelas - ¡más sanación en >%s<!",
	SpecWarnPoweroftheTwins		= "Poder de las Gemelas"
}

L:SetMiscLocalization{
	Fjola		= "Fjola Penívea",
	Eydis		= "Eydis Penaumbra"
}

L:SetOptionLocalization{
	TimerSpecialSpell			= "Mostrar temporizador para la siguiente facultad especial",
	WarnSpecialSpellSoon		= "Mostrar aviso previo para la siguiente facultad especial",
	SpecWarnSpecial				= "Mostrar aviso especial cuando debas cambiar de color",
	SpecWarnSwitchTarget		= "Mostrar aviso especial cuando la otra gemela esté lanzando un hechizo",
	SpecWarnKickNow				= "Mostrar aviso especial cuando debas interrumpir",
	SpecialWarnOnDebuff			= "Mostrar aviso especial cuando estés afectado por un perjuicio (para cambiarlo por otro)",
	SetIconOnDebuffTarget		= "Poner iconos en los objetivos de los perjuicios de $spell:65950 y $spell:66001 (dificultad heroica)",
	WarningTouchDebuff			= "Anunciar objetivos de los perjuicios de $spell:65950 y $spell:66001",
	WarningPoweroftheTwins2		= "Anunciar la gemela afectada por $spell:65916",
	SpecWarnPoweroftheTwins		= "Mostrar aviso especial cuando estés tanqueando una gemela afectada por $spell:65916"
}

---------------
-- Anub'arak --
---------------
L = DBM:GetModLocalization("Anub'arak_Coliseum")

L:SetGeneralLocalization{
	name 					= "Anub'arak"
}

L:SetTimerLocalization{
	TimerEmerge				= "Emersión",
	TimerSubmerge			= "Sumersión",
	timerAdds				= "Siguientes esbirros"
}

L:SetWarningLocalization{
	WarnEmerge				= "Anub'arak regresa a la superficie",
	WarnEmergeSoon			= "Emersión en 10 s",
	WarnSubmerge			= "Anub'arak se entierra en el suelo",
	WarnSubmergeSoon		= "Sumersión en 10 s",
	specWarnSubmergeSoon	= "¡Sumersión en 10 s!",
	warnAdds				= "Siguientes esbirros"
}

L:SetMiscLocalization{
	Emerge				= "emerge de la tierra!",
	Burrow				= "se entierra en el suelo!",
	PcoldIconSet		= "Icono {rt%d} colocado en %s",
	PcoldIconRemoved	= "Icono quitado en %s"
}

L:SetOptionLocalization{
	WarnEmerge				= "Mostrar aviso cuando Anub'arak regrese a la superficie",
	WarnEmergeSoon			= "Mostrar aviso previo para cuando Anub'arak regrese a la superficie",
	WarnSubmerge			= "Mostrar aviso cuando Anub'arak se entierre en el suelo",
	WarnSubmergeSoon		= "Mostrar aviso previo para cuando Anub'arak se entierre en el suelo",
	specWarnSubmergeSoon	= "Mostrar aviso especial cuando falte poco para que Anub'arak se entierre en el suelo",
	warnAdds				= "Anunciar cuando aparezcan esbirros",
	timerAdds				= "Mostrar temporizador para los siguientes esbirros",
	TimerEmerge				= "Mostrar temporizador para cuando Anub'arak regrese a la superficie",
	TimerSubmerge			= "Mostrar temporizador para cuando Anub'arak se entierre en el suelo",
	AnnouncePColdIcons		= "Anunciar iconos de los objetivos de $spell:66013 en el chat de banda (requiere líder o ayudante)",
	AnnouncePColdIconsRemoved	= "Anunciar iconos quitados de los objetivos de $spell:66013 (requiere que la opción anterior esté habilitada)"
}

------------------
-- Lord Tuétano --
------------------
L = DBM:GetModLocalization("LordMarrowgar")

L:SetGeneralLocalization{
	name = "Lord Tuétano"
}

L:SetOptionLocalization{
	SetIconOnImpale		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(69062)
}

------------------------
-- Lady Susurramuerte --
------------------------
L = DBM:GetModLocalization("Deathwhisper")

L:SetGeneralLocalization{
	name = "Lady Susurramuerte"
}

L:SetTimerLocalization{
	TimerAdds	= "Siguientes esbirros"
}

L:SetWarningLocalization{
	WarnReanimating				= "Esbirro reanimado",			-- Reanimating an adherent or fanatic
	WarnAddsSoon				= "Esbirros en breve"
}

L:SetOptionLocalization{
	WarnAddsSoon				= "Mostrar aviso previo para cuando aparezcan esbirros",
	WarnReanimating				= "Mostrar aviso cuando se esté reanimando a un esbirro",	-- Reanimated Adherent/Fanatic spawning
	TimerAdds					= "Mostrar temporizador para los siguientes esbirros",
	SetIconOnDominateMind		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(71289),
	SetIconOnDeformedFanatic	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(70900),
	SetIconOnEmpoweredAdherent	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(70901)
}

L:SetMiscLocalization{
	YellReanimatedFanatic	= "¡Álzate y goza de tu verdadera forma!",
	Fanatic1				= "Fanático del Culto",
	Fanatic2				= "Fanático deformado",
	Fanatic3				= "Fanático reanimado"
}

--------------------------------
-- Batalla de naves de guerra --
--------------------------------
L = DBM:GetModLocalization("GunshipBattle")

L:SetGeneralLocalization{
	name = "Batalla de naves de guerra"
}

L:SetWarningLocalization{
	WarnAddsSoon	= "Esbirros en breve"
}

L:SetOptionLocalization{
	WarnAddsSoon		= "Mostrar aviso previo para cuando aparezcan esbirros",
	TimerAdds			= "Mostrar temporizador para los siguientes esbirros"
}

L:SetTimerLocalization{
	TimerAdds			= "Siguientes esbirros"
}

L:SetMiscLocalization{
	PullAlliance	= "¡Arrancad motores! ¡Tenemos una cita con el destino, muchachos!",
	PullHorde		= "¡Alzaos, hijos e hijas de la Horda! ¡Hoy nos enfrentamos a un odiado enemigo de la Horda! ¡LOK'TAR OGAR!",
	AddsAlliance	= "¡Atracadores, sargentos, atacad!",
	AddsHorde		= "¡Soldados, sargentos, atacad!",
	MageAlliance	= "Nos están dañando el casco, ¡traed un mago de batalla aquí para acabar con esos cañones!",
	MageHorde		= "Nos están dañando el casco, ¡traed un brujo aquí para acabar con esos cañones!",
	Hammer 			= "Martillo de Orgrim",
	Skybreaker		= "El Rompecielos"
}

------------------------------
-- Libramorte Colmillosauro --
------------------------------
L = DBM:GetModLocalization("Deathbringer")

L:SetGeneralLocalization{
	name = "Libramorte Colmillosauro"
}

L:SetOptionLocalization{
	BoilingBloodIcons		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(72385),
	RangeFrame				= "Mostrar marco de distancia (12 m)",
	RunePowerFrame			= "Mostrar marco de salud del jefe y $spell:72371"
}

L:SetMiscLocalization{
	PullAlliance		= "Por cada soldado de la Horda que matasteis... Por cada perro de la Alianza que cayó, el ejército del Rey Exánime creció. Ahora, hasta las Val'kyr alzan a los caídos para la Plaga.",
	PullHorde			= "¡Kor'kron, vámonos! Campeones, vigilad vuestra retaguardia. La Plaga ha sido..."
}

------------------
-- Panzachancro --
------------------
L = DBM:GetModLocalization("Festergut")

L:SetGeneralLocalization{
	name = "Panzachancro"
}

L:SetOptionLocalization{
	RangeFrame			= "Mostrar marco de distancia (8 m)",
	SetIconOnGasSpore	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(69279),
	AnnounceSporeIcons	= "Anunciar iconos de los objetivos de $spell:69279 en el chat de banda (requiere líder o ayudante)",
	AchievementCheck	= "Anunciar si se falla el logro 'Sin vacunas' en el chat de banda (requiere líder o ayudante)"
}

L:SetMiscLocalization{
	SporeSet			= "Icono {rt%d} de Espora de gas en %s",
	AchievementFailed	= ">> LOGRO FALLADO: %s tiene %d acumulaciones de Inoculado <<"
}

----------------
-- Carapútrea --
----------------
L = DBM:GetModLocalization("Rotface")

L:SetGeneralLocalization{
	name = "Carapútrea"
}

L:SetWarningLocalization{
	WarnOozeSpawn				= "Moco pequeño",
	SpecWarnLittleOoze			= "Te está atacando un Moco pequeño - ¡huye!"--creatureid 36897
}

L:SetOptionLocalization{
	WarnOozeSpawn				= "Mostrar aviso cuando aparezca un Moco pequeño",
	SpecWarnLittleOoze			= "Mostrar aviso especial cuando te ataque un Moco pequeño",--creatureid 36897
	RangeFrame					= "Mostrar marco de distancia (8 m)",
	InfectionIcon				= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(69674)
}

L:SetMiscLocalization{
	YellSlimePipes1	= "¡Buenas noticias, amigos! He arreglado las tuberías de babosas venenosas.",	-- Professor Putricide
	YellSlimePipes2	= "¡Grandes noticias, amigos! Las babosas vuelven a fluir."	-- Professor Putricide
}

-------------------------
-- Profesor Putricidio --
-------------------------
L = DBM:GetModLocalization("Putricide")

L:SetGeneralLocalization{
	name = "Profesor Putricidio"
}

L:SetOptionLocalization{
	OozeAdhesiveIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(70447),
	GaseousBloatIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(70672),
	UnboundPlagueIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(70911),
	MalleableGooIcon			= "Poner icono en el primer objetivo de $spell:72295"
}

------------------------------------
-- Consejo de Príncipes de Sangre --
------------------------------------
L = DBM:GetModLocalization("BPCouncil")

L:SetGeneralLocalization{
	name = "Consejo de Príncipes de Sangre"
}

L:SetWarningLocalization{
	WarnTargetSwitch		= "Cambio de objetivo: %s",
	WarnTargetSwitchSoon	= "Cambio de objetivo en breve"
}

L:SetTimerLocalization{
	TimerTargetSwitch		= "Cambio de objetivo"
}

L:SetOptionLocalization{
	WarnTargetSwitch		= "Mostrar aviso cuando haya que cambiar de objetivo",-- Warn when another Prince needs to be damaged
	WarnTargetSwitchSoon	= "Mostrar aviso previo para cuando haya que cambiar de objetivo",-- Every ~47 secs, you have to dps a different Prince
	TimerTargetSwitch		= "Mostrar temporizador para el siguiente cambio de objetivo",
	EmpoweredFlameIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(72040),
	ActivePrinceIcon		= "Poner icono (calavera) en el príncipe potenciado",
	RangeFrame				= "Mostrar marco de distancia (12 m)"
}

L:SetMiscLocalization{
	Keleseth			= "Príncipe Keleseth",
	Taldaram			= "Príncipe Taldaram",
	Valanar				= "Príncipe Valanar",
	EmpoweredFlames		= "¡Llamas potenciadas arremeten contra (%S+)!"
}

-------------------------------
-- Reina de Sangre Lana'thel --
-------------------------------
L = DBM:GetModLocalization("Lanathel")

L:SetGeneralLocalization{
	name = "Reina de Sangre Lana'thel"
}

L:SetOptionLocalization{
	SetIconOnDarkFallen		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(71340),
	SwarmingShadowsIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(71266),
	BloodMirrorIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(70838),
	RangeFrame				= "Mostrar marco de distancia (8 m)"
}

L:SetMiscLocalization{
	SwarmingShadows			= "¡Las sombras se acumulan alrededor de (%S+)!",
	YellFrenzy				= "¡Tengo hambre!"
}

----------------------------
-- Valithria Caminasueños --
----------------------------
L = DBM:GetModLocalization("Valithria")

L:SetGeneralLocalization{
	name = "Valithria Caminasueños"
}

L:SetWarningLocalization{
	WarnPortalOpen	= "Siguientes portales"
}

L:SetTimerLocalization{
	TimerPortalsOpen		= "Portales abiertos",
	TimerPortalsClose		= "Portales cerrados",
	TimerBlazingSkeleton	= "Siguiente Esqueleto llameante",
	TimerAbom				= "Siguiente Abominación glotona"
}

L:SetOptionLocalization{
	SetIconOnBlazingSkeleton	= "Poner icono (calavera) en Esqueleto llameante",
	WarnPortalOpen				= "Mostrar aviso cuando se abran los portales",
	TimerPortalsOpen			= "Mostrar temporizador para cuando se abran los portales",
	TimerPortalsClose			= "Mostrar temporizador para cuando se cierren los portales",
	TimerBlazingSkeleton		= "Mostrar temporizador para el siguiente Esqueleto llameante",
	TimerAbom					= "Mostrar temporizador para la siguiente Abominación glotona"
}

L:SetMiscLocalization{
	YellPortals		= "He abierto un portal al Sueño. Vuestra salvación está dentro, héroes..."
}

----------------
-- Sindragosa --
----------------
L = DBM:GetModLocalization("Sindragosa")

L:SetGeneralLocalization{
	name = "Sindragosa"
}

L:SetWarningLocalization{
	WarnAirphase			= "Fase aérea",
	WarnGroundphaseSoon		= "Fase en tierra en breve"
}

L:SetTimerLocalization{
	TimerNextAirphase		= "Siguiente fase aérea",
	TimerNextGroundphase	= "Siguiente fase en tierra",
	AchievementMystic		= "Logro: Sacúdete"
}

L:SetOptionLocalization{
	WarnAirphase			= "Anunciar cambio a fase aérea",
	WarnGroundphaseSoon		= "Mostrar aviso previo para el cambio a fase en tierra",
	TimerNextAirphase		= "Mostrar temporizador para la siguiente fase aérea",
	TimerNextGroundphase	= "Mostrar temporizador para la siguiente fase en tierra",
	AnnounceFrostBeaconIcons= "Anunciar iconos de los objetivos de $spell:70126 en el chat de banda (requiere líder)",
	SetIconOnFrostBeacon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(70126),
	SetIconOnUnchainedMagic	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(69762),
	ClearIconsOnAirphase	= "Quitar todos los iconos al comenzar la fase aérea",
	AchievementCheck		= "Anunciar avisos del logro 'Sacúdete' en el chat de banda (requiere líder o ayudante)",
	RangeFrame				= "Mostrar marco de distancia (10/20 m) dinámico en función de la última habilidad usada por el jefe y los perjuicios de los jugadores"
}

L:SetMiscLocalization{
	YellAirphase	= "¡Aquí termina vuestra incursión! ¡Nadie sobrevivirá!",
	YellPhase2		= "¡Ahora sentid el poder sin fin de mi maestro y desesperad!",
	YellAirphaseDem		= "Rikk zilthuras rikk zila Aman adare tiriosh ",--Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	YellPhase2Dem		= "Zar kiel xi romathIs zilthuras revos ruk toralar ",--Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	BeaconIconSet		= "Icono {rt%d} de Señal de Escarcha en %s",
	AchievementWarning	= "Aviso: %s tiene 5 acumulaciones de Sacudida mística",
	AchievementFailed	= ">> LOGRO FALLADO: %s tiene %d acumulaciones de Sacudida mística <<"
}

--------------------
-- El Rey Exánime --
--------------------
L = DBM:GetModLocalization("LichKing")

L:SetGeneralLocalization{
	name = "El Rey Exánime"
}

L:SetWarningLocalization{
	ValkyrWarning			= "¡>%s< ha sido agarrado!",
	SpecWarnYouAreValkd		= "¡Te han agarrado!!",
	WarnNecroticPlagueJump	= "Plaga necrótica salta a >%s<",
	SpecWarnValkyrLow		= "Val'kyr por debajo del 55%"
}

L:SetTimerLocalization{
	TimerRoleplay		= "Diálogo",
	PhaseTransition		= "Intermedio",
	TimerNecroticPlagueCleanse = "Purgar Plaga necrótica"
}

L:SetOptionLocalization{
	TimerRoleplay			= "Mostrar temporizador para los diálogos",
	WarnNecroticPlagueJump	= "Anunciar objetivos de los saltos de $spell:70337",
	TimerNecroticPlagueCleanse	= "Mostrar temporizador para purgar Plaga necrótica antes del primer pulso",
	PhaseTransition			= "Mostrar duración de los intermedios",
	ValkyrWarning			= "Anunciar jugadores agarrados por las Guardias de las Sombras Val'kyr",
	SpecWarnYouAreValkd		= "Mostrar aviso especial cuando te agarrae una Guardia de las Sombras Val'kyr",--npc36609
	DefileIcon				= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(72762),
	NecroticPlagueIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(70337),
	RagingSpiritIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(69200),
	TrapIcon				= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(73539),
	HarvestSoulIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(68980),
	AnnounceValkGrabs		= "Anunciar jugadores agarrados por las Guardias de las Sombras Val'kyr en el chat de banda (requiere líder o ayudante)",
	SpecWarnValkyrLow		= "Mostrar aviso especial cuando una Guardia de las Sombras Val'kyr esté por debajo del 55% de salud",
	AnnouncePlagueStack		= "Anunciar acumulaciones de $spell:70337 en el chat de banda (al llegar a 10 y tras cada 5; requiere líder o ayudante)"
}

L:SetMiscLocalization{
	LKPull					= "¿Así que por fin ha llegado la elogiada justicia de la Luz? ¿Debería deponer la Agonía de Escarcha y confiar en tu piedad, Vadín?",
	LKRoleplay				= "¿Me pregunto si de verdad os mueve la... rectitud?",
	ValkGrabbedIcon			= "Una Val'kyr ha agarrado a %s {rt%d}",
	ValkGrabbed				= "Una Val'kyr ha agarrado a %s",
	PlagueStackWarning		= "Aviso: %s tiene %d acumulaciones de Peste necrótica",
	AchievementCompleted	= ">> LOGRO COMPLETADO: %s tiene %d acumulaciones de Plaga necrótica <<"
}

----------------------
-- Enemigos menores --
----------------------
L = DBM:GetModLocalization("ICCTrash")

L:SetGeneralLocalization{
	name = "Enemigos menores"
}

L:SetWarningLocalization{
	SpecWarnTrapL		= "Trampa activada - ¡se ha liberado un Depositario vinculado a la muerte!",
	SpecWarnTrapP		= "Trampa activada - ¡se aproximan Siegacarnes vengativos!",
	SpecWarnGosaEvent	= "¡Emboscada de Sindragosa iniciada!"
}

L:SetOptionLocalization{
	SpecWarnTrapL		= "Mostrar aviso especial cuando se active una trampa de Depositario vinculado a la muerte",
	SpecWarnTrapP		= "Mostrar aviso especial cuando se active una trampa de Siegacarnes vengativos",
	SpecWarnGosaEvent	= "Mostrar aviso especial cuando comience el evento de la emboscada de Sindragosa"
}

L:SetMiscLocalization{
	WarderTrap1			= "¿Quién... anda ahí?",
	WarderTrap2			= "Estoy despierto...",
	WarderTrap3			= "El sagrario del maestro ha sido perturbado.",
	FleshreaperTrap1	= "Rápido, ¡atacaremos por la espalda!",
	FleshreaperTrap2	= "¡No... puedes escapar!",
	FleshreaperTrap3	= "¿Los vivos? ¿¡Aquí!?",
	SindragosaEvent		= "No debéis acercaros a la Reina de Escarcha. ¡Detenedlos, rápido!"
}

----------------------
-- El Sagrario Rubí --
----------------------
-----------------------------
-- Baltharus el Batallante --
-----------------------------
L = DBM:GetModLocalization("Baltharus")

L:SetGeneralLocalization({
	name = "Baltharus el Batallante"
})

L:SetWarningLocalization({
	WarningSplitSoon	= "Separación en breve"
})

L:SetOptionLocalization({
	WarningSplitSoon	= "Mostrar aviso previo para la separación de banda"
})

----------------------------
-- Saviana Furia Ardiente --
----------------------------
L = DBM:GetModLocalization("Saviana")

L:SetGeneralLocalization({
	name = "Saviana Furia Ardiente"
})

------------------------
-- General Zarithrian --
------------------------
L = DBM:GetModLocalization("Zarithrian")

L:SetGeneralLocalization({
	name = "General Zarithrian"
})

L:SetWarningLocalization({
	WarnAdds	= "Ónices clamallamas",
	warnCleaveArmor	= "%s en >%s< (%s)"		-- Cleave Armor on >args.destName< (args.amount)
})

L:SetTimerLocalization({
	TimerAdds	= "Siguientes Ónices clamallamas"
})

L:SetOptionLocalization({
	WarnAdds		= "Anunciar cuando aparezcan Ónices clamallamas",
	TimerAdds		= "Mostrar temporizador para los siguientes Ónices clamallamas",
	warnCleaveArmor	= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(74367)
})

L:SetMiscLocalization({
	SummonMinions	= "¡Reducidlos a cenizas, esbirros!"
})

------------
-- Halion --
------------
L = DBM:GetModLocalization("Halion")

L:SetGeneralLocalization({
	name = "Halion"
})

L:SetWarningLocalization({
	TwilightCutterCast	= "Lanzando Corte Crepuscular en 5 s"
})

L:SetOptionLocalization({
	TwilightCutterCast		= "Mostrar aviso cuando se esté lanzando $spell:74769",
	AnnounceAlternatePhase	= "Mostrar avisos y temporizadores que no pertenezcan a tu fase actual"
})

L:SetMiscLocalization({
	Halion					= "Halion",
	MeteorCast				= "¡Los cielos arden!",
	Phase2					= "En el reino del crepúsculo solo encontraréis sufrimiento. ¡Entrad si os atrevéis!",
	Phase3					= "¡Yo soy la luz y la oscuridad! ¡Temed, mortales, la llegada de Alamuerte!",
	twilightcutter			= "¡Las esferas que orbitan emiten energía oscura!",
	Kill					= "Disfrutad la victoria, mortales, porque será la última. ¡Este mundo arderá cuando vuelva el maestro!"
})
