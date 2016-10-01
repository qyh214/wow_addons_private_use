if GetLocale() ~= "esES" or GetLocale() ~= "esMX" then return end
local L

-----------------
--  Najentus  --
-----------------
L = DBM:GetModLocalization("Najentus")

L:SetGeneralLocalization{
	name = "Gran señor de la guerra Naj'entus"
}

L:SetOptionLocalization{
	InfoFrame	= "Mostrar marco de información de salud de los jugadores (por debajo de 8,8mil de salud)",
	RangeFrame	= DBM_CORE_AUTO_RANGE_OPTION_TEXT_SHORT:format(8),
	SpineIcon	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(39837)
}

L:SetMiscLocalization{
	HealthInfo	= "Salud de los jugadores"
}

----------------
-- Supremus --
----------------
L = DBM:GetModLocalization("Supremus")

L:SetGeneralLocalization{
	name = "Supremus"
}

L:SetWarningLocalization{
	WarnPhase		= "Fase de %s",
	WarnKite		= "Mirada en >%s<"
}

L:SetTimerLocalization{
	TimerPhase		= "Siguiente fase de %s"
}

L:SetOptionLocalization{
	WarnPhase		= "Anunciar cambios de fase",
	WarnKite		= "Anunciar objetivos de Mirada",
	TimerPhase		= "Mostrar temporizador para los cambios de fase",
	KiteIcon		= "Poner icono en el objetivo de Mirada"
}

L:SetMiscLocalization{
	PhaseKite		= "golpea el suelo enfadado!",
	PhaseTank		= "El suelo comienza a abrirse.",
	ChangeTarget	= "adquiere un nuevo objetivo!",
	Kite			= "persecución",
	Tank			= "tanqueo"
}

-------------------------
--  Shape of Akama  --
-------------------------
L = DBM:GetModLocalization("Akama")

L:SetGeneralLocalization{
	name = "Sombra de Akama"
}

-------------------------
--  Teron Gorefiend  --
-------------------------
L = DBM:GetModLocalization("TeronGorefiend")

L:SetGeneralLocalization{
	name = "Teron Sanguino"
}

L:SetTimerLocalization{
	TimerVengefulSpirit		= "Fantasma: %s"
}

L:SetOptionLocalization{
	TimerVengefulSpirit		= "Mostrar temporizador para la duración de la forma de fantasma",
	CrushIcon				= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(40243)
}

----------------------------
--  Gurtogg Bloodboil  --
----------------------------
L = DBM:GetModLocalization("Bloodboil")

L:SetGeneralLocalization{
	name = "Gurtogg Sangre Hirviente"
}

--------------------------
--  Essence Of Souls  --
--------------------------
L = DBM:GetModLocalization("Souls")

L:SetGeneralLocalization{
	name = "Relicario de Almas"
}

L:SetWarningLocalization{
	WarnMana		= "Sin maná en 30 s"
}

L:SetTimerLocalization{
	TimerMana		= "Sin maná"
}

L:SetOptionLocalization{
	WarnMana		= "Mostrar aviso previo para cuando el maná máximo de los jugadores llegue a cero en Fase 2",
	TimerMana		= "Mostrar temporizador para cuando el maná máximo de los jugadores llegue a cero en Fase 2",
	DrainIcon		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(41303),
	SpiteIcon		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(41376)
}

L:SetMiscLocalization{
	Suffering		= "Esencia de sufrimiento",
	Desire			= "Esencia de deseo",
	Anger			= "Esencia de inquina"
}

-----------------------
--  Mother Shahraz --
-----------------------
L = DBM:GetModLocalization("Shahraz")

L:SetGeneralLocalization{
	name = "Madre Shahraz"
}

L:SetTimerLocalization{
	timerAura	= "%s"
}

L:SetOptionLocalization{
	timerAura	= "Mostrar temporizador para la siguiente Aura centelleante",
	FAIcons		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(41001)
}

----------------------
--  Illidari Council  --
----------------------
L = DBM:GetModLocalization("Council")

L:SetGeneralLocalization{
	name = "El Consejo Illidari"
}

L:SetWarningLocalization{
	Immune			= "Malande inmune a %s durante 15 s"
}

L:SetOptionLocalization{
	Immune			= "Mostrar aviso cuando Manalde se vuelva inmune al daño físico o de hechizos",
	PoisonIcon		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(41485)
}

L:SetMiscLocalization{
	Gathios			= "Gathios el Despedazador",
	Malande			= "Lady Malande",
	Zerevor			= "Sumo abisálico Zerevor",
	Veras			= "Veras Sombra Oscura",
	Melee			= "físico",
	Spell			= "hechizos"
}

-------------------------
--  Illidan Stormrage --
-------------------------
L = DBM:GetModLocalization("Illidan")

L:SetGeneralLocalization{
	name = "Illidan Tempestira"
}

L:SetWarningLocalization{
	WarnHuman		= "Fase humanoide",
	WarnDemon		= "Fase demoníaca"
}

L:SetTimerLocalization{
	TimerNextHuman		= "Siguiente fase humanoide",
	TimerNextDemon		= "Siguiente fase demoníaca"
}

L:SetOptionLocalization{
	WarnHuman		= "Anunciar cambio a fase humanoide",
	WarnDemon		= "Anunciar cambio a fase demoníaca",
	TimerNextHuman	= "Mostrar temporizador para la siguiente fase humanoide",
	TimerNextDemon	= "Mostrar temporizador para la siguiente fase demoníaca",
	RangeFrame		= "Mostrar marco de distancia (10 m) en las fases 3 y 4",
	ParasiteIcon	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(41917)
}

L:SetMiscLocalization{
	Pull			= "Akama. Tu hipocresía no me sorprende. Debí acabar contigo y con tus malogrados hermanos hace tiempo.",
	Eyebeam			= "¡Mirad los ojos del Traidor!",
	Demon			= "¡Observad el poder...del demonio interior!",--sic
	Phase4			= "¿Esto es todo, mortales? ¿Es esta toda la furia que podéis reunir?"
}
