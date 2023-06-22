if GetLocale() ~= "ptBR" then
	return
end

local L

---------------
-- Kargath Bladefist --
---------------
L = DBM:GetModLocalization(1128)

---------------------------
-- The Butcher --
---------------------------
L = DBM:GetModLocalization(971)

---------------------------
-- Tectus, the Living Mountain --
---------------------------
L = DBM:GetModLocalization(1195)

L:SetMiscLocalization({
	pillarSpawn	= "ASCENDAM, MONTANHAS!"
})

------------------
-- Brackenspore, Walker of the Deep --
------------------
L = DBM:GetModLocalization(1196)

L:SetOptionLocalization({
	InterruptCounter	= "Contador da decomposição reseta após",
	Two					= "depois de dois casts",
	Three				= "Depois de três casts",
	Four				= "Depois de quatro casts"

-- cast translation would be lançar which relates to throw best to keep it at cast.

})

--------------
-- Twin Ogron --
--------------
L = DBM:GetModLocalization(1148)

L:SetOptionLocalization({
	PhemosSpecial		= "Play countdown sound for Phemos' cooldowns",
	PolSpecial			= "Toca contagem sonora para recargas do Pol",
	PhemosSpecialVoice	= "Toca alertas falados para habilidades do Phemos usando vozes selecionadas",
	PolSpecialVoice		= "Toca alertas falados para habilidades do Pol usando pacote de vozes previamente selecionadas"
})

--------------------
--Koragh --
--------------------
L = DBM:GetModLocalization(1153)

L:SetWarningLocalization({
	specWarnExpelMagicFelFades	= "Vil surgindo em 5s - Volte ao início"
})

L:SetOptionLocalization({
	specWarnExpelMagicFelFades	= "Toca aviso especial para retornar à posição inicial para $spell:172895 expirando"
})

L:SetMiscLocalization({
	supressionTarget1	= "Eu vou esmagá-lo!",
	supressionTarget2	= "Silêncio!",
	supressionTarget3	= "Quieto!",
	supressionTarget4	= "Eu vou rasgá-lo ao meio!"
})

--------------------------
-- Imperator Mar'gok --
--------------------------
L = DBM:GetModLocalization(1197)

L:SetTimerLocalization({
	timerNightTwistedCD	= "próximo Night-Twisted Adds"
})

L:SetOptionLocalization({
	GazeYellType		= "Escolha o tipo de grito para olhar do abismo",
	Countdown			= "contagem até expiração",
	Stacks				= "Quantidades conforme são aplicadas",
	timerNightTwistedCD	= "Exibe contador para o próximo Night-Twisted Faithful"
})

L:SetMiscLocalization({
	BrandedYell		= "Marcado (%d) %dy",
	GazeYell		= "Olhar do Abismo acabando %d",
	GazeYell2		= "Olhar do Abismo (%d) on %s",
	PlayerDebuffs	= "Perto do Vestígio"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("HighmaulTrash")

L:SetGeneralLocalization({
	name	= "Malho Imponente Trash"
})

---------------
-- Gruul --
---------------
L = DBM:GetModLocalization(1161)

L:SetOptionLocalization({
	MythicSoakBehavior	= "Set Mythic difficulty group soak preference for special warnings",--Translate
	ThreeGroup			= "3 Group 1 stack each strat",--Translate
	TwoGroup			= "2 Group 2 stacks each strat"--Translate
})

---------------------------
-- Oregorger, The Devourer --
---------------------------
L = DBM:GetModLocalization(1202)

L:SetOptionLocalization({
	InterruptBehavior	= "Set behavior for interrupt warnings",--Translate
	Smart				= "Interrupt warnings are based on bosses spine stacks",--Translate
	Fixed				= "Interrupts use a 5 or 3 sequence no matter what (even if boss doesn't)"--Translate
})

---------------------------
-- The Blast Furnace --
---------------------------
L = DBM:GetModLocalization(1154)

L:SetWarningLocalization({
	warnBlastFrequency	= "Frequência da explosão aumentou : Aprox cada %d seg"
})

L:SetOptionLocalization({
	warnBlastFrequency	= "Anuncia quando $spell:155209 frequência aumentar"
})

--------------------------
-- Operator Thogar --
--------------------------
L = DBM:GetModLocalization(1147)

L:SetWarningLocalization({
	specWarnSplitSoon	= "Divisão da raid em 10"
})

L:SetOptionLocalization({
	specWarnSplitSoon	= "Exibe um aviso especial 10 segundos antes da divisão da raid"
})

L:SetMiscLocalization({
	Train			= "Train",--Might need translation
	lane			= "Pista",
	oneTrain		= "Trem em 1 pista aleatória",
	oneRandom		= "Aparece em 1 pista aleatória",
	threeTrains		= "Trens em 3 pistas aleatórias",
	threeRandom		= "Aparecem em 3 pistas aleatórias",
	helperMessage	= "Esse encontro pode ser melhorado com mods de terceiros 'Thogar Assist' ou um dos muitos pacotes de vozes para DBM ( com avisos sonoros ) disponíveis no site da Curse.com ."
})

--------------------------
-- The Iron Maidens --
--------------------------
L = DBM:GetModLocalization(1203)

L:SetMiscLocalization({
	shipMessage	= "prepara-se para usar o canhão principal do Couraçado!"
})

--------------------------
-- Blackhand --
--------------------------
L = DBM:GetModLocalization(959)

L:SetWarningLocalization({
	specWarnMFDPosition		= "Marked Position: %s",--Translate
	specWarnSlagPosition	= "Bomb Position: %s"--Translate
})

L:SetOptionLocalization({
	PositionsAllPhases	= "Give positions for $spell:156096 yells during all phases (Instead of just phase 3. This is mostly for testing and assurances, this option is not actually needed)",--Translate
	InfoFrame			= "Show info frame for $spell:155992 and $spell:156530"--Translate
})

L:SetMiscLocalization({
	customMFDSay	= "Marked %s on %s",--Translate
	customSlagSay	= "Bomb %s on %s"--Translate
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("BlackrockFoundryTrash")

L:SetGeneralLocalization({
	name	= "Trash da Fundição da Rocha Negra"
})
