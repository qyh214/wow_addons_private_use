if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

---------------
-- Immerseus --
---------------
L= DBM:GetModLocalization(852)

L:SetMiscLocalization({
	Victory			= "¡Ah, lo habéis logrado! Las aguas vuelven a ser puras."
})

----------------------------
-- Los protectores caídos --
----------------------------
L= DBM:GetModLocalization(849)

L:SetWarningLocalization({
	specWarnCalamity	= "%s",
	specWarnMeasures	= "¡Medidas desesperadas (%s) en breve!"
})

--------------
-- Norushen --
--------------
L= DBM:GetModLocalization(866)

L:SetMiscLocalization({
	wasteOfTime			= "Muy bien, crearé un campo para mantener aislada vuestra corrupción."
})

---------------------
-- Sha del orgullo --
---------------------
L= DBM:GetModLocalization(867)

L:SetOptionLocalization({
	SetIconOnFragment	= "Poner icono en Fragmento corrupto"
})

--------------
-- Galakras --
--------------
L= DBM:GetModLocalization(868)

L:SetWarningLocalization({
	warnTowerOpen		= "Torre abierta",
	warnTowerGrunt		= "Bruto Faucedraco"
})

L:SetTimerLocalization({
	timerTowerCD		= "Siguiente torre",
	timerTowerGruntCD	= "Siguiente Bruto Faucedraco"
})

L:SetOptionLocalization({
	warnTowerOpen		= "Anunciar cuando se abra una torre",
	warnTowerGrunt		= "Anunciar cuando aparezca un Bruto Faucedraco",
	timerTowerCD		= "Mostrar temporizador para la siguiente apertura de torre",
	timerTowerGruntCD	= "Mostrar temporizador para el siguiente Bruto Faucedraco"
})

L:SetMiscLocalization({
	wasteOfTime		= "¡Bien hecho! ¡Grupos de desembarco, formad! ¡Infantería, al frente!",--Alliance Version
	wasteOfTime2	= "Bien hecho. La primera brigada ha desembarcado.",--Horde Version
	Pull			= "Clan Faucedraco, ¡recuperad los muelles y empujadlos al mar! ¡Por Grito Infernal! ¡Por la Horda auténtica!",
	newForces1		= "¡Ya vienen!",--Jaina's line, alliance
	newForces1H		= "Derribadla pronto para que pueda asfixiarla con mis propias manos.",--Sylva's line, horde
	newForces2		= "¡Faucedraco, avanzad!",
	newForces3		= "¡Por Grito Infernal!",
	newForces4		= "¡Siguiente escuadrón, adelante!",
	tower			= "¡La puerta de la torre"--The door barring the South/North Tower has been breached!
})

--------------------
-- Gigante férreo --
--------------------
L= DBM:GetModLocalization(864)

L:SetOptionLocalization({
	timerAssaultModeCD		= DBM_CORE_AUTO_TIMER_OPTIONS.next:format("ej8177"),
	timerSiegeModeCD		= DBM_CORE_AUTO_TIMER_OPTIONS.next:format("ej8178")
})

-------------------------------
-- Chamanes oscuros Kor'kron --
-------------------------------
L= DBM:GetModLocalization(856)

L:SetMiscLocalization({
	PrisonYell		= "Prisión de hierro expira en %s (%d)"
})

---------------------
-- General Nazgrim --
---------------------
L= DBM:GetModLocalization(850)

L:SetWarningLocalization({
	warnDefensiveStanceSoon		= "Actitud defensiva en %d s"
})

L:SetOptionLocalization({
	warnDefensiveStanceSoon		= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.prewarn:format(143593)
})

L:SetMiscLocalization({
	newForces1					= "¡Guerreros, paso ligero!",
	newForces2					= "¡Defended la puerta!",
	newForces3					= "¡Reunid a las tropas!",
	newForces4					= "¡Kor'kron, conmigo!",
	newForces5					= "¡Siguiente escuadrón, al frente!",
	allForces					= "Atención, Korkron: ¡matadlos!",
	nextAdds					= "Siguientes refuerzos: ",
	mage						= "|c"..RAID_CLASS_COLORS["MAGE"].colorStr..LOCALIZED_CLASS_NAMES_MALE["MAGE"].."|r",
	shaman						= "|c"..RAID_CLASS_COLORS["SHAMAN"].colorStr..LOCALIZED_CLASS_NAMES_MALE["SHAMAN"].."|r",
	rogue						= "|c"..RAID_CLASS_COLORS["ROGUE"].colorStr..LOCALIZED_CLASS_NAMES_MALE["ROGUE"].."|r",
	hunter						= "|c"..RAID_CLASS_COLORS["HUNTER"].colorStr..LOCALIZED_CLASS_NAMES_MALE["HUNTER"].."|r",
	warrior						= "|c"..RAID_CLASS_COLORS["WARRIOR"].colorStr..LOCALIZED_CLASS_NAMES_MALE["WARRIOR"].."|r"
})

--------------
-- Malkorok --
--------------
L= DBM:GetModLocalization(846)

-----------------------
-- Botín de Pandaria --
-----------------------
L= DBM:GetModLocalization(870)

L:SetMiscLocalization({
	wasteOfTime		= "¿Estamos grabando? ¿Sí? Vale. Iniciando módulo de control goblin-titán. Atrás.",
	Module1			= "El módulo 1 está listo para el reinicio del sistema.",
	Victory			= "El módulo 2 está listo para el reinicio del sistema."
})

-------------------------
-- Thok el Sanguinario --
-------------------------
L= DBM:GetModLocalization(851)

L:SetOptionLocalization({
	RangeFrame	= "Mostrar marco de distancia (10 m) dinámico (se mostrará al estar en el umbral de alcance de $spell:143442)"
})

--------------------------
-- Asediador Mechanegra --
--------------------------
L= DBM:GetModLocalization(865)

L:SetMiscLocalization({
	newWeapons	= "La cadena de montaje empieza a sacar armas sin terminar.",
	newShredder	= "¡Una trituradora automática se acerca!"
})

----------------------------
-- Dechados de los Klaxxi --
----------------------------
L= DBM:GetModLocalization(853)

L:SetWarningLocalization({
	specWarnActivatedVulnerable		= "Eres vulnerable a %s - ¡esquiva!",
	specWarnMoreParasites			= "Necesitas más parásitos - ¡no uses mitigaciones activas!"
})

L:SetOptionLocalization({
	warnToxicCatalyst				= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format("ej8036"),
	specWarnActivatedVulnerable		= "Mostrar aviso especial cuando seas vulnerable a un dechado",
	specWarnMoreParasites			= "Mostrar aviso especial cuando necesites más parásitos",
	yellToxicCatalyst				= DBM_CORE_AUTO_YELL_OPTION_TEXT.yell:format("ej8036")
})

L:SetMiscLocalization({
	--thanks to blizz, the only accurate way for this to work, is to translate 5 emotes in all languages
	one					= "Uno",
	two					= "Dos",
	three				= "Tres",
	four				= "Cuatro",
	five				= "Cinco",
	hisekFlavor			= "¿Te gusta el silencio, Hisek?",--http://ptr.wowhead.com/quest=31510
	KilrukFlavor		= "Otro días más de matar al enjambre.",--http://ptr.wowhead.com/quest=31109
	XarilFlavor			= "Ya no verás más que cielos oscuros.",--http://ptr.wowhead.com/quest=31216
	KaztikFlavor		= "Reducido a meras golosinas de kunchong.",--http://ptr.wowhead.com/quest=31024
	KaztikFlavor2		= "Un mántide menos; solo quedan ciento noventa y nueve.",--http://ptr.wowhead.com/quest=31808
	KorvenFlavor		= "El fin de un imperio ancestral.",--http://ptr.wowhead.com/quest=31232
	KorvenFlavor2		= "Toma tus tablillas de Gurthani y métetelas por donde te quepan.",--http://ptr.wowhead.com/quest=31232
	IyyokukFlavor		= "He visto una oportunidad y la he explotado.",--Does not have quests, http://ptr.wowhead.com/npc=65305
	KarozFlavor			= "¡No volverás a saltar!",---Does not have quests, http://ptr.wowhead.com/npc=65303
	SkeerFlavor			= "¡Una delicia sangrienta!",--http://ptr.wowhead.com/quest=31178
	RikkalFlavor		= "Recogida de espécimen completada."--http://ptr.wowhead.com/quest=31508
})

----------------------------
-- Garrosh Grito Infernal --
----------------------------
L= DBM:GetModLocalization(869)

L:SetTimerLocalization({
	timerRoleplay		= "Diálogo"
})

L:SetOptionLocalization({
	timerRoleplay		= "Mostrar temporizador para el diálogo entre Garrosh y Thrall",
	RangeFrame			= "Mostrar marco de distancia (8 m) dinámico (se mostrará al estar en el umbral de alcance de $spell:147126)",
	InfoFrame			= "Mostrar marco de información de jugadores sin reducción de daño durante el intermedio",
	yellMaliceFading	= "Gritar cuando $spell:147209 esté a punto de expirar"
})

L:SetMiscLocalization({
	wasteOfTime			= "No es demasiado tarde, Garrosh. Renuncia al cargo de Jefe de Guerra. Esto puede acabar ahora, sin más sangre.",
	NoReduce			= "Sin reducción de daño",
	MaliceFadeYell		= "Malicia expirando en %s (%d)",
	phase3End			= "¿Creéis que habéis ganado?"
})

----------------------
-- Enemigos menores --
----------------------
L = DBM:GetModLocalization("SoOTrash")

L:SetGeneralLocalization({
	name =	"Enemigos menores"
})
