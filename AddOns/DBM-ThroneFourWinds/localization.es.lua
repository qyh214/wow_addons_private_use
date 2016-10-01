if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

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
	LightningRodIcon= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(89668),
	TimerFeedback	= "Mostrar temporizador para la duración de $spell:87904",
	RangeFrame		= "Mostrar marco de distancia (20 m) cuando estés afectado por $spell:89668"
})
