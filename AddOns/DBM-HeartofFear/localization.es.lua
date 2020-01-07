if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then
	return
end
local L

----------------------------
-- Visir imperial Zor'lok --
----------------------------
L = DBM:GetModLocalization(745)

L:SetWarningLocalization({
	warnEcho			= "Ha aparecido un eco",
	warnEchoDown		= "Eco abatido",
	specwarnAttenuation	= "%s en %s (%s)",
	specwarnPlatform	= "Cambio de plataforma"
})

L:SetOptionLocalization({
	warnEcho			= "Anunciar cuando aparezca un eco",
	warnEchoDown		= "Anunciar cuando se derrote a un eco",
	specwarnAttenuation	= DBM_CORE_AUTO_SPEC_WARN_OPTIONS.spell:format(127834),
	specwarnPlatform	= "Mostrar aviso especial cuando el jefe cambie de plataforma",
	ArrowOnAttenuation	= "Mostrar flecha durante $spell:127834 para indicar la dirección en que moverse",
	MindControlIcon		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(122740)
})

L:SetMiscLocalization({
	Platform	= "¡El visir imperial Zor'lok vuela hacia una de las plataformas!",
	Defeat		= "No sucumbiremos ante la desesperación del vacío oscuro. Si Ella desea que perezcamos, así lo haremos."
})

------------
-- Ta'yak --
------------
L = DBM:GetModLocalization(744)

L:SetOptionLocalization({
	UnseenStrikeArrow	= DBM_CORE_AUTO_ARROW_OPTION_TEXT:format(122949),
	RangeFrame			= DBM_CORE_AUTO_RANGE_OPTION_TEXT:format(10, 123175)
})

-------------
-- Garalon --
-------------
L = DBM:GetModLocalization(713)

L:SetWarningLocalization({
	warnCrush		= "%s",
	specwarnUnder	= "¡Sal del círculo púrpura!"
})

L:SetOptionLocalization({
	warnCrush		= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format(122774),
	specwarnUnder	= "Mostrar aviso especial cuando estés debajo del jefe",
	PheromonesIcon	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(122835)
})

L:SetMiscLocalization({
	UnderHim	= "debajo de sí",
	Phase2		= "¡La enorme coraza de Garalon empieza a agrietarse y romperse!"
})

--------------------------------
-- Señor del viento Mel'jarak --
--------------------------------
L = DBM:GetModLocalization(741)

L:SetOptionLocalization({
	AmberPrisonIcons		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(121885),
	specWarnReinforcements	= DBM_CORE_AUTO_SPEC_WARN_OPTIONS.spell:format("ej6554")
})

------------------------------
-- Formador de ámbar Un'sok --
------------------------------
L = DBM:GetModLocalization(737)

L:SetWarningLocalization({
	warnReshapeLife				= "%s en >%s< (%d)",--Localized because i like class colors on warning and shoving a number into targetname broke it using the generic.
	warnReshapeLifeTutor		= "1: Interrumpir/perjuicio al objetivo (úsalo en el jefe para acumular el perjuicio), 2: Interrumpir tu propia Deflagración de ámbar, 3: Restaurar voluntad cuando te quede poca (úsalo principalmente en la fase 3), 4: Salir del vehículo (solo en las dos primeras fases)",
	warnAmberExplosion			= ">%s< está lanzando %s",
	warnAmberExplosionAM		= "La Monstruosidad de ámbar está lanzando Deflagración de ámbar - ¡interrumpe ahora!",--personal warning.
	warnInterruptsAvailable		= "Interrupciones disponibles para %s: >%s<",
	warnWillPower				= "Voluntad restante: %s",
	specwarnWillPower			= "Voluntad baja - ¡sal del vehículo o consume un charco!",
	specwarnAmberExplosionYou	= "¡Interrumpe tu propia %s!",--Struggle for Control interrupt.
	specwarnAmberExplosionAM	= "%s - ¡interrumpe a la %s!",--Amber Montrosity
	specwarnAmberExplosionOther	= "%s - ¡interrumpe al %s!"--Mutated Construct
})

L:SetTimerLocalization({
	timerDestabalize		= "Desestabilizar (%2$d) : %1$s",
	timerAmberExplosionAMCD	= "Deflagración (Monstruosidad) TdR"
})

L:SetOptionLocalization({
	warnReshapeLife				= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.target:format(122784),
	warnReshapeLifeTutor		= "Mostrar explicación de facultades del Ensamblaje mutado",
	warnAmberExplosion			= "Mostrar aviso (y quién lo lanza) cuando $spell:122398 se esté lanzando",
	warnAmberExplosionAM		= "Mostrar aviso personal cuando la Monstruosidad de ámbar lance $spell:122398 (para interrumpirla)",
	warnInterruptsAvailable		= "Anunciar jugadores mutados con Golpe de ámbar disponible para interrumpir $spell:122402",
	warnWillPower				= "Anunciar voluntad restante cuando quede 80, 50, 30, 10, ó 4.",
	specwarnWillPower			= "Mostrar aviso especial cuando a tu ensamblaje le quede poca voluntad",
	specwarnAmberExplosionYou	= "Mostrar aviso especial para interrumpir tu propia $spell:122398",
	specwarnAmberExplosionAM	= "Mostrar aviso especial para interrumpir la $spell:122402 de la Monstruosidad de ámbar",
	specwarnAmberExplosionOther	= "Mostrar aviso especial para interrumpir la $spell:122398 de los Ensamblajes mutados descontrolados",
	timerDestabalize			= DBM_CORE_AUTO_TIMER_OPTIONS.target:format(123059),
	timerAmberExplosionAMCD		= "Mostrar temporizador para la siguiente $spell:122402 de la Monstruosidad de ámbar",
	InfoFrame					= "Mostrar marco de información de la voluntad de los jugadores",
	FixNameplates				= "Ocultar automáticamente las placas de nombres irrelevantes mientras estés mutado (se restaurarán automáticamente al terminar el encuentro)"
})

L:SetMiscLocalization({
	WillPower	= "Voluntad"
})

-------------------------------
-- Gran emperatriz Shek'zeer --
-------------------------------
L = DBM:GetModLocalization(743)

L:SetWarningLocalization({
	warnAmberTrap	= "Trampa de ámbar: %d/5 resinas"
})

L:SetOptionLocalization({
	warnAmberTrap		= "Mostrar aviso (con progreso) cuando se esté creando una $spell:125826",
	InfoFrame			= "Mostrar marco de información de jugadores afectados por $spell:125390",
	RangeFrame			= DBM_CORE_AUTO_RANGE_OPTION_TEXT:format(5, 123735),
	StickyResinIcons	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(124097),
	HeartOfFearIcon		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(123845)
})

L:SetMiscLocalization({
	PlayerDebuffs	= "Fijar",
	YellPhase3		= "¡Se acabaron las excusas, Emperatriz! ¡Acaba con estos despreciables o te mataré yo mismo!"
})

------------------------
--  Enemigos menores  --
------------------------
L = DBM:GetModLocalization("HoFTrash")

L:SetGeneralLocalization({
	name	= "Enemigos menores"
})

L:SetOptionLocalization({
	UnseenStrikeArrow	= "Mostrar flecha cuando un jugador esté afectado por $spell:122949"
})
