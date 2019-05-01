if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

-----------------
-- Beth'tilac --
-----------------
L= DBM:GetModLocalization(192)

L:SetOptionLocalization({
	RangeFrame			= "Mostrar marco de distancia (10 m)"
})

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
	TimerHatchEggs		= "Mostrar temporizador para la eclosión de huevos",
	InfoFrame			= "Mostrar marco de información para $spell:98734"
})

L:SetMiscLocalization({
	YellPull		= "¡Mortales, ahora sirvo a un nuevo amo!",
	YellPhase2		= "¡Estos cielos son MÍOS!",
	FullPower		= "spell:99925",--This is in the emote, shouldn't need localizing, just msg:find
	LavaWorms		= "¡Gusanos de lava ígneos surgen del suelo!",--Might use this one day if i feel it needs a warning for something. Or maybe pre warning for something else (like transition soon)
	East			= "este",
	West			= "oeste",
	Both			= "ambos"
})

-------------
-- Shannox --
-------------
L= DBM:GetModLocalization(195)

L:SetOptionLocalization({
	SetIconOnFaceRage	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(99947),
	SetIconOnRage		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(100415)
})

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
	TimerBladeNext		= "Mostrar temporizador para el siguiente cambio de hoja",
	SetIconOnCountdown	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(99516),
	SetIconOnTorment	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(99256),
	InfoFrame			= "Mostrar marco de información para las acumulaciones de $spell:99262",
	RangeFrame			= "Mostrar marco de distancia (5 m) para $spell:99257"
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
	RangeFrameCat				= "Mostrar marco de distancia (10 m) para $spell:98374",
	IconOnLeapingFlames			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(98476)
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
	warnRageRagnarosSoon		= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.prewarn:format(101109),
	warnSplittingBlow			= "Mostrar avisos de ubicación para $spell:98951",
	warnEngulfingFlame			= "Mostrar avisos de ubicación para $spell:99171 en dificultad normal",
	warnEngulfingFlameHeroic	= "Mostrar avisos de ubicación para $spell:99171 en dificultad heroica",
	warnSeedsLand				= "Mostrar temporizador y aviso para $spell:98520 en función de cuando aterricen las semillas en lugar de cuando ocurra el lanzamiento",
	warnEmpoweredSulf			= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.cast:format(100604),
	timerRageRagnaros			= DBM_CORE_AUTO_TIMER_OPTIONS.cast:format(101109),
	TimerPhaseSons				= "Mostrar temporizador de duración para los intermedios de Hijos de la llama",
	RangeFrame					= "Mostrar marco de distancia",
	InfoHealthFrame				= "Mostrar marco de información de salud (por debajo de 100mil)",
	MeteorFrame					= "Mostrar marco de información de objetivos de $spell:99849",
	AggroFrame					= "Mostrar marco de información de jugadores sin amenaza durante $journal:2647",
	BlazingHeatIcons			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(100460)
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
