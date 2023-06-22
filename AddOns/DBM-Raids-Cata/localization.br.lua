if GetLocale() ~= "ptBR" then return end

local L

----------------
--  Argaloth  --
----------------
L= DBM:GetModLocalization(139)

L:SetOptionLocalization({
	SetIconOnConsuming		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(88954)
})

-----------------
--  Occu'thar  --
-----------------
L= DBM:GetModLocalization(140)

----------------------------------
--  Alizabal, Mistress of Hate  --
----------------------------------
L= DBM:GetModLocalization(339)

L:SetTimerLocalization({
	TimerFirstSpecial		= "Primeiro especial"
})

L:SetOptionLocalization({
	TimerFirstSpecial		= "Mostrar cronógrafo para o primeiro especial após $spell:105738<br/>(O primeiro especial é aleatório. Ou $spell:105067 ou $spell:104936)"
})

-------------------------------
--  Dark Iron Golem Council  --
-------------------------------
L = DBM:GetModLocalization(169)

L:SetWarningLocalization({
	SpecWarnActivated			= "Mude de alvo para %s!",
	specWarnGenerator			= "Gerador de Energia - Mexa-se %s!"
})

L:SetTimerLocalization({
	timerShadowConductorCast	= "Infusão Sombria",
	timerArcaneLockout			= "Aniquilador em Recarga",
	timerArcaneBlowbackCast		= "Explosão Arcana Reversa",
	timerNefAblity				= "Recarga Melhorar Habilidades"
})

L:SetOptionLocalization({
	timerShadowConductorCast	= "Exibir cronógrafo para lançamento de $spell:92048",
	timerArcaneLockout			= "Exibir cronógrafo para recarga de $spell:91542",
	timerArcaneBlowbackCast		= "Exibir cronógrafo para lançamento de $spell:91879",
	timerNefAblity				= "Exibir cronógrafo para recarga do bônus Melhorar Habilidade (modo Heróico)",
	SpecWarnActivated			= "Exibir aviso especial quando um novo chefe é ativado",
	specWarnGenerator			= "Exibir aviso especial quando um chefe obtém $spell:91557",
	AcquiringTargetIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79501),
	ConductorIcon				= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79888),
	ShadowConductorIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92053),
	SetIconOnActivated			= "Colocar ícone no último chefe ativado"
})

L:SetMiscLocalization({
	YellTargetLock				= "Sombra Envolvente! Fiquem longe!"
})

--------------
--  Magmaw  --
--------------
L = DBM:GetModLocalization(170)

L:SetWarningLocalization({
	SpecWarnInferno	= "Constructo Ósseo Incandescente em breve (~4s)"
})

L:SetOptionLocalization({
	SpecWarnInferno	= "Exibir aviso especial antecipado para $spell:92190 (~4s)",
	RangeFrame		= "Exibir medidor de distância na fase 2 (5)"
})

L:SetMiscLocalization({
	Slump			= "%s slumps forward, exposing his pincers!",
	HeadExposed		= "%s becomes impaled on the spike, exposing his head!",
	YellPhase2		= "Inconceivable! You may actually defeat my lava worm! Perhaps I can help... tip the scales."
})

-----------------
--  Atramedes  --
-----------------
L = DBM:GetModLocalization(171)

L:SetOptionLocalization({
	InfoFrame				= "Exibir quadro de informações para o níveis de som",
	TrackingIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(78092)
})

L:SetMiscLocalization({
	NefAdd					= "Atramedes, the heroes are right THERE!",
	Airphase				= "Yes, run! With every step your heart quickens. The beating, loud and thunderous... Almost deafening. You cannot escape!"
})

-----------------
--  Chimaeron  --
-----------------
L = DBM:GetModLocalization(172)

L:SetOptionLocalization({
	RangeFrame		= "Exibir medidor de distância (6)",
	SetIconOnSlime	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82935),
	InfoFrame		= "Exibir quadro de informações para vida (<10k pv)"
})

L:SetMiscLocalization({
	HealthInfo	= "Informações de vida"
})

----------------
--  Maloriak  --
----------------
L = DBM:GetModLocalization(173)

L:SetWarningLocalization({
	WarnPhase			= "Fase %s"
})

L:SetTimerLocalization({
	TimerPhase			= "Próxima fase"
})

L:SetOptionLocalization({
	WarnPhase			= "Exibir aviso indicando qual será a próxima fase",
	TimerPhase			= "Exibir cronógrafo para a próxima fase",
	RangeFrame			= "Exibir medidor de distância (6) durante a fase azul",
	SetTextures			= "Automaticamente desabilitar texturas projetadas durante a fase escura<br/>(habilita novamente ao término da fase)",
	FlashFreezeIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92979),
	BitingChillIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(77760),
	ConsumingFlamesIcon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(77786)
})

L:SetMiscLocalization({
	YellRed				= "red|r vial into the cauldron!",--Partial matchs, no need for full strings unless you really want em, mod checks for both.
	YellBlue			= "blue|r vial into the cauldron!",
	YellGreen			= "green|r vial into the cauldron!",
	YellDark			= "dark|r magic into the cauldron!"
})

----------------
--  Nefarian  --
----------------
L = DBM:GetModLocalization(174)

L:SetWarningLocalization({
	OnyTailSwipe			= "Açoite de Cauda (Onyxia)",
	NefTailSwipe			= "Açoite de Cauda (Nefarian)",
	OnyBreath				= "Sopro (Onyxia)",
	NefBreath				= "Sopro (Nefarian)",
	specWarnShadowblazeSoon	= "%s",
	warnShadowblazeSoon		= "%s"
})

L:SetTimerLocalization({
	timerNefLanding			= "Nefarian pousa",
	OnySwipeTimer			= "Recarga Açoite de Cauda (Ony)",
	NefSwipeTimer			= "Recarga Açoite de Cauda (Nef)",
	OnyBreathTimer			= "Recarga Sopro (Ony)",
	NefBreathTimer			= "Recarga Sopro (Nef)"
})

L:SetOptionLocalization({
	OnyTailSwipe			= "Exibir aviso para $spell:77827 de Onyxia",
	NefTailSwipe			= "Exibir aviso para $spell:77827 de Nefarian",
	OnyBreath				= "Exibir aviso para $spell:94124 de Onyxia",
	NefBreath				= "Exibir aviso para $spell:94124 de Nefarian",
	specWarnCinderMove		= "Exibir aviso especial para afastar-se quando você está sob efeito de<br/> $spell:79339 (5s antes da explosão)",
	warnShadowblazeSoon		= "Exibir aviso antecipado para $spell:81031 (5s antes)<br/>(Funciona apenas após o cronógrafo estar sincronizado, para garantir a precisão)",
	specWarnShadowblazeSoon	= "Exibir aviso antecipado para $spell:81031<br/>(Primeiro aviso 5s antes. Segundo aviso 1s antes, após sincronia, para garantir precisão)",
	timerNefLanding			= "Exibir cronógrafo para quando Nefarian pousa",
	OnySwipeTimer			= "Exibir cronógrafo para recarga de $spell:77827 (Onyxia)",
	NefSwipeTimer			= "Exibir cronógrafo para recarga de $spell:77827 (Nefarian)",
	OnyBreathTimer			= "Exibir cronógrafo para recarga de $spell:94124 (Onyxia)",
	NefBreathTimer			= "Exibir cronógrafo para recarga de $spell:94124 (Nefarian)",
	InfoFrame				= "Exibir quadro de informações da Energia Elétrica de Onyxia",
	SetWater				= "Automaticamente desabilitar colisão com a água, ao entrar em combate<br/>(habilita novamente, ao sair de combate)",
	SetIconOnCinder			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79339),
	RangeFrame				= "Exibir medidor de distância (10) para $spell:79339<br/>(Mostra todo mundo se você tiver o debuff, caso contrário, apenas jogadores com ícones)"
})

L:SetMiscLocalization({
	NefAoe					= "The air crackles with electricity!",
	YellPhase2				= "Curse you, mortals! Such a callous disregard for one's possessions must be met with extreme force!",
	YellPhase3				= "I have tried to be an accommodating host, but you simply will not die! Time to throw all pretense aside and just... KILL YOU ALL!",
	YellShadowBlaze			= "Flesh turns to ash!",
	ShadowBlazeExact		= "Centelha de Labareda Sombria em %ds",
	ShadowBlazeEstimate		= "Centelha de Labareda Sombria em breve (~5s)"
})

-------------------------------
--  Blackwing Descent Trash  --
-------------------------------
L = DBM:GetModLocalization("BWDTrash")

L:SetGeneralLocalization({
	name = "Trash de Descenso do Asa Negra"
})

--------------------------
--  Halfus Wyrmbreaker  --
--------------------------
L = DBM:GetModLocalization(156)

L:SetOptionLocalization({
	ShowDrakeHealth		= "Mostrar vida dos dragonetes soltos.<br/>(Requer quadro de vida habilitado)"
})

---------------------------
--  Valiona & Theralion  --
---------------------------
L = DBM:GetModLocalization(157)

L:SetOptionLocalization({
	TBwarnWhileBlackout		= "Exibir aviso para $spell:92898 quando $spell:86788 estiver ativo",
	TwilightBlastArrow		= "Exibir seta do DBM quando $spell:92898 estiver próximo a você",
	RangeFrame				= "Mostrar medidor de distância (10m)",
	BlackoutShieldFrame		= "Usar uma barra de vida para mostrar a vida do chefe durante $spell:92878",
	BlackoutIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92878),
	EngulfingIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(86622)
})

L:SetMiscLocalization({
	Trigger1				= "Respiração profunda!",
	BlackoutTarget			= "Apagão: %s"
})

----------------------------------
--  Twilight Ascendant Council  --
----------------------------------
L = DBM:GetModLocalization(158)

L:SetWarningLocalization({
	specWarnBossLow			= "%s abaixo de 30%% - próxima fase em breve!",
	SpecWarnGrounded		= "Pegue Aterrado",
	SpecWarnSearingWinds	= "Pegue Ventos Revoltos"
})

L:SetTimerLocalization({
	timerTransition			= "Transição de fase"
})

L:SetOptionLocalization({
	specWarnBossLow			= "Ebibir aviso especial quando os chefes tiverem menos de 30% de vida",
	SpecWarnGrounded		= "Exibir aviso especial quando você estiver sem o efeito de $spell:83581<br/>(~10seg antes do lançamento)",
	SpecWarnSearingWinds	= "Exibir aviso especial quando você estiver sem o efeito de $spell:83500<br/>(~10seg antes do lançamento)",
	timerTransition			= "Exibir cronógrafo de transição de fase",
	RangeFrame				= "Exibir medidor de distância automaticamente, quando necessário",
	yellScrewed				= "Gritar quando você tiver $spell:83099 e $spell:92307 ao mesmo tempo",
	InfoFrame				= "Mostrar quadro de informações para jogadores sem $spell:83581 ou $spell:83500",
	HeartIceIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82665),
	BurningBloodIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82660),
	LightningRodIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(83099),
	GravityCrushIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(84948),
	FrostBeaconIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92307),
	StaticOverloadIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92067),
	GravityCoreIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92075)
})

L:SetMiscLocalization({
	Quake			= "The ground beneath you rumbles ominously....",
	Thundershock	= "The surrounding air crackles with energy....",
	Switch			= "Enough of this foolishness!",--"We will handle them!" comes 3 seconds after this one
	Phase3			= "An impressive display...",--"BEHOLD YOUR DOOM!" is about 13 seconds after
	Kill			= "Impossible....",
	blizzHatesMe	= "Pára-raios e Sinalizador Gélido em mim! Abram espaço!",--You're probably fucked, and gonna kill half your raid if this happens, but worth a try anyways :).
	WrongDebuff	= "Sem %s"
})

----------------
--  Cho'gall  --
----------------
L = DBM:GetModLocalization(167)

L:SetOptionLocalization({
	CorruptingCrashArrow	= "Exibir seta do DBM quando $spell:93178 for cair próximo a você",
	InfoFrame				= "Mostrar quadro de informações para $journal:3165",
	RangeFrame				= "Mostrar medidor de distância (5) para $spell:82235",
	SetIconOnWorship		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(91317)
})

----------------
--  Sinestra  --
----------------
L = DBM:GetModLocalization(168)

L:SetWarningLocalization({
	WarnOrbSoon			= "Orbes em %d seg!",
	SpecWarnOrbs		= "Orbes chegando! Atenção!",
	warnWrackJump		= "%s pulou para >%s<",
	warnAggro			= "Jogadores com ameaça (Sujeitos a orbes): >%s< ",
	SpecWarnAggroOnYou	= "Você tem ameaça! Atenção aos Orbes!"
})

L:SetTimerLocalization({
	TimerEggWeakening	= "Carapaça Crepuscular desvanece",
	TimerEggWeaken		= "Carapaça Crepuscular regenera-se",
	TimerOrbs			= "Recarga de Orbes Sombrios"
})

L:SetOptionLocalization({
	WarnOrbSoon			= "Exibir aviso antecipado para orbes ( 5s antes, a cada 1s)<br/>(Pode não ser correto. Pode causar spam.)",
	warnWrackJump		= "Anunciar quando $spell:92955 saltar de alvo",
	warnAggro			= "Anunciar jogadores que tem Ameaça quando os orbes surgirem (podem ser alvo dos orbes)",
	SpecWarnAggroOnYou	= "Exibir aviso especial se você tiver Ameaça quando os orbes surgirem<br/>(você pode ser o alvo dos orbes)",
	SpecWarnOrbs		= "Exibir aviso especial quando orbes surgirem (Aviso esperado)",
	TimerEggWeakening	= "Exibir cronógrafo para quando $spell:87654 desvanescer",
	TimerEggWeaken		= "Exibir cronógrafo para regeneração de $spell:87654",
	TimerOrbs			= "Exibir cronógrafo para os próximos orbes (Tempo esperado, Pode não ser correto)",
	SetIconOnOrbs		= "Colocar ícones em jogadores que tenham Ameaça quando Orbes surgirem<br/>(possíveis alvos dos Orbes)",
	InfoFrame			= "Exibir quadro de informações para jogadores que tem ameaça"
})

L:SetMiscLocalization({
	YellDragon			= "Feed, children!  Take your fill from their meaty husks!",
	YellEgg				= "You mistake this for weakness?  Fool!",
	HasAggro			= "Has Aggro"
})

-------------------------------------
--  The Bastion of Twilight Trash  --
-------------------------------------
L = DBM:GetModLocalization("BoTrash")

L:SetGeneralLocalization({
	name =	"Trash de Bastião do Crepúsculo"
})

------------------------
--  Conclave of Wind  --
------------------------
L = DBM:GetModLocalization(154)

L:SetWarningLocalization({
	warnSpecial			= "Furacão/Zéfiro/Tempestade de Granizo ativos",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial		= "Habilidades especiais ativas!",
	warnSpecialSoon		= "Habilidades especiais em 10 segundos!"
})

L:SetTimerLocalization({
	timerSpecial		= "Habilidades Especiais recarga",
	timerSpecialActive	= "Habilidades Especiais ativas"
})

L:SetOptionLocalization({
	warnSpecial			= "Exibir aviso quando Furacão/Zéfiro/Tempestade de Granizo são lançadas",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial		= "Exibir aviso quando habilidades especiais são lançadas",
	timerSpecial		= "Exibir cronógrafo para recarga de habilidades especiais",
	timerSpecialActive	= "Exibir cronógrafo para duração de habilidades especiais",
	warnSpecialSoon		= "Exibit aviso antecipado 10 segundos antes de habilidades especiais",
	OnlyWarnforMyTarget	= "Exibir avisos/cronógrafos apenas para o alvo e foco atuais<br/>(Esconde o resto. ISSO INCLUI O AVISO PARA PUXAR)"
})

L:SetMiscLocalization({
	gatherstrength	= "begins to gather strength"
})

---------------
--  Al'Akir  --
---------------
L = DBM:GetModLocalization(155)

L:SetTimerLocalization({
	TimerFeedback 	= "Realimentação (%d)"
})

L:SetOptionLocalization({
	LightningRodIcon= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(89668),
	TimerFeedback	= "Exibir cronógrafo para a duração de $spell:87904",
	RangeFrame		= "Exibir medidor de distância (20), quando afetado por $spell:89668"
})

-----------------
-- Beth'tilac --
-----------------
L= DBM:GetModLocalization(192)

L:SetMiscLocalization({
	EmoteSpiderlings 	= "Spiderlings have been roused from their nest!"
})

-------------------
-- Lord Rhyolith --
-------------------
L= DBM:GetModLocalization(193)

---------------
-- Alysrazor --
---------------
L= DBM:GetModLocalization(194)

L:SetWarningLocalization({
	WarnPhase			= "Fase %d",
	WarnNewInitiate		= "Novato do Gadanho Flamejante (%s)"
})

L:SetTimerLocalization({
	TimerPhaseChange	= "Fase %d",
	TimerHatchEggs		= "Próx. Ovos",
	timerNextInitiate	= "Próx. Novato (%s)"
})

L:SetOptionLocalization({
	WarnPhase			= "Exibir aviso para cada mudança de fase",
	WarnNewInitiate		= "Exibir aviso quando Novato do Gadanho Flamejante surge",
	timerNextInitiate	= "Exibir cronógrafo para o próximo Novato do Gadanho Flamejante",
	TimerPhaseChange	= "Exibir cronógrafo para a próxima fase",
	TimerHatchEggs		= "Exibir cronógrafo para quando os próximos ovos chocarem"
})

L:SetMiscLocalization({
	YellPull		= "I serve a new master now, mortals!",
	YellPhase2		= "These skies are MINE!",
	LavaWorms		= "Fiery Lava Worms erupt from the ground!",--Might use this one day if i feel it needs a warning for something. Or maybe pre warning for something else (like transition soon)
	PowerLevel		= "Penas Ígneas",
	East			= "Leste",
	West			= "Oeste",
	Both			= "Ambos"
})

-------------
-- Shannox --
-------------
L= DBM:GetModLocalization(195)

-------------
-- Baleroc --
-------------
L= DBM:GetModLocalization(196)

L:SetWarningLocalization({
	warnStrike	= "%s (%d)"
})

L:SetTimerLocalization({
	timerStrike			= "Próx. %s",
	TimerBladeActive	= "%s",
	TimerBladeNext		= "Próx. lâmina"
})

L:SetOptionLocalization({
	ResetShardsinThrees	= "Reiniciar contagem de $spell:99259 a cada 3s(25 jogadores)/2s(10 jogadores)",
	warnStrike			= "Show warnings for Decimation/Inferno Strike", -- couldn't find corresponding spells on dungeon journal. Has it been removed?
	timerStrike			= "Show timer for next Decimation/Inferno Strike", -- same as above
	TimerBladeActive	= "Exibir cronógrafo de duração para a Lâmina ativa",
	TimerBladeNext		= "Exibir cronógrafo para a próxima Lâmina da Dizimação/Inferno"
})

--------------------------------
-- Majordomo Fandral Staghelm --
--------------------------------
L= DBM:GetModLocalization(197)

L:SetTimerLocalization({
	timerNextSpecial	= "Próx. %s (%d)"
})

L:SetOptionLocalization({
	timerNextSpecial			= "Exibir cronógrafo para a próxima habilidade especial.",
	RangeFrameSeeds				= "Exibir medidor de distância (12) para $spell:98450",
	RangeFrameCat				= "Exibir medidor de distância (10) para $spell:98374"
})

--------------
-- Ragnaros --
--------------
L= DBM:GetModLocalization(198)

L:SetWarningLocalization({
	warnRageRagnarosSoon	= "%s em %s em 5 seg",--Spellname on targetname
	warnSplittingBlow		= "%s em %s",--Spellname in Location
	warnEngulfingFlame		= "%s em %s",--Spellname in Location
	warnEmpoweredSulf		= "%s em 5 seg"--The spell has a 5 second channel, but tooltip doesn't reflect it so cannot auto localize
})

L:SetTimerLocalization({
	timerRageRagnaros		= "%s em %s",--Spellname on targetname
	TimerPhaseSons			= "Fim da Transição"
})

L:SetOptionLocalization({
	warnRageRagnarosSoon		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.prewarn:format(101109),
	warnSplittingBlow			= "Exibir avisos para local de $spell:100877",
	warnEngulfingFlame			= "Exibir avisos para local de $spell:99171",
	WarnEngulfingFlameHeroic	= "Exibir avisos para local de $spell:99171 (modo heróico)",
	warnSeedsLand				= "Exibir aviso/cronógrafo para queda de $spell:98520 ao invés do lançamento",
	warnEmpoweredSulf			= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.cast:format(100997),
	timerRageRagnaros			= DBM_CORE_L.AUTO_TIMER_OPTIONS.cast:format(101109),
	TimerPhaseSons				= "Exibir cronógrafo de duração da \"Fase dos Filhos das Chamas\"",
	InfoHealthFrame				= "Exibir quadro de informações de vida (<100k pv)",
	MeteorFrame					= "Exibir quadro de informações para alvos de $spell:99849",
	AggroFrame					= "Exibir quadro de informações de jogadores que não tem ameaça durante Elementais Derretidos"
})

L:SetMiscLocalization({
	East				= "Leste",
	West				= "Oeste",
	Middle				= "Meio",
	North				= "Frente",
	South				= "Fundo",
	HealthInfo			= "Abaixo de 100k PV",
	HasNoAggro			= "Sem Ameaça",
	MeteorTargets		= "Ó Deus, Meteoros!",--Keep rollin' rollin' rollin' rollin'.
	TransitionEnded1	= "Enough! I will finish this.",--More reliable then adds method.
	TransitionEnded2	= "Sulfuras will be your end.",
	TransitionEnded3	= "Fall to your knees, mortals!  This ends now.",
	Defeat				= "Too soon! ... You have come too soon...",
	Phase4				= "Too soon..."
})

-----------------------
--  Firelands Trash  --
-----------------------
L = DBM:GetModLocalization("FirelandsTrash")

L:SetGeneralLocalization({
	name = "Trash de Terras do Fogo"
})

----------------
--  Volcanus  --
----------------
L = DBM:GetModLocalization("Volcanus")

L:SetGeneralLocalization({
	name = "Volcanus" --TODO I have no Idea what's his localized name (not on dungeon journal)
})

L:SetTimerLocalization({
	timerStaffTransition	= "Transição termina"
})

L:SetOptionLocalization({
	timerStaffTransition	= "Exibir cronógrafo para a transição de fase"
})

L:SetMiscLocalization({
	StaffEvent			= "The Branch of Nordrassil reacts violently to %S+ touch!",--Reg expression pull match
	StaffTrees			= "Burning Treants erupt from the ground to aid the Protector!",--Might add a spec warning for this later.
	StaffTransition		= "The fires consuming the Tormented Protector wink out!"
})

-----------------------
--  Nexus Legendary  --
-----------------------
L = DBM:GetModLocalization("NexusLegendary")

L:SetGeneralLocalization({
	name = "Thyrinar" -- TODO no idea of his name either.
})

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
	KohcromWarning	= "Exibir avisos quando Kohcrom imita habilidades.",
	KohcromCD		= "Exibir cronógrafo para a próxima imitação de habilidade de Kohcrom.",
	RangeFrame		= "Exibir medidor de distância (5) para conquista."
})

L:SetMiscLocalization({
})

---------------------
-- Warlord Zon'ozz --
---------------------
L= DBM:GetModLocalization(324)

L:SetOptionLocalization({
    ShadowYell	= "Gritar ao ser afetado por $spell:104600<br/>(Apenas modo heróico)",
	CustomRangeFrame	= "Opções do medidor de distância",
	Never				= "Desabilitado",
	Normal				= "Medidor Normal",
	DynamicPhase2		= "Filtrar penalidades na Fase 2",
	DynamicAlways		= "Sempre filtrar penalidades"
})

L:SetMiscLocalization({
	voidYell	= "Gul'kafh an'qov N'Zoth."--Start translating the yell he does for Void of the Unmaking cast, the latest logs from DS indicate blizz removed the event that detected casts. sigh.
})

-----------------------------
-- Yor'sahj the Unsleeping --
-----------------------------
L= DBM:GetModLocalization(325)

L:SetWarningLocalization({
	warnOozesHit	= "%s absorvidas %s"
})

L:SetTimerLocalization({
	timerOozesActive	= "Glóbulos atacáveis"
})

L:SetOptionLocalization({
	warnOozesHit		= "Anunciar quais glóbulos atingem o chefe",
	timerOozesActive	= "Exibir cronógrafo para quando os Glóbulos se tornam atacáveis",
	RangeFrame			= "Exibir medidor de distância (4) para $spell:104898<br/>(Modo Normal+)"
})

L:SetMiscLocalization({
	Black			= "|cFF424242Negro|r",
	Purple			= "|cFF9932CDPúrpura|r",
	Red				= "|cFFFF0404Vermelho|r",
	Green			= "|cFF088A08Verde|r",
	Blue			= "|cFF0080FFAzul|r",
	Yellow			= "|cFFFFA901Amarelo|r"
})

-----------------------
-- Hagara the Binder --
-----------------------
L= DBM:GetModLocalization(317)

L:SetWarningLocalization({
	WarnPillars				= "%s: %d restantes",
	warnFrostTombCast		= "%s em 8 seg"
})

L:SetTimerLocalization({
	TimerSpecial			= "Primeiro especial"
})

L:SetOptionLocalization({
	WarnPillars				= "Anunciar quantos $journal:3919 ou $journal:4069 restam",
	TimerSpecial			= "Exibir cronógrafo para lançamento da primeira habilidade",
    RangeFrame				= "Exibir medidor de distância: (3) para $spell:105269, (10) para $journal:4327",
	AnnounceFrostTombIcons	= "Anunciar no chat da raide, ícones para alvos de $spell:104451<br/>(requer liderança)",
	warnFrostTombCast		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.cast:format(104448),
	SetIconOnFrostTomb		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(104451),
	SetIconOnFrostflake		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(109325),
	SpecialCount			= "Tocar som de contagem regressiva para $spell:105256 ou $spell:105465",
	SetBubbles				= "Automaticamente desabilitar balões de voz quando $spell:104451 está disponível<br/>(Voltando ao normal ao fim do combate)"
})

L:SetMiscLocalization({
	TombIconSet				= "Ícone de Tumba de Gelo {rt%d} colocado em %s"
})

---------------
-- Ultraxion --
---------------
L= DBM:GetModLocalization(331)

L:SetWarningLocalization({
	specWarnHourofTwilightN		= "%s (%d) em 5s"--spellname Count
})

L:SetTimerLocalization({
	TimerCombatStart	= "Ultraxion pousa"
})

L:SetOptionLocalization({
	TimerCombatStart	= "Exibir cronógrafo para início do combate.",
	ResetHoTCounter		= "Reiniciar contador de Hora do Crepúsculo",--$spell doesn't work in this function apparently so use typed spellname for now.
	Never				= "Nunca",
	ResetDynamic		= "Zerar a cada 3/2 (heróico/normal)",
	Reset3Always		= "Sempre zerar a cada 3",
	SpecWarnHoTN		= "Aviso especial 5s antes de Hora do Crepúsculo. Se configurado para Nunca zerar, a regra de 3 em 3 será utilizada.",
	One					= "1 (ou seja, 1 4 7)",
	Two					= "2 (ou seja, 2 5)",
	Three				= "3 (ou seja, 3 6)"
})

L:SetMiscLocalization({
	Pull				= "Eu sinto uma grande desordem no equilíbrio que se aproxima. O caos incendeia a minha mente!"
})

-------------------------
-- Warmaster Blackhorn --
-------------------------
L= DBM:GetModLocalization(332)

L:SetWarningLocalization({
	SpecWarnElites	= "Elites do Crepúsculo!"
})

L:SetTimerLocalization({
	TimerCombatStart	= "Início do combate",
	TimerAdd			= "Próximos Elites"
})

L:SetOptionLocalization({
	TimerCombatStart	= "Exibir cronógrafo para o início do combate",
	TimerAdd			= "Exibir cronógrafo para o surgimento de próximos Elites do Crepúsculo!",
	SpecWarnElites		= "Exibir aviso especial para novos Elites do Crepúsculo",
	SetTextures			= "Automaticamente desabilitar texturas projetadas durante a fase 1<br/>(Habilita novamente na fase 2)"
})

L:SetMiscLocalization({
	SapperEmote			= "Um draco mergulha para lançar um Sapador do Crepúsculo ao convés!",
	GorionaRetreat			= "se contorce de dor e retira-se entre as nuvens rodopiantes."
})

-------------------------
-- Spine of Deathwing  --
-------------------------
L= DBM:GetModLocalization(318)

L:SetWarningLocalization({
	SpecWarnTendril			= "Segure-se!"
})

L:SetOptionLocalization({
	SpecWarnTendril			= "Exibir aviso especial quando você não tem $spell:109454",
	InfoFrame				= "Exibir quadro de informações para jogadores sem $spell:109454",
	SetIconOnGrip			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(109459),
	ShowShieldInfo			= "Exibir vida do chefe, com uma barra de vida para $spell:105479"
})

L:SetMiscLocalization({
	Pull		= "As placas! Ele está se desfazendo! Destruam as placas e teremos uma chance de derrotá-lo!",
	NoDebuff	= "Sem %s",
	PlasmaTarget	= "Plasma Calcinante: %s",
	DRoll		= "prestes a rolar",
	DLevels			= "nivela"
})

---------------------------
-- Madness of Deathwing  --
---------------------------
L= DBM:GetModLocalization(333)

L:SetOptionLocalization({
	RangeFrame			= "Exibir medidor de distância dinâmico baseado nas penalidades do jogador para<br/>$spell:108649 na dificuldade heróica",
	SetIconOnParasite	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(108649)
})

L:SetMiscLocalization({
	Pull				= "Vocês não fizeram NADA. Seu mundo será DESTRUÍDO."
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("DSTrash")

L:SetGeneralLocalization({
	name =	"Trash de Dragonsoul"
})

L:SetWarningLocalization({
	DrakesLeft			= "Agressores do Crepúsculo restantes: %d"
})

L:SetTimerLocalization({
	TimerDrakes			= "%s",--spellname from mod
})

L:SetOptionLocalization({
	DrakesLeft			= "Anunciar quantos Agressores do Crepúsculo restam",
	TimerDrakes			= "Exibir cronógrafo para quando Assaltantes do Crepúsculo $spell:109904"
})

L:SetMiscLocalization({
	EoEEvent			= "Não adianta, o poder da Alma é muito grande",--Partial
	UltraxionTrash		= "Que bom vê-la novamente, Alexstrasza. Estive ocupado na minha ausência.",
	UltraxionTrashEnded = "Simples dragonetes, experimentos, um meio para uma causa maior. Você verá os frutos da pesquisa que minha prole fez."
})
