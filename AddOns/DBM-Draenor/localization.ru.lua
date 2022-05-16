if GetLocale() ~= "ruRU" then
	return
end
local L

-------------------------
-- Supreme Lord Kazzak --
-------------------------
L = DBM:GetModLocalization(1452)

L:SetMiscLocalization({
	Pull	= "Вы познаете мощь Легиона!"
})

--------------------------
--  Garrison Invasions  --
--------------------------
L = DBM:GetModLocalization("GarrisonInvasions")

L:SetGeneralLocalization({
	name	= "Вторжения в гарнизон"
})

L:SetWarningLocalization({
	specWarnRylak		= "Темнокрыл-падальщик приближается",
	specWarnWorker		= "Испуганный рабочий на открытом воздухе",
	specWarnSpy			= "Шпион пробрался внутрь",
	specWarnBuilding	= "Здание подвергается нападению"
})

L:SetOptionLocalization({
	specWarnRylak		= "Показывать спецпредупреждение о приближении рилаков",
	specWarnWorker		= "Показывать спецпредупреждение, когда перепуганный рабочий оказывается на открытом воздухе.",
	specWarnSpy			= "Показывать спецпредупреждение, когда шпион пробрался внутрь",
	specWarnBuilding	= "Показывать спецпредупреждение, когда здание находится под атакой"
})

L:SetMiscLocalization({
	--General
	preCombat			= "К оружию! Занять посты!",
	preCombat2			= "The air has taken a turn for the foul...",--Shadow Council doesn't follow format of others :\
	rylakSpawn			= "Шум битвы привлекает рилака!",
	terrifiedWorker		= "Испуганный работник находится вне укрытия!",
	sneakySpy			= "воспользовался суматохой и проник на нашу территорию!",
	buildingAttack		= "напали!",
	--Ogre
	GorianwarCaller		= "A Gorian Warcaller joins the battle to raise morale!",--Maybe combined "add" special warning most adds?
	WildfireElemental	= "У главных ворот призывается Буйный элементаль огня!",
	--Iron Horde
	Assassin			= "Убийца охотится на ваших стражей!"
})

-----------------
--  Annihilon  --
-----------------
L = DBM:GetModLocalization("Annihilon")

L:SetGeneralLocalization({
	name	= "Аннигилон"
})

--------------
--  Teluur  --
--------------
L = DBM:GetModLocalization("Teluur")

L:SetGeneralLocalization({
	name	= "Телуур"
})

----------------------
--  Lady Fleshsear  --
----------------------
L = DBM:GetModLocalization("LadyFleshsear")

L:SetGeneralLocalization({
	name	= "Госпожа Плотогонь"
})

-------------------------
--  Commander Dro'gan  --
-------------------------
L = DBM:GetModLocalization("Drogan")

L:SetGeneralLocalization({
	name	= "Командир Дро'ган"
})

-----------------------------
--  Mage Lord Gogg'nathog  --
-----------------------------
L = DBM:GetModLocalization("Goggnathog")

L:SetGeneralLocalization({
	name	= "Высокочтимый маг Гогг'натог"
})

------------
--  Gaur  --
------------
L = DBM:GetModLocalization("Gaur")

L:SetGeneralLocalization({
	name	= "Гаур"
})
