local L = BigWigs:NewBossLocale("Morchok", "esMX")
if not L then return end
if L then
	L.engage_trigger = "Pretendéis detener una avalancha. Os sepultaré."

	L.crush_desc = "Muestra los stacs de Machacar armadura y una barra con su duración."

	L.blood = "Sangre"

	L.explosion = "Explosión"
	L.crystal = "Cristal"
end

L = BigWigs:NewBossLocale("Warlord Zon'ozz", "esMX")
if L then
	L.engage_trigger = "Zzof Shuul'wah. ¡Thoq fssh N'Zoth!"

	L.ball = "Esfera de vacío"
	L.ball_desc = "Una esfera de vacío que rebota entre jugadores y el jefe."
	L.ball_yell = "Gul'kafh an'qov N'Zoth."

	L.bounce = "Rebotar Esfera de vacío"
	L.bounce_desc = "Contador para el rebote de la Esfera de vacío."

	L.darkness = "¡Fiesta de tentáculos!"
	L.darkness_desc = "Esta fase comienza, cuando la esfera de vacío golpea al jefe."

	L.shadows = "Sombras"

	L.custom_off_shadows_marker = "Disrupting Shadows marker"
	L.custom_off_shadows_marker_desc = "Mark Disrupting Shadows targets with {rt1}{rt2}{rt3}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r"
end

L = BigWigs:NewBossLocale("Yor'sahj the Unsleeping", "esMX")
if L then
	L.engage_trigger = "¡Iilth qi'uothk shn'ma yeh'glu Shath'Yar! ¡H'IWN IILTH!"

	L.bolt_desc = "Cuenta los stacs de Descarga de Vacío y muestra una barra con su duración."
	L.bolt_message = "%2$dx Descarga en %1$s"

	L.blue = "|cFF0080FFAzul|r"
	L.green = "|cFF088A08Verde|r"
	L.purple = "|cFF9932CDMorado|r"
	L.yellow = "|cFFFFA901Amarillo|r"
	L.black = "|cFF424242Negro|r"
	L.red = "|cFFFF0404Rojo|r"

	L.blobs = "Manchas"
	L.blobs_bar = "Próxima Mancha"
	L.blobs_desc = "Las Manchas se mueven hacia el jefe"
end

L = BigWigs:NewBossLocale("Hagara the Stormbinder", "esMX")
if L then
	L.engage_trigger = "¡Os enfrentáis a la Vinculatormentas! Os mataré a todos."

	L.lightning_or_frost = "Relámpago o Hielo"
	L.ice_next = "Fase de Hielo"
	L.lightning_next = "Fase de Relámpago"

	L.nextphase = "Siguiente Fase"
	L.nextphase_desc = "Avisos para la siguiente fase"
end

L = BigWigs:NewBossLocale("Ultraxion", "esMX")
if L then
	L.engage_trigger = "¡Ha llegado la Hora del Crepúsculo!"

	L.warmup = "Calentamiento"
	L.warmup_desc = "Tiempo de calentamiento"
	L.warmup_trigger = "Soy el principio del fin, la sombra que eclipsa el Sol, la campana que tañe por tu muerte."

	L.crystal = "Cristales de mejora"
	L.crystal_desc = "Contadores para varios cristales de mejora que invocan los NPC's."
	L.crystal_red = "Cristal rojo"
	L.crystal_green = "Cristal verde"
	L.crystal_blue = "Cristal azul"

	L.twilight = "Crepúsculo"
	L.cast = "Crepúsculo barra de casteo"
	L.cast_desc = "Mostrar una barra de 5 segundos cuando se esté casteando Crepúsculo."

	L.lightself = "Luz mortecina en TI"
	L.lightself_desc = "Mostrar una barra que visualice el tiempo restante hasta que Luz mortecina te haga explotar."
	L.lightself_bar = "<Explotas>"

	L.lighttank = "Luz mortecina en tanques"
	L.lighttank_desc = "Si un tanque tiene Luz mortecina, muestra una barra y un Flash para la explosión."
	L.lighttank_bar = "<%s Explota>"
	L.lighttank_message = "Tanque explotando"
end

L = BigWigs:NewBossLocale("Warmaster Blackhorn", "esMX")
if L then
	L.warmup = "Calentamiento"
	L.warmup_desc = "Tiempo hasta que el combate comience."

	L.sunder = "Hender armadura"
	L.sunder_desc = "Muestra los stacs de Hender armadura y una barra con su duración."
	L.sunder_message = "%2$dx Hender en %1$s"

	L.sapper_trigger = "¡Un draco desciende para dejar a un zapador Crepuscular en la cubierta!"
	L.sapper = "Zapador"
	L.sapper_desc = "El Zapador intenta dañar la nave"

	L.stage2_trigger = "Parece que voy a tener que hacerlo yo. ¡Bien!"
end

L = BigWigs:NewBossLocale("Spine of Deathwing", "esMX")
if L then
	L.engage_trigger = "¡Las placas! ¡Se está deshaciendo! ¡Destrozad las placas y tendremos una oportunidad de derribarlo!"

	L.about_to_roll = "a punto de girar"
	L.rolling = "rueda hacia la"
	L.not_hooked = "¡>NO< estás enganchado!"
	L.roll_message = "¡Está girando, girando, girando!"
	L.level_trigger = "se estabiliza."
	L.level_message = "¡Bueno, se ha estabilizado!"

	L.exposed = "Armadura expuesta"

	L.residue = "Residuos no absorbidos"
	L.residue_desc = "Mensajes que te informan cuanto residuo de sangre queda en el suelo."
	L.residue_message = "Residuos no absorbidos: %d"
end

L = BigWigs:NewBossLocale("Madness of Deathwing", "esMX")
if L then
	L.engage_trigger = "No habéis hecho nada. Destruiré vuestro mundo."

	-- Copy & Paste from Encounter Journal with correct health percentages (type '/dump (C_EncounterJournal.GetSectionInfo(4103)).title' in the game)
	L.smalltentacles_desc = "At 70% and 40% remaining health the Limb Tentacle sprouts several Blistering Tentacles that are immune to Area of Effect abilities."

	L.bolt_explode = "<Descarga Explota>"
	L.parasite = "Parásito"
	L.blobs_soon = "%d%% - Sangre coagulante inminente!"
end

