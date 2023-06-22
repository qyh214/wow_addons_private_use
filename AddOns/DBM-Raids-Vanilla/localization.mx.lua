if GetLocale() ~= "esMX" then return end
local L

---------------
-- Kurinnaxx --
---------------
L = DBM:GetModLocalization("Kurinnaxx")

L:SetGeneralLocalization{
	name 		= "Куриннакс"
}
------------
-- Rajaxx --
------------
L = DBM:GetModLocalization("Rajaxx")

L:SetGeneralLocalization{
	name 		= "Генерал Раджакс"
}
L:SetWarningLocalization{
	WarnWave	= "Волна %s",
}
L:SetOptionLocalization{
	WarnWave	= "Показывать предупреждение о следующей волне"
}
L:SetMiscLocalization{
	Wave1		= "Они пришли. Постарайся не дать себя убить, ",
	Wave12Alt	= "Раджакс, напомни, когда я в последний раз обещал тебя убить?",
	Wave3		= "Час возмездия близок! Да охватит мрак сердца наших врагов!",
	Wave4		= "Мы не будем больше ждать за закрытыми дверьми и каменными стенами! Мы не будем больше отказываться от возмездия! Даже драконы содрогнутся перед нашим гневом!",
	Wave5		= "Пусть наши враги трепещут! Смерть им!",
	Wave6		= "Олений Шлем будет скулить и молить о пощаде, в точности как его сопливый сынок! Тысячелетняя несправедливость сегодня закончится!",
	Wave7		= "Фэндрал! Твой час пробил! Иди же, прячься в изумрудном сне и молись, чтобы мы до тебя не добрались!",
	Wave8		= "Настырная тварь! Я сам тебя убью!"
}

----------
-- Moam --
----------
L = DBM:GetModLocalization("Moam")

L:SetGeneralLocalization{
	name 		= "Моам"
}

----------
-- Buru --
----------
L = DBM:GetModLocalization("Buru")

L:SetGeneralLocalization{
	name 		= "Буру Ненасытный"
}
L:SetWarningLocalization{
	WarnPursue		= "Преследует >%s<",
	SpecWarnPursue	= "Преследует вас!",
	WarnDismember	= "%s на >%s< (%s)"
}
L:SetOptionLocalization{
	WarnPursue		= "Называть преследуемые цели",
	SpecWarnPursue	= "Показывать специальное предупреждение, когда преследование на вас",
	WarnDismember	= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(96)
}
L:SetMiscLocalization{
	PursueEmote 	= "%s смотрит на"
}

-------------
-- Ayamiss --
-------------
L = DBM:GetModLocalization("Ayamiss")

L:SetGeneralLocalization{
	name 		= "Аямисса Охотница"
}

--------------
-- Ossirian --
--------------
L = DBM:GetModLocalization("Ossirian")

L:SetGeneralLocalization{
	name 		= "Оссириан Неуязвимый"
}
L:SetWarningLocalization{
	WarnVulnerable	= "%s"
}
L:SetTimerLocalization{
	TimerVulnerable	= "%s"
}
L:SetOptionLocalization{
	WarnVulnerable	= "Объявлять слабость",
	TimerVulnerable	= "Показывать таймер до слабости"
}

----------------
-- AQ20 Trash --
----------------
L = DBM:GetModLocalization("AQ20Trash")

L:SetGeneralLocalization{
	name = "АК20: Треш"
}

------------
-- Skeram --
------------
L = DBM:GetModLocalization("Skeram")

L:SetGeneralLocalization{
	name = "El profeta Skeram"
}

----------------
-- Three Bugs --
----------------
L = DBM:GetModLocalization("ThreeBugs")

L:SetGeneralLocalization{
	name = "Realeza silítida"
}
L:SetMiscLocalization{
	Yauj = "Princesa Yauj",
	Vem = "Vem",
	Kri = "Lord Kri"
}

-------------
-- Sartura --
-------------
L = DBM:GetModLocalization("Sartura")

L:SetGeneralLocalization{
	name = "Guardia de batalla Sartura"
}

--------------
-- Fankriss --
--------------
L = DBM:GetModLocalization("Fankriss")

L:SetGeneralLocalization{
	name = "Fankriss el Implacable"
}

--------------
-- Viscidus --
--------------
L = DBM:GetModLocalization("Viscidus")

L:SetGeneralLocalization{
	name = "Viscidus"
}
L:SetWarningLocalization{
	WarnFreeze	= "Congelación: %d/3",
	WarnShatter	= "Hacerse añicos: %d/3"
}
L:SetOptionLocalization{
	WarnFreeze	= "Anunciar congelación",
	WarnShatter	= "Anunciar hacerse añicos"
}
L:SetMiscLocalization{
	Slow	= "comienza a ir más despacio!",
	Freezing= "se está congelando!",
	Frozen	= "no se puede mover!",
	Phase4 	= "comienza a desmoronarse!",
	Phase5 	= "parece a punto de hacerse añicos!",
	Phase6 	= "explota!",

	HitsRemain	= "Golpes restantes",
	Frost		= "Escarcha",
	Physical	= "Daño físico"
}
-------------
-- Huhuran --
-------------
L = DBM:GetModLocalization("Huhuran")

L:SetGeneralLocalization{
	name = "Princesa Huhuran"
}
---------------
-- Twin Emps --
---------------
L = DBM:GetModLocalization("TwinEmpsAQ")

L:SetGeneralLocalization{
	name = "Los Emperadores Gemelos"
}
L:SetMiscLocalization{
	Veklor = "Emperador Vek'lor",
	Veknil = "Emperador Vek'nilash"
}

------------
-- C'Thun --
------------
L = DBM:GetModLocalization("CThun")

L:SetGeneralLocalization{
	name = "C'Thun"
}
L:SetWarningLocalization{
	WarnEyeTentacle			= "Tentáculo ocular",
	WarnClawTentacle2		= "Tentáculo Garral",
	WarnGiantEyeTentacle	= "Tentáculo ocular gigante",
	WarnGiantClawTentacle	= "Tentáculo garral gigante",
	SpecWarnWeakened		= "¡C'Thun está débil!"
}
L:SetTimerLocalization{
	TimerEyeTentacle		= "Siguiente Tentáculo ocular",
	TimerClawTentacle		= "Siguiente Tentáculo Garral",
	TimerGiantEyeTentacle	= "Siguiente Tentáculo ocular gigante",
	TimerGiantClawTentacle	= "Siguiente Tentáculo garral gigante",
	TimerWeakened			= "Debilidad termina"
}
L:SetOptionLocalization{
	WarnEyeTentacle			= "Mostrar aviso cuando aparezca un Tentáculo ocular",
	WarnClawTentacle2		= "Mostrar aviso cuando aparezca un Tentáculo Garral",
	WarnGiantEyeTentacle	= "Mostrar aviso cuando aparezca un Tentáculo ocular gigante",
	WarnGiantClawTentacle	= "Mostrar aviso cuando aparezca un Tentáculo garral gigante",
	WarnWeakened			= "Mostrar aviso cuando C'Thun se vuelva débil",
	SpecWarnWeakened		= "Mostrar aviso especial cuando C'Thun se vuelva débil",
	TimerEyeTentacle		= "Mostrar temporizador para el siguiente Tentáculo ocular",
	TimerClawTentacle		= "Mostrar temporizador para el siguiente Tentáculo Garral",
	TimerGiantEyeTentacle	= "Mostrar temporizador para el siguiente Tentáculo ocular gigante",
	TimerGiantClawTentacle	= "Mostrar temporizador para el siguiente Tentáculo garral gigante",
	TimerWeakened			= "Mostrar temporizador para la duración de la debilidad de C'Thun",
	RangeFrame				= "Mostrar marco de distancia (10 m)"
}
L:SetMiscLocalization{
	Stomach		= "Estómago",
	Eye			= "Ojo de C'Thun",
	FleshTent	= "Tentáculo de carne",
	Weakened 	= "está débil!",
	NotValid	= "AQ40 parcialmente limpiado. Quedan %s jefes opcionales."
}
----------------
-- Ouro --
----------------
L = DBM:GetModLocalization("Ouro")

L:SetGeneralLocalization{
	name = "Ouro"
}
L:SetWarningLocalization{
	WarnSubmerge		= "Ouro se sumerge",
	WarnEmerge			= "Ouro regresa"
}
L:SetTimerLocalization{
	TimerSubmerge		= "Sumersión",
	TimerEmerge			= "Emersión"
}
L:SetOptionLocalization{
	WarnSubmerge		= "Mostrar aviso cuando Ouro se sumerja",
	TimerSubmerge		= "Mostrar temporizador para cuando Ouro se sumerja",
	WarnEmerge			= "Mostrar aviso cuando Ouro regrese a la superficie",
	TimerEmerge			= "Mostrar temporizador para cuando Ouro regrese a la superficie"
}
----------------
-- AQ40 Trash --
----------------
L = DBM:GetModLocalization("AQ40Trash")

L:SetGeneralLocalization{
	name = "AQ40: Bichos"
}

-------------------
--  Venoxis  --
-------------------
L = DBM:GetModLocalization("Venoxis")

L:SetGeneralLocalization{
	name = "Sumo sacerdote Venoxis"
}

-------------------
--  Jeklik  --
-------------------
L = DBM:GetModLocalization("Jeklik")

L:SetGeneralLocalization{
	name = "Suma sacerdotisa Jeklik"
}

-------------------
--  Marli  --
-------------------
L = DBM:GetModLocalization("Marli")

L:SetGeneralLocalization{
	name = "Suma sacerdotisa Mar'li"
}

-------------------
--  Thekal  --
-------------------
L = DBM:GetModLocalization("Thekal")

L:SetGeneralLocalization{
	name = "Sumo sacerdote Thekal"
}

L:SetWarningLocalization({
	WarnSimulKill	= "Primer esbirro muerto - Resurrección en ~15 segundos"
})

L:SetTimerLocalization({
	TimerSimulKill	= "Resurrección"
})

L:SetOptionLocalization({
	WarnSimulKill	= "Anunciar primer esbirro muerto",
	TimerSimulKill	= "Mostrar tiempo para resurrección de sacerdote"
})

L:SetMiscLocalization({
	PriestDied	= "%s muere.",
	YellPhase2	= "Shirvallah, ¡lléname de IRA!",
	YellKill	= "¡Hakkar ya no me controla! ¡Por fin algo de paz!",
	Thekal		= "Sumo sacerdote Thekal",
	Zath		= "Zelote Zath",
	LorKhan		= "Zelote Lor'Khan"
})

-------------------
--  Arlokk  --
-------------------
L = DBM:GetModLocalization("Arlokk")

L:SetGeneralLocalization{
	name = "Suma sacerdotisa Arlokk"
}

-------------------
--  Hakkar  --
-------------------
L = DBM:GetModLocalization("Hakkar")

L:SetGeneralLocalization{
	name = "Hakkar"
}

-------------------
--  Bloodlord  --
-------------------
L = DBM:GetModLocalization("Bloodlord")

L:SetGeneralLocalization{
	name = "Señor sangriento Mandokir"
}
L:SetMiscLocalization{
	Bloodlord 	= "Señor sangriento Mandokir",
	Ohgan		= "Ohgan",
	GazeYell	= "Te estoy vigilando"
}

-------------------
--  Edge of Madness  --
-------------------
L = DBM:GetModLocalization("EdgeOfMadness")

L:SetGeneralLocalization{
	name = "Cabo de la Locura"
}
L:SetMiscLocalization{
	Hazzarah = "Hazza'rah",
	Renataki = "Renataki",
	Wushoolay = "Wushoolay",
	Grilek = "Gri'lek"
}

-------------------
--  Gahz'ranka  --
-------------------
L = DBM:GetModLocalization("Gahzranka")

L:SetGeneralLocalization{
	name = "Gahz'ranka"
}

-------------------
--  Jindo  --
-------------------
L = DBM:GetModLocalization("Jindo")

L:SetGeneralLocalization{
	name = "Jin'do el Aojador"
}

-----------------
--  Razorgore  --
-----------------
L = DBM:GetModLocalization("Razorgore")

L:SetGeneralLocalization{
	name = "Sangrevaja el Indomable"
}
L:SetTimerLocalization{
	TimerAddsSpawn	= "Primeros esbirros"
}
L:SetOptionLocalization{
	TimerAddsSpawn	= "Mostrar temporizador para cuando aparezcan los primeros esbirros"
}
L:SetMiscLocalization{
	Phase2Emote	= "huyen mientras se consume el poder del orbe.",
	YellEgg1	= "¡Pagarán por obligarme a hacer esto!",
	YellEgg2	= "¡Locos! ¡Esos huevos son más valiosos de lo que creen!",
	YellEgg3	= "¡No, otro no! ¡Rodarán sus cabezas por esta infamia!",
	YellPull	= "¡Los invasores han penetrado en El Criadero! ¡Activa la alarma! ¡Hay que proteger los huevos a toda costa!"
}
-------------------
--  Vaelastrasz  --
-------------------
L = DBM:GetModLocalization("Vaelastrasz")

L:SetGeneralLocalization{
	name				= "Vaelastrasz el Corrupto"
}

L:SetMiscLocalization{
	Event				= "¡Demasiado tarde, amigos! Ahora estoy poseído por la corrupción de Nefarius... No puedo... controlarme."
}
-----------------
--  Broodlord  --
-----------------
L = DBM:GetModLocalization("Broodlord")

L:SetGeneralLocalization{
	name	= "Señor de linaje Capazote"
}

L:SetMiscLocalization{
	Pull	= "¡Nadie de su raza debería estar aquí! ¡Están condenados!"
}

---------------
--  Firemaw  --
---------------
L = DBM:GetModLocalization("Firemaw")

L:SetGeneralLocalization{
	name = "Faucefogo"
}

---------------
--  Ebonroc  --
---------------
L = DBM:GetModLocalization("Ebonroc")

L:SetGeneralLocalization{
	name = "Ebanorroca"
}

----------------
--  Flamegor  --
----------------
L = DBM:GetModLocalization("Flamegor")

L:SetGeneralLocalization{
	name = "Flamagor"
}

-----------------------
--  Vulnerabilities  --
-----------------------
-- Chromaggus, Death Talon Overseer and Death Talon Wyrmguard
L = DBM:GetModLocalization("TalonGuards")

L:SetGeneralLocalization{
	name = "Guardias Garramortal"
}
L:SetWarningLocalization{
	WarnVulnerable		= "Vulnerabilidad: %s"
}
L:SetOptionLocalization{
	WarnVulnerable		= "Mostrar aviso de vulnerabilidades de hechizo"
}
L:SetMiscLocalization{
	Fire		= "Fuego",
	Nature		= "Naturaleza",
	Frost		= "Escarcha",
	Shadow		= "Sombras",
	Arcane		= "Arcano",
	Holy		= "Sagrado"
}

------------------
--  Chromaggus  --
------------------
L = DBM:GetModLocalization("Chromaggus")

L:SetGeneralLocalization{
	name = "Chromaggus"
}
L:SetWarningLocalization{
	WarnBreath		= "%s",
	WarnVulnerable	= "Vulnerabilidad: %s"
}
L:SetTimerLocalization{
	TimerBreathCD	= "%s TdR",
	TimerBreath		= "%s lanzamiento",
	TimerVulnCD		= "TdR de Vulnerabilidad"
}
L:SetOptionLocalization{
	WarnBreath		= "Mostrar aviso cuando Chromaggus lance uno de sus alientos",
	WarnVulnerable	= "Mostrar temporizador para el tiempo de reutilización de los alientos",
	TimerBreathCD	= "Mostrar TdR de aliento",
	TimerBreath		= "Mostrar lanzamiento de aliento",
	TimerVulnCD		= "Mostrar TdR de Vulnerabilidad"
}
L:SetMiscLocalization{
	Breath1	= "Primer aliento",
	Breath2	= "Segundo aliento",
	VulnEmote	= "%s se estremece mientras su piel empieza a brillar.",
	Vuln		= "Vulnerabilidad",
	Fire		= "Fuego",
	Nature		= "Naturaleza",
	Frost		= "Escarcha",
	Shadow		= "Sombras",
	Arcane		= "Arcano",
	Holy		= "Sagrado"
}

----------------
--  Nefarian  --
----------------
L = DBM:GetModLocalization("Nefarian-Classic")

L:SetGeneralLocalization{
	name = "Nefarian"
}
L:SetWarningLocalization{
	WarnAddsLeft		= "%d restante",
	WarnClassCall		= "Llamada de %s",
	specwarnClassCall	= "¡Llamada de tu clase!"
}
L:SetTimerLocalization{
	TimerClassCall		= "Llamada de %s termina"
}
L:SetOptionLocalization{
	TimerClassCall		= "Mostrar temporizador para la duración de las llamadas en cada clase",
	WarnAddsLeft		= "Anunciar muertes restante hasta Fase 2",
	WarnClassCall		= "Mostrar aviso para las llamadas de clase",
	specwarnClassCall	= "Mostrar aviso especial cuando se ve afectado por la llamada de clase"
}
L:SetMiscLocalization{
	YellP1		= "¡Que comiencen los juegos!",
	YellP2		= "Bien hecho, mis esbirros. El coraje de los mortales empieza a mermar. ¡Veamos ahora cómo se enfrentan al verdadero Señor de la Cubre de Roca Negra!",
	YellP3		= "¡Imposible! ¡Levántense, mis esbirros! ¡Sirvan a su amo una vez más!",
	YellShaman	= "¡Chamanes, muéstrenme lo que pueden hacer sus tótems!",
	YellPaladin	= "Paladines... He oído que tienen muchas vidas. Demuéstrenmelo.",
	YellDruid	= "Los druidas y su estúpido poder de cambiar de forma. ¡Veámoslo en acción!",
	YellPriest	= "¡Sacerdotes! Si van a seguir curando de esa forma, ¡podíamos hacerlo más interesante!",
	YellWarrior	= "¡Vamos guerreros, sé que pueden golpear más fuerte que eso! ¡Veámoslo!",
	YellRogue	= "¿Pícaros? ¡Dejen de esconderse y enfréntense a mí!",
	YellWarlock	= "Brujos... No deberían estar jugando con magia que no comprenden. ¿Ven lo que pasa?",
	YellHunter	= "¡Cazadores y sus molestas cerbatanas!",
	YellMage	= "¿Magos también? Deberían tener más cuidado cuando juegan con la magia...",
--	YellDK		= "¡Caballeros de la Muerte... venid aquí!",
--	YellMonk	= "Monjes, ¿no os mareáis con tanta vuelta?",
--	YellDH		= "¿Cazadores de demonios? Qué raro eso de taparos los ojos así. ¿No os cuesta ver lo que tenéis alrededor?"--Demon Hunter call; I know this hasn't been implemented yet in DBM, but I added it just in case.
}

----------------
--  Lucifron  --
----------------
L = DBM:GetModLocalization("Lucifron")

L:SetGeneralLocalization{
	name = "Lucifron"
}

----------------
--  Magmadar  --
----------------
L = DBM:GetModLocalization("Magmadar")

L:SetGeneralLocalization{
	name = "Magmadar"
}

----------------
--  Gehennas  --
----------------
L = DBM:GetModLocalization("Gehennas")

L:SetGeneralLocalization{
	name = "Gehennas"
}

------------
--  Garr  --
------------
L = DBM:GetModLocalization("Garr-Classic")

L:SetGeneralLocalization{
	name = "Garr"
}

--------------
--  Geddon  --
--------------
L = DBM:GetModLocalization("Geddon")

L:SetGeneralLocalization{
	name = "Barón Geddon"
}

----------------
--  Shazzrah  --
----------------
L = DBM:GetModLocalization("Shazzrah")

L:SetGeneralLocalization{
	name = "Shazzrah"
}

----------------
--  Sulfuron  --
----------------
L = DBM:GetModLocalization("Sulfuron")

L:SetGeneralLocalization{
	name = "Sulfuron Presagista"
}

----------------
--  Golemagg  --
----------------
L = DBM:GetModLocalization("Golemagg")

L:SetGeneralLocalization{
	name = "Golemagg el Incinerador"
}

-----------------
--  Majordomo  --
-----------------
L = DBM:GetModLocalization("Majordomo")

L:SetGeneralLocalization{
	name = "Mayordomo Executus"
}
L:SetTimerLocalization{
	timerShieldCD		= "Próximo Escudo"
}
L:SetOptionLocalization{
	timerShieldCD		= "Mostrar temporizador para el próximo Escudo de daño/reflejo"
}
----------------
--  Ragnaros  --
----------------
L = DBM:GetModLocalization("Ragnaros-Classic")

L:SetGeneralLocalization{
	name = "Ragnaros"
}
L:SetWarningLocalization{
	WarnSubmerge		= "Ragnaros se sumerge",
	WarnEmerge			= "Ragnaros ha regresado"
}
L:SetTimerLocalization{
	TimerSubmerge		= "Sumersión",
	TimerEmerge			= "Emersión"
}
L:SetOptionLocalization{
	WarnSubmerge		= "Mostrar aviso cuando Ragnaros se sumerja",
	TimerSubmerge		= "Mostrar temporizador para cuando Ragnaros se sumerja",
	WarnEmerge			= "Mostrar aviso cuando Ragnaros regrese a la superficie",
	TimerEmerge			= "Mostrar temporizador para cuando Ragnaros regrese a la superficie"
}
L:SetMiscLocalization{
	Submerge	= "¡AVANCEN, MIS SIRVIENTES! ¡DEFIENDAN A SU MAESTRO!",
	Pull		= "¡Crías imprudentes! ¡Se han precipitado hasta su propia muerte! ¡Ahora miren, el maestro se agita!"
}

-----------------
--  MC: Trash  --
-----------------
L = DBM:GetModLocalization("MCTrash")

L:SetGeneralLocalization{
	name = "NM: Bichos"
}

--------------
--  Onyxia  --
--------------
L = DBM:GetModLocalization("Onyxia")

L:SetGeneralLocalization{
	name = "Onyxia"
}

L:SetWarningLocalization{
	WarnWhelpsSoon		= "Crías de Onyxia en breve"
}

L:SetTimerLocalization{
	TimerWhelps	= "Crías de Onyxia"
}

L:SetOptionLocalization{
	TimerWhelps				= "Mostrar temporizador para las siguientes Crías de Onyxia",
	WarnWhelpsSoon			= "Mostrar aviso previo para las siguientes Crías de Onyxia",
	SoundWTF3				= "Reproducir sonidos graciosos de cierta banda legendaria"
}

L:SetMiscLocalization{
	Breath = "%s toma aliento...",
	YellPull = "Qué casualidad. Generalmente, debo salir de mi guarida para poder comer.",
	YellP2 = "Este ejercicio sin sentido me aburre. ¡Los incineraré a todos desde arriba!",
	YellP3 = "¡Parece ser que van a necesitar otra lección, mortales!"
}

-----------------
-- Anub'Rekhan --
-----------------
L = DBM:GetModLocalization("Anub'Rekhan")

L:SetGeneralLocalization({
	name = "Anub'Rekhan"
})

L:SetWarningLocalization({
	SpecialLocust		= "Enjambre de langostas",
	WarningLocustFaded	= "Enjambre de langostas ha terminado"
})

L:SetOptionLocalization({
	SpecialLocust		= "Mostrar aviso especial para $spell:28785",
	WarningLocustFaded	= "Mostrar aviso cuando termine $spell:28785",
	ArachnophobiaTimer	= "Mostrar temporizador para el logro 'Aracnofobia'"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "Logro: Aracnofobia",
	Pull1				= "¡Eso, corred! ¡Así la sangre circula más rápido!",
	Pull2				= "Solo un bocado..."
})

-------------------------
-- Gran Viuda Faerlina --
-------------------------
L = DBM:GetModLocalization("Faerlina")

L:SetGeneralLocalization({
	name = "Gran Viuda Faerlina"
})

L:SetWarningLocalization({
	WarningEmbraceExpire	= "Abrazo de la viuda expirando en 5 s",
	WarningEmbraceExpired	= "Abrazo de la viuda ha expirado"
})

L:SetOptionLocalization({
	WarningEmbraceExpire	= "Mostrar aviso previo para cuando expire Abrazo de la viuda",
	WarningEmbraceExpired	= "Mostrar aviso cuando expire Abrazo de la viuda"
})

L:SetMiscLocalization({
	Pull					= "¡Arrodíllate ante mí, sabandija!"--Not actually pull trigger, but often said on pull
})

-------------
-- Maexxna --
-------------
L = DBM:GetModLocalization("Maexxna")

L:SetGeneralLocalization({
	name = "Maexxna"
})

L:SetWarningLocalization({
	WarningSpidersSoon	= "Arañitas de Maexxna en 5 s",
	WarningSpidersNow	= "Arañitas de Maexxna"
})

L:SetTimerLocalization({
	TimerSpider	= "Siguientes arañitas"
})

L:SetOptionLocalization({
	WarningSpidersSoon	= "Mostrar aviso previo para cuando aparezcan Arañitas de Maexxna",
	WarningSpidersNow	= "Mostrar aviso cuando aparezcan Arañitas de Maexxna",
	TimerSpider			= "Mostrar temporizador para las siguientes Arañitas de Maexxna"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "Logro: Aracnofobia"
})

-----------------------
-- Noth el Pesteador --
-----------------------
L = DBM:GetModLocalization("Noth")

L:SetGeneralLocalization({
	name = "Noth el Pesteador"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "Teletransporte",
	WarningTeleportSoon	= "Teletransporte en 20 s"
})

L:SetTimerLocalization({
	TimerTeleport		= "Teletransporte: Balcón",
	TimerTeleportBack	= "Teletransporte: Suelo"
})

L:SetOptionLocalization({
	WarningTeleportNow	= "Mostrar aviso para Teletransporte",
	WarningTeleportSoon	= "Mostrar aviso previo para Teletransporte",
	TimerTeleport		= "Mostrar temporizador para el siguiente Teletransporte: Balcón",
	TimerTeleportBack	= "Mostrar temporizador para Teletransporte: Suelo"
})

L:SetMiscLocalization({
	Pull				= "¡Muere, intruso!",
	AddsYell			= "¡Levantaos, soldados míos! ¡Levantaos y luchad una vez más!",
	Adds				= "invoca a guerreros esqueletos!",
	AddsTwo				= "alza más esqueletos!"
})

----------------------
-- Heigan el Impuro --
----------------------
L = DBM:GetModLocalization("Heigan")

L:SetGeneralLocalization({
	name = "Heigan el Impuro"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "Teletransporte",
	WarningTeleportSoon	= "Teletransporte en %d s"
})

L:SetTimerLocalization({
	TimerTeleport	= "Teletransporte"
})

L:SetOptionLocalization({
	WarningTeleportNow	= "Mostrar aviso para Teletransporte",
	WarningTeleportSoon	= "Mostrar aviso previo para Teletransporte",
	TimerTeleport		= "Mostrar aviso para Teletransporte"
})

L:SetMiscLocalization({
	Pull				= "Ahora me perteneces."
})

-------------
-- Loatheb --
-------------
L = DBM:GetModLocalization("Loatheb")

L:SetGeneralLocalization({
	name = "Loatheb"
})

L:SetWarningLocalization({
	WarningHealSoon	= "Sanación posible en 3 s",
	WarningHealNow	= "¡Sanad ahora!"
})

L:SetOptionLocalization({
	WarningHealSoon		= "Mostrar aviso previo para la franja de sanación",
	WarningHealNow		= "Mostrar aviso para la franja de sanación"
})

---------------
-- Remendejo --
---------------
L = DBM:GetModLocalization("Patchwerk")

L:SetGeneralLocalization({
	name = "Remendejo"
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	yell1 = "¡Remendejo quiere jugar!",
	yell2 = "¡Remendejo es la encarnación de guerra de Kel'Thuzad!"
})

---------------
-- Grobbulus --
---------------
L = DBM:GetModLocalization("Grobbulus")

L:SetGeneralLocalization({
	name = "Grobbulus"
})

-----------
-- Gluth --
-----------
L = DBM:GetModLocalization("Gluth")

L:SetGeneralLocalization({
	name = "Gluth"
})

--------------
-- Thaddius --
--------------
L = DBM:GetModLocalization("Thaddius")

L:SetGeneralLocalization({
	name = "Thaddius"
})

L:SetMiscLocalization({
	Yell	= "¡Stalagg aplasta!",
	Emote	= "¡%s se sobrecarga!",
	Emote2	= "¡Espiral Tesla se sobrecarga!",
	Boss1	= "Feugen",
	Boss2	= "Stalagg",
	Charge1 = "negativo",
	Charge2 = "positivo"
})

L:SetOptionLocalization({
	WarningChargeChanged	= "Mostrar aviso especial cuando tu polaridad cambie",
	WarningChargeNotChanged	= "Mostrar aviso especial cuando tu polaridad no cambie",
	AirowsEnabled			= "Mostrar flechas (estrategia típica de dos grupos)",
	ArrowsRightLeft			= "Mostrar flechas de izquierda y derecha (estrategia de cuatro grupos; muestra la flecha izquierda si cambia la polaridad, y la derecha si no cambia)",
	ArrowsInverse			= "Mostrar flechas de izquierda y derecha inversas (estrategia de cuatro grupos; muestra la flecha derecha si cambia la polaridad, y la izquierda si no cambia)"
})

L:SetWarningLocalization({
	WarningChargeChanged	= "Polaridad cambiada a %s",
	WarningChargeNotChanged	= "Tu polaridad no ha cambiado"
})

--------------------------
-- Instructor Razuvious --
--------------------------
L = DBM:GetModLocalization("Razuvious")

L:SetGeneralLocalization({
	name = "Instructor Razuvious"
})

L:SetMiscLocalization({
	Yell1 = "¡No tengan piedad!",
	Yell2 = "¡Se ha acabado el tiempo de práctica! ¡Quiero ver lo que han aprendido!",
	Yell3 = "¡Hagan lo que les enseñé!",
	Yell4 = "Un barrido con pierna... ¿Tienes algún problema?"
})

L:SetOptionLocalization({
	WarningShieldWallSoon	= "Mostrar aviso previo para cuando termine $spell:29061"
})

L:SetWarningLocalization({
	WarningShieldWallSoon	= "Barrera de huesos termina en 5 s"
})

--------------------------
-- Gothik el Cosechador --
--------------------------
L = DBM:GetModLocalization("Gothik")

L:SetGeneralLocalization({
	name = "Gothik el Cosechador"
})

L:SetOptionLocalization({
	TimerWave			= "Mostrar temporizador para la siguiente oleada de esbirros",
	TimerPhase2			= "Mostrar temporizador para el cambio a Fase 2",
	WarningWaveSoon		= "Mostrar aviso previo para la siguiente oleada de esbirros",
	WarningWaveSpawned	= "Mostrar aviso cuando comience una oleada de esbirros",
	WarningRiderDown	= "Mostrar aviso cuando muera un Jinete inflexible",
	WarningKnightDown	= "Mostrar aviso cuando muera un Caballero de la Muerte inflexible"
})

L:SetTimerLocalization({
	TimerWave	= "Oleada %d",
	TimerPhase2	= "Fase 2"
})

L:SetWarningLocalization({
	WarningWaveSoon		= "Oleada %d: %s en 3 s",
	WarningWaveSpawned	= "Oleada %d: %s",
	WarningRiderDown	= "Jinete muerto",
	WarningKnightDown	= "Caballero muerto",
	WarningPhase2		= "Fase 2"
})

L:SetMiscLocalization({
	yell			= "Tú mismo has buscado tu final.",
	WarningWave1	= "%d %s",
	WarningWave2	= "%d %s y %d %s",
	WarningWave3	= "%d %s, %d %s y %d %s",
	Trainee			= "practicantes",
	Knight			= "caballeros",
	Rider			= "jinetes"
})

------------------------
-- Los Cuatro Jinetes --
------------------------
L = DBM:GetModLocalization("Horsemen")

L:SetGeneralLocalization({
	name = "Los Cuatro Jinetes"
})

L:SetOptionLocalization({
	WarningMarkSoon				= "Mostrar aviso previo para las marcas",
	SpecialWarningMarkOnPlayer	= "Mostrar aviso especial cuando estés afectado por más de cuatro marcas"
})

L:SetTimerLocalization({
})

L:SetWarningLocalization({
	WarningMarkSoon				= "Marca %d en 3 s",
	SpecialWarningMarkOnPlayer	= "%s: %s"
})

L:SetMiscLocalization({
	Korthazz	= "Señor feudal Korth'azz",
	Rivendare	= "Barón Osahendido",
	Blaumeux	= "Lady Blaumeux",
	Zeliek		= "Sir Zeliek"
})

---------------
-- Sapphiron --
---------------
L = DBM:GetModLocalization("Sapphiron")

L:SetGeneralLocalization({
	name = "Sapphiron"
})

L:SetOptionLocalization({
	WarningAirPhaseSoon	= "Mostrar aviso previo para el cambio a fase aérea",
	WarningAirPhaseNow	= "Anunciar cambio a fase aérea",
	WarningLanded		= "Anunciar cambio a fase en tierra",
	TimerAir			= "Mostrar temporizador para el cambio a fase aérea",
	TimerLanding		= "Mostrar temporizador para el cambio a fase en tierra",
	TimerIceBlast		= "Mostrar temporizador para $spell:28524",
	WarningDeepBreath	= "Mostrar aviso especial para $spell:28524",
	WarningIceblock		= "Gritar cuando te afecte $spell:28522"
})

L:SetMiscLocalization({
	EmoteBreath			= "%s respira hondo.",
	WarningYellIceblock	= "¡Soy un bloque de hielo!"
})

L:SetWarningLocalization({
	WarningAirPhaseSoon	= "Fase aérea en 10 s",
	WarningAirPhaseNow	= "Fase aérea",
	WarningLanded		= "Fase en tierra",
	WarningDeepBreath	= "Aliento de Escarcha"
})

L:SetTimerLocalization({
	TimerAir		= "Fase aérea",
	TimerLanding	= "Fase en tierra",
	TimerIceBlast	= "Aliento de Escarcha"
})

----------------
-- Kel'Thuzad --
----------------

L = DBM:GetModLocalization("Kel'Thuzad")

L:SetGeneralLocalization({
	name = "Kel'Thuzad"
})

L:SetOptionLocalization({
	TimerPhase2			= "Mostrar temporizador para el cambio a Fase 2",
	specwarnP2Soon		= "Mostrar aviso especial 10 s antes del cambio a Fase 2",
	warnAddsSoon		= "Mostrar aviso previo para cuando aparezcan los Guardianes de Corona de Hielo"
})

L:SetMiscLocalization({
	Yell = "¡Esbirros, sirvientes, soldados de la fría oscuridad! ¡Obedeced la llamada de Kel'Thuzad!"
})

L:SetWarningLocalization({
	specwarnP2Soon	= "Fase 2 en 10 s",
	warnAddsSoon	= "Guardianes de Corona de Hielo en breve"
})

L:SetTimerLocalization({
	TimerPhase2	= "Fase 2"
})
