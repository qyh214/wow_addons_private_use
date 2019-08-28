if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

-------------
-- Morchok --
-------------
L= DBM:GetModLocalization(311)

L:SetWarningLocalization({
	KohcromWarning	= "%s: %s"--Bossname, spellname. At least with this we can get boss name from casts in this one, unlike a timer started off the previous bosses casts.
})

L:SetTimerLocalization({
	KohcromCD		= "Kohcrom imita %s",--Universal single local timer used for all of his mimick timers
})

L:SetOptionLocalization({
	KohcromWarning	= "Mostrar aviso para las facultades imitadas por $journal:4262",
	KohcromCD		= "Mostrar temporizador para la siguiente habilidad imitada por $journal:4262",
	RangeFrame		= "Mostrar marco de distancia (5 m) para el logro 'No te pegues a mí'"
})

L:SetMiscLocalization({
})

--------------------------------
-- Señor de la guerra Zon'ozz --
--------------------------------
L= DBM:GetModLocalization(324)

L:SetOptionLocalization({
	ShadowYell			= "Gritar cuando te afecte $spell:103434 (dificultad heroica)",
	CustomRangeFrame	= "Opciones del marco de distancia (dificultad heroica)",
	Never				= "Desactivado",
	Normal				= "Marco de distancia normal",
	DynamicPhase2		= "Perjuicio durante la fase 2",
	DynamicAlways		= "Perjuicio durante todo el combate"
})

L:SetMiscLocalization({
	voidYell	= "Gul'kafh an'qov N'Zoth."--Start translating the yell he does for Void of the Unmaking cast, the latest logs from DS indicate blizz removed the event that detected casts. sigh.
})

-------------------------
-- Yor'sahj el Velador --
-------------------------
L= DBM:GetModLocalization(325)

L:SetWarningLocalization({
	warnOozesHit	= "%s absorbe %s"
})

L:SetTimerLocalization({
	timerOozesActive	= "Glóbulos atacables",
	timerOozesReach		= "Glóbulos llegan a Yor'sahj"
})

L:SetOptionLocalization({
	warnOozesHit		= "Anunciar cuando los glóbulos lleguen al jefe",
	timerOozesActive	= "Mostrar temporizador para cuando los glóbulos se vuelvan atacables",
	timerOozesReach		= "Mostrar temporizador para cuando los glóbulos lleguen a a Yor'sahj",
	RangeFrame			= "Mostrar marco de distancia (4 m) para $spell:104898 (dificultad normal/heroica)"
})

L:SetMiscLocalization({
	Black			= "|cFF424242negro|r",
	Purple			= "|cFF9932CDpúrpura|r",
	Red				= "|cFFFF0404rojo|r",
	Green			= "|cFF088A08verde|r",
	Blue			= "|cFF0080FFazul|r",
	Yellow			= "|cFFFFA901amarillo|r"
})

--------------------------------
-- Hagara la Vinculatormentas --
--------------------------------
L= DBM:GetModLocalization(317)

L:SetWarningLocalization({
	WarnPillars				= "%s: %d restantes",
	warnFrostTombCast		= "%s en 8 s"
})

L:SetTimerLocalization({
	TimerSpecial			= "Primera habilidad especial"
})

L:SetOptionLocalization({
	WarnPillars				= "Anunciar el número de $journal:3919 y $journal:4069 restantes",
	TimerSpecial			= "Mostrar temporizador para el primer lanzamiento de habilidad especial",
	RangeFrame				= "Mostrar marco de distancia para $spell:105269 (3 m) y $journal:4327 (10 m)",
	AnnounceFrostTombIcons	= "Anunciar iconos de los objetivos de $spell:104451 en el chat de banda (requiere líder o ayudante)",
	warnFrostTombCast		= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.cast:format(104448),
	SetIconOnFrostTomb		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(104451),
	SetIconOnFrostflake		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(109325),
	SpecialCount			= "Reproducir sonido de cuenta atrás para $spell:105256 y $spell:105465",
	SetBubbles				= "Desactivar bocadillos de chat automáticamente cuando $spell:104451 esté disponible (se restaurarán cuando termine el encuentro)"
})

L:SetMiscLocalization({
	TombIconSet				= "Icono {rt%d} para Tumba de hielo en %s"
})

---------------
-- Ultraxion --
---------------
L= DBM:GetModLocalization(331)

L:SetWarningLocalization({
	specWarnHourofTwilightN		= "%s (%d) en 5 s"--spellname Count
})

L:SetTimerLocalization({
	TimerCombatStart	= "Ultraxion atacable"
})

L:SetOptionLocalization({
	TimerCombatStart	= "Mostrar temporizador para el diálogo de Ultraxion",
	ResetHoTCounter		= "Patrón del contador de Hora del Crepúsculo",--$spell doesn't work in this function apparently so use typed spellname for now.
	Never				= "No reiniciar nunca",
	ResetDynamic		= "Reiniciar en secuencias de 3 (heroica) o 2 (normal)",
	Reset3Always		= "Reiniciar siempre en secuencias de 3",
	SpecWarnHoTN		= "Mostrar aviso especial cuando falten 5 s para Hora del Crepúsculo (si el patrón del contador está configurado en 'No reiniciar nunca', se ajustará al patrón de secuencias de 3)",
	One					= "1 (ej. 1 4 7)",
	Two					= "2 (ej. 2 5)",
	Three				= "3 (ej. 3 6)"
})

L:SetMiscLocalization({
	Pull				= "Percibo que se avecina una gran alteración del equilibrio. ¡Su caos inunda mi mente!"
})

------------------
-- Cuerno Negro --
------------------
L= DBM:GetModLocalization(332)

L:SetWarningLocalization({
	SpecWarnElites	= "¡Élites Crepusculares!"
})

L:SetTimerLocalization({
	TimerAdd			= "Siguientes élites"
})

L:SetOptionLocalization({
	TimerAdd			= "Mostrar temporizador para los siguientes élites Crepusculares",
	SpecWarnElites		= "Mostrar aviso especial cuando aparezcan los élites Crepusculares",
	SetTextures			= "Desactivar automáticamente la opción gráfica de texturas proyectadas durante la fase 1 (se restaurará al iniciarse la fase 2)"
})

L:SetMiscLocalization({
	SapperEmote			= "¡Un draco desciende para dejar a un zapador Crepuscular en la cubierta!",
	Broadside			= "spell:110153",
	DeckFire			= "spell:110095",
	GorionaRetreat			= "grita de dolor y se retira al remolino de nubes."
})

----------------------------
-- Espinazo de Alamuerte  --
----------------------------
L= DBM:GetModLocalization(318)

L:SetWarningLocalization({
	warnSealArmor			= "%s",
	SpecWarnTendril			= "¡Ponte a salvo!"
})

L:SetOptionLocalization({
	warnSealArmor			= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.cast:format(105847),
	SpecWarnTendril			= "Mostrar aviso especial cuando no tengas el perjuicio de $spell:105563",
	InfoFrame				= "Mostrar marco de información de jugadores sin $spell:105563",
	SetIconOnGrip			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(105490),
	ShowShieldInfo			= "Mostrar barra de absorción para $spell:105479 (ignora la opción de marco de salud del jefe)"
})

L:SetMiscLocalization({
	Pull			= "¡Las placas! ¡Se está deshaciendo! ¡Destrozad las placas y tendremos una oportunidad de derribarlo!",
	NoDebuff		= "Sin %s",
	PlasmaTarget	= "Plasma ardiente: %s",
	DRoll			= "a punto de girar",
	DLevels			= "se estabiliza."
})

--------------------------
-- Locura de Alamuerte  -- 
--------------------------
L= DBM:GetModLocalization(333)

L:SetOptionLocalization({
	RangeFrame			= "Mostrar marco de distancia dinámico según el estado del perjuicio $spell:108649 (dificultad heroica)",
	SetIconOnParasite	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(108649)
})

L:SetMiscLocalization({
	Pull				= "No habéis hecho nada. Destruiré vuestro mundo."
})

------------------------
--  Enemigos menores  --
------------------------
L = DBM:GetModLocalization("DSTrash")

L:SetGeneralLocalization({
	name =	"Enemigos menores"
})

L:SetWarningLocalization({
	DrakesLeft			= "Acometedores Crepusculares restantes: %d"
})

L:SetTimerLocalization({
	timerRoleplay		= "Diálogo",
	TimerDrakes			= "%s"--spellname from mod
})

L:SetOptionLocalization({
	DrakesLeft			= "Anunciar el número de Acometedores Crepusculares restantes",
	TimerDrakes			= "Mostrar temporizador para $spell:109904"
})

L:SetMiscLocalization({
	firstRP				= "¡Alabados sean los Titanes, han regresado!",
	UltraxionTrash		= "Me alegra volver a verte, Alexstrasza. He estado ocupado en mi ausencia.",
	UltraxionTrashEnded = "Simples crías, experimentos, un medio para un fin mayor. Verás el resultado de las investigaciones de mi nidada."
})