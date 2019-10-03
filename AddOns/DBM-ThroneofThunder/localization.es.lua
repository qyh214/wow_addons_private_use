if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then
	return
end
local L

--------------------------
-- Jin'rokh el Rompedor --
--------------------------
L = DBM:GetModLocalization(827)

L:SetWarningLocalization({
	specWarnWaterMove	= "%s en breve - ¡sal de Agua conductiva!"
})

L:SetOptionLocalization({
	specWarnWaterMove	= "Mostrar aviso especial para salir de $spell:138470 (avisa antes de $spell:137313 o cuando el perjuicio de $spell:138732 esté a punto de expirar)",
	RangeFrame			= DBM_CORE_AUTO_RANGE_OPTION_TEXT_SHORT:format("8/4")
})

----------------
-- Horridonte --
----------------
L = DBM:GetModLocalization(819)

L:SetWarningLocalization({
	warnAdds				= "%s",
	warnOrbofControl		= "Orbe de control en el suelo",
	specWarnOrbofControl	= "¡Orbe de control en el suelo!"
})

L:SetTimerLocalization({
	timerDoor	= "Siguiente puerta tribal",
	timerAdds	= "Siguiente %s"
})

L:SetOptionLocalization({
	warnAdds				= "Anunciar cuando aparezcan esbirros",
	warnOrbofControl		= "Anunciar cuando un $journal:7092 cae al suelo",
	specWarnOrbofControl	= "Mostrar aviso especial cuando un $journal:7092 cae al suelo",
	timerDoor				= "Mostrar temporizador para la apertura de la siguiente puerta tribal",
	timerAdds				= "Mostrar temporizador para los siguientes esbirros",
	SetIconOnAdds			= "Poner iconos en los esbirros de las gradas",
	RangeFrame				= DBM_CORE_AUTO_RANGE_OPTION_TEXT:format(5, 136480),
	SetIconOnCharge			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(136769)
})

L:SetMiscLocalization({
	newForces		= "salen en tropel desde",--Farraki forces pour from the Farraki Tribal Door!
	chargeTarget	= "fija la vista"--Horridon sets his eyes on Eraeshio and stamps his tail!
})

-------------------------
-- Consejo de Ancianos --
-------------------------
L = DBM:GetModLocalization(816)

L:SetWarningLocalization({
	specWarnPossessed	= "%s en %s - ¡cambia de objetivo!"
})

L:SetOptionLocalization({
	warnPossessed		= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.target:format(136442),
	specWarnPossessed	= DBM_CORE_AUTO_SPEC_WARN_OPTIONS.switch:format(136442),
	RangeFrame			= DBM_CORE_AUTO_RANGE_OPTION_TEXT_SHORT:format(5),
	AnnounceCooldowns	= "Anunciar (con contador, hasta 3) los lanzamientos de $spell:137166 para el uso de facultades potentes de sanación",
	SetIconOnBitingCold	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(136992),
	SetIconOnFrostBite	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(136922)
})

------------
-- Tortos --
------------
L = DBM:GetModLocalization(825)

L:SetWarningLocalization({
	warnKickShell			= "%s usado por >%s< (%d restantes)",
	specWarnCrystalShell	= "Obtén %s"
})

L:SetOptionLocalization({
	warnKickShell			= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format(134031),
	specWarnCrystalShell	= "Mostrar aviso especial cuando no tengas el perjuicio de $spell:137633 y estés por encima del 90% de salud",
	InfoFrame				= "Mostrar marco de información de jugadores no afectados por $spell:137633",
	ClearIconOnTurtles		= "Quitar iconos de $journal:7129 cuando les afecte $spell:133971",
	AnnounceCooldowns		= "Anunciar $spell:134920 (con contador) para el uso de facultades potentes de sanación"
})

L:SetMiscLocalization({
	WrongDebuff	= "Sin %s"
})

-------------
-- Megaera --
-------------
L = DBM:GetModLocalization(821)

L:SetTimerLocalization({
	timerBreathsCD	= "Siguiente aliento"
})

L:SetOptionLocalization({
	timerBreaths			= "Mostrar temporizador para el siguiente aliento",
	SetIconOnCinders		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(139822),
	SetIconOnTorrentofIce	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(139889),
	AnnounceCooldowns		= "Anunciar Desenfreno (con contador) para el uso de facultades potentes de sanación",
	Never					= "Nunca",
	Every					= "Todos (consecutivo)",
	EveryTwo				= "Cada 2",
	EveryThree				= "Cada 3",
	EveryTwoExcludeDiff		= "Cada 2 (exceptuando Difusión)",
	EveryThreeExcludeDiff	= "Cada 3 (exceptuando Difusión)"
})

L:SetMiscLocalization({
	rampageEnds	= "La ira de Megaera amaina."
})

------------
-- Ji Kun --
------------
L = DBM:GetModLocalization(828)

L:SetWarningLocalization({
	warnFlock			= "%s - %s %s",
	specWarnFlock		= "%s - %s %s",
	specWarnBigBird		= "Guardián del nido (%s)",
	specWarnBigBirdSoon	= "Guardián del nido (%s) en breve"
})

L:SetTimerLocalization({
	timerFlockCD	= "Nido (%d): %s"
})

L:SetOptionLocalization({
	warnFlock			= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.count:format("ej7348"),
	specWarnFlock		= DBM_CORE_AUTO_SPEC_WARN_OPTIONS.switch:format("ej7348"),
	specWarnBigBird		= DBM_CORE_AUTO_SPEC_WARN_OPTIONS.switch:format("ej7827"),
	specWarnBigBirdSoon	= DBM_CORE_AUTO_SPEC_WARN_OPTIONS.soon:format("ej7827"),
	timerFlockCD		= DBM_CORE_AUTO_TIMER_OPTIONS.nextcount:format("ej7348"),
	RangeFrame			= DBM_CORE_AUTO_RANGE_OPTION_TEXT:format(10, 138923),
	ShowNestArrows		= "Mostrar flecha para nidos activos",
	Never				= "Nunca",
	Northeast			= "Azul - Noreste superior e inferior",
	Southeast			= "Verde - Sudeste superior e inferior",
	Southwest			= "Púrpura/Rojo - Sudoeste superior e inferior (25) o medio superior (10)",
	West				= "Rojo - Oeste inferior y medio superior (25)",
	Northwest			= "Amarillo - Noroeste superior e inferior (25)",
	Guardians			= "Nidos con guardianes del nido"
})

L:SetMiscLocalization({
	eggsHatch		= "empiezan a abrirse!",
	Upper			= "Arriba",
	Lower			= "Abajo",
	UpperAndLower	= "Arriba y abajo",
	TrippleD		= "Triple (dos abajo)",
	TrippleU		= "Triple (dos arriba)",
	NorthEast		= "|cff0000ffNoreste|r",--Blue
	SouthEast		= "|cFF088A08Sudeste|r",--Green
	SouthWest		= "|cFF9932CDSudoeste|r",--Purple
	West			= "|cffff0000Oeste|r",--Red
	NorthWest		= "|cffffff00Noroeste|r",--Yellow
	Middle10		= "|cFF9932CDMedio|r",--Purple (Middle is upper southwest on 10 man/LFR)
	Middle25		= "|cffff0000Medio|r",--Red (Middle is upper west on 25 man)
	ArrowUpper		= " |TInterface\\Icons\\misc_arrowlup:12:12|t ",
	ArrowLower		= " |TInterface\\Icons\\misc_arrowdown:12:12|t "
})

------------------------
-- Durumu el Olvidado --
------------------------
L = DBM:GetModLocalization(818)

L:SetWarningLocalization({
	warnBeamNormal				= "Luz - |cffff0000Roja|r : >%s<, |cff0000ffAzul|r : >%s<",
	warnBeamHeroic				= "Luz - |cffff0000Roja|r : >%s<, |cff0000ffAzul|r : >%s<, |cffffff00Amarilla|r : >%s<",
	warnAddsLeft				= "Nieblas restantes: %d",
	specWarnBlueBeam			= "Luz azul en ti - ¡no te muevas!",
	specWarnFogRevealed			= "¡%s revelada!",
	specWarnDisintegrationBeam	= "%s (%s)"
})

L:SetOptionLocalization({
	warnBeam					= "Anunciar objetivos de los haces de luz",
	warnAddsLeft				= "Anunciar el número de nieblas restantes",
	specWarnFogRevealed			= "Mostrar aviso especial cuando se revele una niebla",
	specWarnBlueBeam			= DBM_CORE_AUTO_SPEC_WARN_OPTIONS.spell:format(139202),
	specWarnDisintegrationBeam	= DBM_CORE_AUTO_SPEC_WARN_OPTIONS.spell:format("ej6882"),
	ArrowOnBeam					= "Mostrar flecha durante $journal:6882 para indicar la dirección en que moverse",
	SetIconRays					= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format("ej6891"),
	SetIconLifeDrain			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(133795),
	SetIconOnParasite			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(133597),
	InfoFrame					= "Mostrar marco de información para las acumulaciones de $spell:133795",
	SetParticle					= "Cambiar automáticamente la opción gráfica de densidad de partículas a bajo al iniciar el encuentro (se restaurará al terminar el encuentro)"
})

L:SetMiscLocalization({
	LifeYell	= "Drenaje de vida en %s (%d)"
})

----------------
-- Primordius --
----------------
L = DBM:GetModLocalization(820)

L:SetWarningLocalization({
	warnDebuffCount	= "Mutaciones: %d/5 buenas, %d malas"
})

L:SetOptionLocalization({
	warnDebuffCount		= "Mostrar aviso (con contador) de perjuicios de mutación al absorber charcos",
	RangeFrame			= DBM_CORE_AUTO_RANGE_OPTION_TEXT_SHORT:format("5/3"),
	SetIconOnBigOoze	= "Poner icono en $journal:6969"
})

-------------------
-- Animus oscuro --
-------------------
L = DBM:GetModLocalization(824)

L:SetWarningLocalization({
	warnMatterSwapped	= "%s: >%s< y >%s< intercambiados"
})

L:SetOptionLocalization({
	warnMatterSwapped	= "Anunciar objetivos intercambiados por $spell:138618",
	SetIconOnFont		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(138707)
})

L:SetMiscLocalization({
	Pull	= "¡El orbe explota!"
})

------------------
-- Qon el Tenaz --
------------------
L = DBM:GetModLocalization(817)

L:SetWarningLocalization({
	warnDeadZone	= "%s: escudado en %s / %s"
})

L:SetOptionLocalization({
	warnDeadZone			= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format(137229),
	SetIconOnLightningStorm	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(136192),
	RangeFrame				= "Mostrar marco de distancia (10 m) dinámico (se mostrará si hay demasiados jugadores demasiado juntos)",
	InfoFrame				= "Mostrar marco de información de jugadores afectados por el perjuicio de $spell:136193"
})

-----------------------
-- Consortes Gemelas --
-----------------------
L = DBM:GetModLocalization(829)

L:SetWarningLocalization({
	warnNight	= "Fase de la noche",
	warnDay		= "Fase del día",
	warnDusk	= "Fase del ocaso"
})

L:SetTimerLocalization({
	timerDayCD	= "Siguiente fase del día",
	timerDuskCD	= "Siguiente fase del ocaso"
})

L:SetOptionLocalization({
	warnNight	= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format("ej7641"),
	warnDay		= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format("ej7645"),
	warnDusk	= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format("ej7633"),
	timerDayCD	= DBM_CORE_AUTO_TIMER_OPTIONS.next:format("ej7645"),
	timerDuskCD	= DBM_CORE_AUTO_TIMER_OPTIONS.next:format("ej7633"),
	RangeFrame	= DBM_CORE_AUTO_RANGE_OPTION_TEXT_SHORT:format(5)
})

L:SetMiscLocalization({
	DuskPhase	= "¡Lu'lin! ¡Préstame tu fuerza!"
})

--------------
-- Lei Shen --
--------------
L = DBM:GetModLocalization(832)

L:SetWarningLocalization({
	specWarnIntermissionSoon	= "Intermedio en breve",
	warnDiffusionChainSpread	= "%s salta a >%s<"
})

L:SetTimerLocalization({
	timerConduitCD	= "Primera facultad de conducto TdR"
})

L:SetOptionLocalization({
	specWarnIntermissionSoon	= "Mostrar aviso especial previo para los intermedios",
	warnDiffusionChainSpread	= "Anunciar objetivos de los saltos de $spell:135991",
	timerConduitCD				= "Mostrar temporizador para el tiempo de reutilización de la primera facultad de conducto",
	RangeFrame					= DBM_CORE_AUTO_RANGE_OPTION_TEXT_SHORT:format("8/6"),--For two different spells
	StaticShockArrow			= "Mostrar flecha cuando un jugador esté afectado por $spell:135695",
	OverchargeArrow				= "Mostrar flecha cuando un jugador esté afectado por $spell:136295",
	SetIconOnOvercharge			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(136295),
	SetIconOnStaticShock		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(135695)
})

L:SetMiscLocalization({
	StaticYell	= "Choque estático en %s (%d)"
})

------------
-- Ra Den --
------------
L = DBM:GetModLocalization(831)

L:SetWarningLocalization({
	specWarnUnstablVitaJump	= "¡Vita inestable salta a ti!"
})

L:SetOptionLocalization({
	specWarnUnstablVitaJump	= "Mostrar aviso especial cuando $spell:138297 salta a ti",
	SetIconsOnVita			= "Poner iconos en jugadores afectados por el perjuicio de $spell:138297 y el jugador más alejado de ellos"
})

L:SetMiscLocalization({
	Defeat	= "¡Esperad!"
})

------------------------
--  Enemigos menores  --
------------------------
L = DBM:GetModLocalization("ToTTrash")

L:SetGeneralLocalization({
	name	= "Enemigos menores"
})

L:SetOptionLocalization({
	RangeFrame	= DBM_CORE_AUTO_RANGE_OPTION_TEXT_SHORT:format(10)--For 3 different spells
})