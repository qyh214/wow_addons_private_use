if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then
	return
end
local L

-------------------
-- Sha de la ira --
-------------------
L = DBM:GetModLocalization(691)

L:SetOptionLocalization({
	RangeFrame		= "Mostrar marco de distancia dinámico en función del estado del perjuicio de $spell:119622 en los jugadores",
	SetIconOnMC2	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(119622)
})

L:SetMiscLocalization({
	Pull	= "¡Sí, sí! ¡Dejad que vuestra ira florezca! ¡Intentad abatirme!"
})

------------------------------
-- Banda guerrera de Salyis --
------------------------------
L = DBM:GetModLocalization(725)

L:SetMiscLocalization({
	Pull	= "¡Quiero sus cadáveres!"
})

--------------
-- Oondasta --
--------------
L = DBM:GetModLocalization(826)

L:SetOptionLocalization({
	RangeFrame	= DBM_CORE_AUTO_RANGE_OPTION_TEXT:format(10, 137511)
})

L:SetMiscLocalization({
	Pull	= "¡Cómo osáis interrumpir nueh'tros preparativos! ¡Nadie detendrá a los Zandalari! ¡Eh'ta vez no!"
})

------------------------------------
-- Nalak, el Señor de la Tormenta --
------------------------------------
L = DBM:GetModLocalization(814)

L:SetOptionLocalization({
	RangeFrame	= DBM_CORE_AUTO_RANGE_OPTION_TEXT:format(10, 136340)
})

L:SetMiscLocalization({
	Pull	= "¿Sentís un viento frío? Se avecina la tormenta..."
})

----------------------------
-- Chi-ji, la Grulla Roja --
----------------------------
L = DBM:GetModLocalization(857)

L:SetOptionLocalization({
	SetIconOnBeacon	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(144473),
	BeaconArrow		= "Mostrar flecha cuando un jugador esté afectado por $spell:144473"
})

L:SetMiscLocalization({
	Pull	= "Comencemos.",
	Victory	= "Vuestra esperanza brilla con fuerza, sobre todo cuando lucháis juntos. Siempre iluminará vuestro camino, incluso en los lugares más oscuros."
})

-------------------------------
-- Yu'lon, el Dragón de Jade --
-------------------------------
L = DBM:GetModLocalization(858)

L:SetOptionLocalization({
	RangeFrame	= DBM_CORE_AUTO_RANGE_OPTION_TEXT:format(11, 144532)
})

L:SetMiscLocalization({
	Pull	= "¡Comienza la prueba!",
	Wave1	= "¡No dejéis que las dificultades os nublen el juicio!",
	Wave2	= "¡Escuchad vuestra voz interior y buscad la verdad!",
	Wave3	= "¡Considerad siempre las consecuencias de vuestros actos!",
	Victory	= "Vuestra sabiduría os ha hecho superar esta prueba. Que siempre ilumine vuestro camino en la oscuridad."
})

---------------------------
-- Niuzao, el Buey Negro --
---------------------------
L = DBM:GetModLocalization(859)

L:SetMiscLocalization({
	Pull		= "Ya veremos.",
	Victory		= "Aunque estaréis rodeados de enemigos inimaginables, vuestra entereza os permitirá resistir. Recordadlo en los tiempos que se avecinan.",
	VictoryDem	= "Rakkas shi alar re pathrebosh il zila rethule kiel shi shi belaros rikk kanrethad adare revos shi xi thorje Rukadare zila te lok zekul melar "--Is this different in other languages? I have no way to check this.
})

---------------------------
-- Xuen, el Tigre Blanco --
---------------------------
L = DBM:GetModLocalization(860)

L:SetOptionLocalization({
	RangeFrame	= DBM_CORE_AUTO_RANGE_OPTION_TEXT:format(3, 144642)
})

L:SetMiscLocalization({
	Pull	= "¡Ja! ¡La prueba comienza!",
	Victory	= "Sois fuertes, más de lo que creéis. Tenedlo presente en la oscuridad que os espera y dejad que os sirva de escudo."
})

-----------------------------------------
-- Ordos, Dios de fuego de los yaungol --
-----------------------------------------
L = DBM:GetModLocalization(861)

L:SetOptionLocalization({
	SetIconOnBurningSoul	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(144689),
	RangeFrame				= DBM_CORE_AUTO_RANGE_OPTION_TEXT:format(8, 144689)
})

L:SetMiscLocalization({
	Pull	= "Ocuparéis mi lugar en el fuego eterno."
})

-----------------
--  Zandalari  --
-----------------
L = DBM:GetModLocalization("Zandalari")

L:SetGeneralLocalization({
	name	= "Zandalari"
})