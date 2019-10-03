if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then
	return
end
local L

------------------------
-- Cervezas y Truenos --
------------------------
L = DBM:GetModLocalization("d517")

L:SetTimerLocalization({
	timerEvent	= "Cerveza fermentada (aprox.)"
})

L:SetOptionLocalization({
	timerEvent	= "Mostrar temporizador para cuando termine aproximadamente la fermentación de la cerveza"
})

L:SetMiscLocalization({
	BrewStart		= "¡Ya empieza la tormenta! Preparaos.",
	BorokhulaPull	= "¡Último aviso, reptiles de lengua bífida!",
	BorokhulaAdds	= "solicita refuerzos!"--In case useful/important on heroic. On normal just zerg boss and ignore these unless you want achievement.
})

---------------
-- Templanza --
---------------
L = DBM:GetModLocalization("d589")

L:SetMiscLocalization({
	ScargashPull	= "¡Vuestra Alianza es DÉBIL!"--Not yet in use but could be with more logs and combat start timers
})

-----------------------------
-- Arena de la Aniquilación --
-----------------------------
L = DBM:GetModLocalization("d511")

-----------------------
-- Asalto a Zan'vess --
-----------------------
L = DBM:GetModLocalization("d593")

L:SetMiscLocalization({
	TelvrakPull	= "¡Zan'vess no caerá nunca!"
})

--------------------------
-- Batalla en Alta Mar ---
--------------------------
L = DBM:GetModLocalization("d652")

------------------------
-- Sangre en la Nieve --
------------------------
L = DBM:GetModLocalization("d646")

----------------------------------
-- Festival de la Cerveza Lunar --
----------------------------------
L = DBM:GetModLocalization("d539")

L:SetTimerLocalization({
	timerBossCD	= "%s"
})

L:SetOptionLocalization({
	timerBossCD	= "Mostrar temporizador para el siguiente jefe"
})

L:SetMiscLocalization({
	RatEngage	= "¡Es la madre del cubil! ¡Cuidado,",
	BeginAttack	= "¡Hay que defender a los aldeanos!",
	Yeti		= "Yeti de guerra Bataari",
	Qobi		= "Belisario Qobi"
})

-----------------------------------
-- Cripta de los Reyes Olvidados --
-----------------------------------
L = DBM:GetModLocalization("d504")

------------------------------
-- Una Daga en la Oscuridad --
------------------------------
L = DBM:GetModLocalization("d616")

L:SetTimerLocalization({
	timerAddsCD	= "Invocar esbirros TdR"
})

L:SetOptionLocalization({
	timerAddsCD	= "Mostrar temporizador para el tiempo de reutilización de la invocación de esbirros del Señor lagarto"
})

L:SetMiscLocalization({
	LizardLord	= "Esos saurok vigilan la cueva. Ocupémonos de ellos."
})

--------------------------------
-- Corazón Oscuro de Pandaria --
--------------------------------
L = DBM:GetModLocalization("d647")

L:SetMiscLocalization({
	summonElemental	= "¡Esbirros, acabad con estos insectos!"
})

--------------------
-- Aldea Verdemar --
--------------------
L = DBM:GetModLocalization("d492")

----------------------
-- Punto de Dominio --
----------------------
L = DBM:GetModLocalization("Landfall")

L:SetWarningLocalization({
	WarnAchFiveAlive	= "Logro 'Los cinco en el Punto de Dominio' fallado"
})

L:SetOptionLocalization({
	WarnAchFiveAlive	= "Mostrar aviso si se falla el logro 'Los cinco en el Punto de Dominio'"
})

--------------------------------
-- Los Secretos de Sima Ígnea --
--------------------------------
L = DBM:GetModLocalization("d649")

L:SetMiscLocalization({
	XorenthPull	= "¡Todas las razas inferiores son enemigas de la Horda auténtica!",
	ElagloPull	= "¡Estúpidos! ¡Los de vuestra especie no pueden detener a la auténtica Horda!"
})

------------------------
-- Caída de Theramore --
------------------------
L = DBM:GetModLocalization("d566")

------------------------------------
-- Los Tesoros del Rey del Trueno --
------------------------------------
L = DBM:GetModLocalization("d620")

----------------
-- Unga Ingoo --
----------------
L = DBM:GetModLocalization("d499")

---------------------------
-- Fuego verde del brujo --
---------------------------
L = DBM:GetModLocalization("d594")

L:SetWarningLocalization({
	specWarnLostSouls		= "¡Almas perdidas!",
	specWarnEnslavePitLord	= "Señor del foso - ¡esclavízalo ahora!"
})

L:SetTimerLocalization({
	timerLostSoulsCD	= "Almas perdidas TdR"
})

L:SetOptionLocalization({
	specWarnLostSouls		= "Mostrar aviso especial cuando aparezcan Almas perdidas",
	specWarnEnslavePitLord	= "Mostrar aviso especial para usar Esclavizar demonio cuando aparezca el Señor del foso",
	timerLostSoulsCD		= "Mostrar temporizador para las siguientes Almas perdidas"
})

L:SetMiscLocalization({
	LostSouls	= "¡Enfréntate a las almas condenadas por los de tu calaña!"
})

-----------------------------
-- El Ingrediente Secreto --
-----------------------------
L = DBM:GetModLocalization("d745")

L:SetMiscLocalization({
	Clear	= "¡Bien hecho!"
})