if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

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
	BlackoutIcon			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(86788),
	EngulfingIcon			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(86622)
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
	HeartIceIcon			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(82665),
	BurningBloodIcon		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(82660),
	LightningRodIcon		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(83099),
	GravityCrushIcon		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(84948),
	FrostBeaconIcon			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(92307),
	StaticOverloadIcon		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(92067),
	GravityCoreIcon			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(92075)
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
	SetIconOnWorship		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(91317)
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
