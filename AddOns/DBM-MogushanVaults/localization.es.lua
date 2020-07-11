if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then
	return
end
local L

--------------------------
-- La guardia de piedra --
--------------------------
L = DBM:GetModLocalization(679)

L:SetWarningLocalization({
	SpecWarnOverloadSoon		= "¡%s en breve!", -- prepare survival ablility or move boss. need more specific message.
	specWarnBreakJasperChains	= "¡Rompe las cadenas de jaspe!"
})

L:SetOptionLocalization({
	SpecWarnOverloadSoon		= "Mostrar aviso especial antes de Sobrecarga", -- need to change this, i can not translate this with good grammer. please help.
	specWarnBreakJasperChains	= "Mostrar aviso especial cuando sea seguro romper $spell:130395",
	InfoFrame					= "Mostrar marco de información con la energía de los jefes, petrificación de los jugadores y qué jefe está lanzando la petrificación"
})

L:SetMiscLocalization({
	Overload	= "¡%s se empieza a sobrecargar!"
})

------------------------
-- Feng el Detestable --
------------------------
L = DBM:GetModLocalization(689)

L:SetWarningLocalization({
	WarnPhase			= "Fase %d",
	specWarnBarrierNow	= "¡Usa Barrera anuladora ahora!"
})

L:SetOptionLocalization({
	WarnPhase			= "Anunciar cambios de fase",
	specWarnBarrierNow	= "Mostrar aviso especial cuando debas usar $spell:115817 (buscador de bandas)",
	RangeFrame	= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT_SHORT:format("6") .. " durante la fase Arcana",
	SetIconOnWS	= DBM_CORE_L.AUTO_ICONS_OPTION_TEXT:format(116784),
	SetIconOnAR	= DBM_CORE_L.AUTO_ICONS_OPTION_TEXT:format(116417)
})

L:SetMiscLocalization({
	Fire	= "¡Oh, exaltado! ¡Soy tu herramienta para desgarrar la carne de los huesos!",
	Arcane	= "¡Oh, sabio eterno! ¡Transmíteme tu sapiencia Arcana!",
	Nature	= "¡Oh, gran espíritu! ¡Otórgame el poder de la tierra!",--I did not log this one, text is probably not right
	Shadow	= "¡Almas de campeones antiguos! ¡Concededme vuestro escudo!"
})

--------------
-- Gara'jal --
--------------
L = DBM:GetModLocalization(682)

L:SetOptionLocalization({
	SetIconOnVoodoo	= DBM_CORE_L.AUTO_ICONS_OPTION_TEXT:format(122151)
})

L:SetMiscLocalization({
	Pull	= "¡Ya es hora de morir!"
})

------------------------
-- Los Reyes Espíritu --
------------------------
L = DBM:GetModLocalization(687)

L:SetWarningLocalization({
	DarknessSoon	= "Escudo de la oscuridad en %d s"
})

L:SetTimerLocalization({
	timerUSRevive		= "Sombra imperecedera se reforma",
	timerRainOfArrowsCD	= "%s"
})

L:SetOptionLocalization({
	DarknessSoon		= "Mostrar aviso previo con cuenta atrás de 5 s para $spell:117697",
	timerUSRevive		= "Mostrar temporizador para cuando $spell:117506 se reforme",
	timerRainOfArrowsCD = DBM_CORE_L.AUTO_TIMER_OPTIONS.cd:format(118122),
	RangeFrame			= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT_SHORT:format("8")
})

------------
-- Elegon --
------------
L = DBM:GetModLocalization(726)

L:SetWarningLocalization({
	specWarnDespawnFloor	= "¡La plataforma desaparecerá en 6 s!"
})

L:SetTimerLocalization({
	timerDespawnFloor	= "La plataforma desaparece"
})

L:SetOptionLocalization({
	specWarnDespawnFloor	= "Mostrar aviso especial antes de que desaparezca la plataforma",
	timerDespawnFloor		= "Mostrar temporizador para la desaparición de la plataforma",
	SetIconOnDestabilized	= DBM_CORE_L.AUTO_ICONS_OPTION_TEXT:format(132222)
})

----------------------------
-- Voluntad del Emperador --
----------------------------
L = DBM:GetModLocalization(677)

L:SetOptionLocalization({
	InfoFrame		= "Mostrar marco de información de jugadores afectados por $spell:116525",
	CountOutCombo	= "Contar lanzamientos de $journal:5673",
	ArrowOnCombo	= "Mostrar flecha durante $journal:5673 (asumiendo que el jefe tiene al tanque delante y el resto de la banda a sus espaldas)"
})

L:SetMiscLocalization({
	Pull		= "¡La máquina vuelve a la vida! ¡Baja el nivel inferior!",--Emote
	Rage		= "La ira del Emperador resuena por las colinas.",--Yell
	Strength	= "¡La fuerza del Emperador aparece en la habitación!",--Emote
	Courage		= "¡El coraje del Emperador aparece en la habitación!",--Emote
	Boss		= "¡Aparecen dos construcciones titánicas en las enormes habitaciones!"--Emote
})
