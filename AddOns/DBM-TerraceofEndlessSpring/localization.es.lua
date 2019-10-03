if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then
	return
end
local L

---------------------------------
-- Protectores de la Eternidad --
---------------------------------
L = DBM:GetModLocalization(683)

L:SetWarningLocalization({
	warnGroupOrder		= "Interceptar esbirros: Grupo %s",
	specWarnYourGroup	= "Le toca a tu grupo - ¡intercepta a los esbirros!"
})

L:SetOptionLocalization({
	warnGroupOrder		= "Anunciar rotación de grupos para $spell:118191 (por ahora solo para 25 jugadores con la estrategia de 5, 2, 2, 2)",
	specWarnYourGroup	= "Mostrar aviso especial cuando a tu grupo le toque interceptar $spell:118191 (25 jugadores)",
	RangeFrame			= DBM_CORE_AUTO_RANGE_OPTION_TEXT:format(8, 111850) .. " (muestra a todos los jugadores si tienes el perjuicio, o solo a los jugadores con el perjuicio si no estás afectado)",
	SetIconOnPrison		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(117436)
})

-------------
-- Tsulong --
-------------
L = DBM:GetModLocalization(742)

L:SetOptionLocalization({
	warnLightOfDay	= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.target:format(123716)
})

L:SetMiscLocalization{
	Victory	= "Gracias, forasteros. Me habéis liberado."
}

-------------
-- Lei Shi --
-------------
L = DBM:GetModLocalization(729)

L:SetWarningLocalization({
	warnHideOver	= "%s ha terminado"
})

L:SetTimerLocalization({
	timerSpecialCD	= "Facultad especial (%d) TdR"
})

L:SetOptionLocalization({
	warnHideOver	= "Mostrar aviso cuando termine $spell:123244",
	timerSpecialCD	= "Mostrar temporizador para el tiempo de reutilización de las facultades especiales",
	RangeFrame		= DBM_CORE_AUTO_RANGE_OPTION_TEXT:format(3, 123121) .. " (muestra a todos durante Ocultar, y solo a los tanques el resto del tiempo)"
})

L:SetMiscLocalization{
	Victory	= "Yo... ah... ¿eh? ¿Yo he...? ¿Era yo...? Todo... estaba... turbio."--wtb alternate and less crappy victory event.
}

-------------------
-- Sha del miedo --
-------------------
L = DBM:GetModLocalization(709)

L:SetWarningLocalization({
	MoveForward					= "Ve adelante",
	MoveRight					= "Ve a la derecha",
	MoveBack					= "Ve a tu posición anterior",
	specWarnBreathOfFearSoon	= "Aliento de miedo en breve - ¡ve al muro!"
})

L:SetTimerLocalization({
	timerSpecialAbilityCD	= "Siguiente habilidad especial",
	timerSpoHudCD			= "Terror / Aspersor TdR",
	timerSpoStrCD			= "Aspersor / Golpe TdR",
	timerHudStrCD			= "Terror / Golpe TdR"
})

L:SetOptionLocalization({
	warnThrash					= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format(131996),
	warnBreathOnPlatform		= "Mostrar aviso para $spell:119414 al estar en los santuarios (no recomendable salvo que seas el líder de la banda)",
	specWarnBreathOfFearSoon	= "Mostrar aviso especial previo para $spell:119414 si no estás afectado por el beneficio de $spell:117964",
	specWarnMovement			= "Mostrar aviso especial para esquivar durante $spell:120047",
	timerSpecialAbility			= "Mostrar temporizador para la siguiente habilidad especial",
	RangeFrame					= DBM_CORE_AUTO_RANGE_OPTION_TEXT:format(2, 119519),
	SetIconOnHuddle				= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(120629)
})