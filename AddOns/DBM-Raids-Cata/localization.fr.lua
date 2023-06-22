if GetLocale() ~= "frFR" then return end
local L

----------------
--  Argaloth  --
----------------
L= DBM:GetModLocalization(139)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetMiscLocalization({
})

L:SetOptionLocalization({
	SetIconOnConsuming		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(88954)
})

-----------------
--  Occu'thar  --
-----------------
L= DBM:GetModLocalization(140)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetMiscLocalization({
})

L:SetOptionLocalization({
})

----------------------------------
--  Alizabal, Mistress of Hate  --
----------------------------------
L= DBM:GetModLocalization(339)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetMiscLocalization({
})

L:SetOptionLocalization({
})

-------------------------------
--  Dark Iron Golem Council  --
-------------------------------
L = DBM:GetModLocalization(169)

L:SetTimerLocalization({
	timerShadowConductorCast	= "Conducteur d'ombre",
	timerArcaneBlowbackCast	= "Retour arcanique"
})

L:SetOptionLocalization({
	timerShadowConductorCast	= "Affiche le timer : $spell:92053",
	timerArcaneBlowbackCast	= "Affiche le timer : $spell:91879",
	AcquiringTargetIcon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79501),
	ConductorIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79888),
	BombTargetIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(80094),
	ShadowConductorIcon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92053)
})

L:SetMiscLocalization({
})

--------------
--  Magmaw  --
--------------
L = DBM:GetModLocalization(170)

L:SetWarningLocalization({
	SpecWarnInferno	= "Assemblage d'os flamboyant Imminent (~4s)"
})

L:SetMiscLocalization({
	Slump			= "%s s'effondre vers l'avant et expose ses pinces !",
	HeadExposed		= "%s vient de s'empaler sur la pointe et expose sa tête !",
	YellPhase2			= "Inconcevable ! Vous pourriez vraiment vaincre mon ver de lave !"
})

L:SetOptionLocalization({
	SpecWarnInferno		= "Affiche une pré-alerte spéciale sur $spell:92190 (~4s)",
	RangeFrame		= "Affiche la fenêtre de portée en Phase 2 (5)"
})

-----------------
--  Atramedes  --
-----------------
L = DBM:GetModLocalization(171)

L:SetOptionLocalization({
	InfoFrame			= "Affiche une fenêtre d'info pour le niveau sonore",
	TrackingIcon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(78092)
})

L:SetMiscLocalization({
	Airphase			= "Oui, fuyez ! Chaque foulée accélère votre cœur. Les battements résonnent comme le tonnerre... Assourdissant. Vous ne vous échapperez pas !" -- à vérifier
})

-----------------
--  Chimaeron  --
-----------------
L = DBM:GetModLocalization(172)

L:SetOptionLocalization({
	RangeFrame	= "Affiche la fenêtre de portée (6)",
	SetIconOnSlime	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82935),
	InfoFrame		= "Affiche une fenêtre d'info sur la santé (<10k pv)"
})

L:SetMiscLocalization({
	HealthInfo		= "Info Santé"
})

----------------
--  Maloriak  --
----------------
L = DBM:GetModLocalization(173)

L:SetWarningLocalization({
	WarnPhase		= " Phase %s"
})

L:SetTimerLocalization({
	TimerPhase		= "Prochaine Phase"
})

L:SetOptionLocalization({
	WarnPhase			= "Affiche l'alerte d'une nouvelle phase",
	TimerPhase			= "Affiche le timer de la prochaine phase",
	RangeFrame		= "Affiche la fenêtre de portée (6) durant la Phase Bleue",
	FlashFreezeIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92979),
	BitingChillIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(77760),
	ConsumingFlamesIcon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(77786)
})

L:SetMiscLocalization({
	YellRed		= "Flacon rouge|r dans le chaudron !",-- à vérifier
	YellBlue		= "Flacon bleu|r dans le chaudron !",-- à vérifier
	YellGreen		= "Flacon vert|r dans le chaudron !",-- à vérifier
	YellDark		= "Flacon sombre|r dans le chaudron !"-- à vérifier
})

----------------
--  Nefarian  --
----------------
L = DBM:GetModLocalization(174)

L:SetWarningLocalization({
	OnyTailSwipe		= "(Onyxia) Fouette-queue",
	NefTailSwipe		= "(Nefarian) Fouette-queue",
	OnyBreath			= "(Onyxia) Souffle",
	NefBreath			= "(Nefarian) Souffle"
})

L:SetTimerLocalization({
	OnySwipeTimer		= "(Ony) CD Fouette-queue",
	NefSwipeTimer		= "(Nef) CD Fouette-queue",
	OnyBreathTimer		= "(Ony) CD Souffle",
	NefBreathTimer		= "(Nef) CD Souffle"
})

L:SetOptionLocalization({
	OnyTailSwipe		= "Alerte pour $spell:77827 d'Onyxia",
	NefTailSwipe		= "Alerte pour $spell:77827 de Nefarian",
	OnyBreath			= "Alerte pour $spell:94124 d'Onyxia",
	NefBreath			= "Alerte pour $spell:94124 de Nefarian",
	OnySwipeTimer		= "Affiche le CoolDown $spell:77827 d'Onyxia",
	NefSwipeTimer		= "Affiche le CoolDown $spell:77827 de Nefarian",
	OnyBreathTimer		= "Affiche le CoolDown $spell:94124 d'Onyxia",
	NefBreathTimer		= "Affiche le CoolDown $spell:94124 de Nefarian",
	RangeFrame		= "Affiche la fenêtre de portée (10) lorsque vous avez $spell:79339",
	SetIconOnCinder		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79339)
})

L:SetMiscLocalization({
	NefAoe			= "L'air craque sous l'électricité !", -- à vérifier
	YellPhase2			= "Soyez maudits, mortels ! Un tel mépris pour les possessions d'autrui doit être traité avec une extrême fermeté !", -- à vérifier
	YellPhase3			= "J'ai tout fait pour être un hôte accomodant, mais vous ne daignez pas mourir ! Oublions les bonnes manières et passons aux choses sérieuses... VOUS TUER TOUS !",
	ShadowBlazeExact		= "Shadowblaze in %ds",
	ShadowBlazeEstimate		= "Shadowblaze soon (~5s)"
})

-------------------------------
--  Blackwing Descent Trash  --
-------------------------------
L = DBM:GetModLocalization("BWDTrash")

L:SetGeneralLocalization({
	name = "Blackwing Descent Trash"
})

--------------------------
--  Halfus Wyrmbreaker  --
--------------------------
L= DBM:GetModLocalization(156)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetMiscLocalization({
})

L:SetOptionLocalization({
})

---------------------------
--  Valiona & Theralion  --
---------------------------
L= DBM:GetModLocalization(157)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
	TwilightBlastArrow		= "Afficher la flèche DBM lorsque $spell:92898 est près de vous",
	RangeFrame				= "Afficher la fenêtre de portée (10)",
	BlackoutIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92878),
	EngulfingIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(86622)
})

L:SetMiscLocalization({
	Trigger1				= "Theralion, je m'occupe du vestibule. Couvre leur fuite !"--Change this to what deep breath emote is.
})

----------------------------------
--  Twilight Ascendant Council  --
----------------------------------
L= DBM:GetModLocalization(158)

L:SetWarningLocalization({
	specWarnBossLow	= ">%s< en dessous de 30%",
	SpecWarnGrounded	= "Obtenir le buff Liaison à la masse",
	SpecWarnSearingWinds	= "Obtenir le buff Vents tournoyants"
})

L:SetTimerLocalization({
	timerTransition		= "Changement de phase"
})

L:SetMiscLocalization({
	Quake		= "Le sol sous vos pieds gronde avec menace...", -- A verifier ...
	Thundershock	= "L'air qui vous entoure crépite d'énergie...", -- A verifier ...
	Switch		= "Nous allons nous occuper d'eux !", -- A verifier ...
	Phase3		= "CONTEMPLEZ VOTRE DESTIN !", -- A verifier ...
	Kill			= "Impossible...."
})

L:SetOptionLocalization({
	specWarnBossLow	= "Alerte spéciale lorsque les Boss sont en dessous de 30% de PV",
	SpecWarnGrounded	= "Alerte spéciale lorsque vous manquez l'amélioration $spell:83581 <br/>(~10sec avant le lancement du sort)",
	SpecWarnSearingWinds	= "Alerte spéciale lorsque vous manquez l'amélioration  $spell:83500 <br/>(~10sec avant le lancement du sort)",
	timerTransition		= "Affiche le temps pour: Changement de phase",
	RangeFrame		= "Affiche automatiquement la fenêtre de portée lorsque c'est nécessaire",
	HeartIceIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82665),
	BurningBloodIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82660),
	LightningRodIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(83099),
	GravityCrushIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(84948),
	FrostBeaconIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92307),
	StaticOverloadIcon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92067),
	GravityCoreIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92075)
})

----------------
--  Cho'gall  --
----------------
L= DBM:GetModLocalization(167)

L:SetWarningLocalization({
--	WarnPhase2Soon	= "Phase 2 imminente"
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
--	WarnPhase2Soon		= "Afficher la pré-alerte pour la Phase 2",
	CorruptingCrashArrow	= "Afficher la flèche DBM lorsque $spell:93178 est près de vous",
	InfoFrame			= "Afficher la fenêtre d'info pour le sort $journal:3165",
	RangeFrame		= "Afficher la fenêtre de portée (5) pour $spell:82235",
	SetIconOnWorship	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(91317)
})

----------------
--  Sinestra  --
----------------
L= DBM:GetModLocalization(168)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetMiscLocalization({
})

L:SetOptionLocalization({
})

-------------------------------------
--  The Bastion of Twilight Trash  --
-------------------------------------
L = DBM:GetModLocalization("BoTrash")

L:SetGeneralLocalization({
	name =	"The Bastion of Twilight Trash"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

------------------------
--  Conclave of Wind  --
------------------------
L = DBM:GetModLocalization(154)

L:SetWarningLocalization({
	warnSpecial			= "Ouragan/Zéphyr/Tempête de grésil Actifs",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial		= "Abiletés Speciales Activées!"
})

L:SetTimerLocalization({
	timerSpecial			= "CD Abiletés Speciales",
	timerSpecialActive		= "Abiletés Speciales Actives"
})

L:SetOptionLocalization({
	warnSpecial		= "Alerter lorsque Ouragan/Zéphyr/Tempête de grésil  sont cast",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial		= "Alerter lorsque les abiletés spéciales sont cast",
	timerSpecial		= "Afficher le timer des cooldown des abiletés spéciales",
	timerSpecialActive	= "Afficher le timer de la durée des abiletés spéciales"
})

L:SetMiscLocalization({
	gatherstrength			= "%s commence à rassembler ses forces à partir des autres Seigneurs du Vent !"
})

---------------
--  Al'Akir  --
---------------
L = DBM:GetModLocalization(155)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
	TimerFeedback 	= "Réaction (%d)"
})

L:SetOptionLocalization({
	LightningRodIcon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(89668),
	TimerFeedback	= "Afficher le timer pour la durée de: $spell:87904"
})

-----------------
-- Beth'tilac --
-----------------
L = DBM:GetModLocalization(192)

L:SetMiscLocalization({
	EmoteSpiderlings 	= "De jeunes araignées sont sorties de leur nid !"
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
	WarnPhase			= "Phase %d",
	WarnNewInitiate		= "Initié de la Serre flamboyante (%s)"
})

L:SetTimerLocalization({
	TimerPhaseChange	= "Phase %d",
	TimerHatchEggs		= "Prochains œufs",
	timerNextInitiate	= "Prochain initié (%s)"
})

L:SetOptionLocalization({
	WarnPhase			= "Alerte à chaque changement de phase",
	WarnNewInitiate		= "Alerte lors de l'arrivée d'un nouvel Initié de la Serre flamboyante",
	timerNextInitiate	= "Délai avant l'arrivée d'un nouvel Initié de la Serre flamboyante",
	TimerPhaseChange	= "Délai avant la prochaine phase",
	TimerHatchEggs		= "Délai avant que les œufs n'éclosent"
})

L:SetMiscLocalization({
	YellPull		= "Je sers désormais un nouveau maître, mortels !",
	YellPhase2		= "Ce ciel est à MOI.",
	LavaWorms		= "Des vers de lave embrasés surgissent du sol !",--Might use this one day if i feel it needs a warning for something. Or maybe pre warning for something else (like transition soon)
	PowerLevel		= "Plumes de feu",
	East			= "Est",
	West			= "Ouest",
	Both			= "Les deux"
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
	timerStrike			= "Prochain %s",
	TimerBladeActive	= "%s",
	TimerBladeNext		= "Prochaine lame"
})

L:SetOptionLocalization({
	ResetShardsinThrees	= "Relance du compteur de $spell:99259 par paquet de 3s(25m)/2s(10m)",
	warnStrike			= "Alerte concernant la Frappe de décimation/du feu d'enfer",
	timerStrike			= "Délai avant la prochaine Frappe de décimation/du feu d'enfer",
	TimerBladeActive	= "Durée de la lame active",
	TimerBladeNext		= "Délai avant la prochaine Lame de décimation/infernale"
})

--------------------------------
-- Majordomo Fandral Staghelm --
--------------------------------
L= DBM:GetModLocalization(197)

L:SetTimerLocalization({
	timerNextSpecial	= "Prochain %s (%d)"
})

L:SetOptionLocalization({
	timerNextSpecial			= "Délai avant la prochaine technique spéciale",
	RangeFrameSeeds				= "Cadre des portées (12) pour $spell:98450",
	RangeFrameCat				= "Cadre des portées (10) pour $spell:98374"
})

--------------
-- Ragnaros --
--------------
L= DBM:GetModLocalization(198)

L:SetWarningLocalization({
	warnRageRagnarosSoon	= "%s sur %s dans 5 sec.",--Spellname on targetname
	warnSplittingBlow		= "%s %s",--Spellname in Location
	warnEngulfingFlame		= "%s %s",--Spellname in Location
	warnAggro				= "Vous avez l'aggro d'un Elémentaire du magma",
	warnNoAggro				= "Vous n'avez pas l'aggro d'un Elémentaire du magma",
	warnEmpoweredSulf		= "%s dans 5 sec."--The spell has a 5 second channel, but tooltip doesn't reflect it so cannot auto localize
})

L:SetTimerLocalization({
	timerRageRagnaros		= "%s sur %s",--Spellname on targetname
	TimerPhaseSons			= "Fin de la transition"
})

L:SetOptionLocalization({
	warnRageRagnarosSoon		= "Alerte préventive concernant $spell:101109",
	warnSplittingBlow			= "Alerte concernant $spell:100877",
	warnEngulfingFlame			= "Alerte de position concernant $spell:99171",
	WarnEngulfingFlameHeroic	= "Alerte de position concernant $spell:99171 en héroïque",
	warnSeedsLand				= "Alerte/Délai concernant l'impact de $spell:98520 au lieu des incant. de graînes",
	ElementalAggroWarn			= "Alerte indiquant si vous avez ou non l'aggro d'un Elém. du magma",
	warnEmpoweredSulf			= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.cast:format(100997),
	timerRageRagnaros			= DBM_CORE_L.AUTO_TIMER_OPTIONS.cast:format(101109),
	TimerPhaseSons				= "Durée de la \"phase des Fils des flammes\"",
	InfoHealthFrame				= "Cadre d'infos concernant les vies (<110k pv)",
	MeteorFrame					= "Cadre d'infos concernant les cibles de $spell:99849",
	AggroFrame					= "Cadre d'infos indiquant les joueurs n'ayant pas l'aggro des Elém. du magma"
})

L:SetMiscLocalization({
	East				= "à l'est",
	West				= "à l'ouest",
	Middle				= "au milieu",
	North				= "en mêlée",
	South				= "à l'arrière",
	HealthInfo			= "Moins de 90k PV",
	HasNoAggro			= "Sans aggro",
	MeteorTargets		= "ZOMG des météores !",
	TransitionEnded1	= "Assez ! Je vais en finir.",
	TransitionEnded2	= "Sulfuras sera votre fin.",
	TransitionEnded3	= "À genoux, mortels ! C'est la fin.",
	Defeat				= "Trop tôt !... Vous êtes arrivés trop tôt...", -- à vérifier
	Phase4				= "Trop tôt..." -- à vérifier
})

-----------------------
--  Firelands Trash  --
-----------------------
L = DBM:GetModLocalization("FirelandsTrash")

L:SetGeneralLocalization({
	name = "Trash des terres de Feu"
})

----------------
--  Volcanus  --
----------------
L = DBM:GetModLocalization("Volcanus")

L:SetGeneralLocalization({
	name = "Volcanus"
})

L:SetTimerLocalization({
	timerStaffTransition	= "Fin de la transition"
})

L:SetOptionLocalization({
	timerStaffTransition	= "Durée de la transition de phase"
})

L:SetMiscLocalization({
	StaffEvent			= "La branche de Nordrassil réagit violemment au contact |2 %S+ !",--Reg expression pull match
	StaffTrees			= "Des tréants ardents surgissent du sol pour aider le protecteur !",--Might add a spec warning for this later.
	StaffTransition		= "Les flammes consumant le protecteur tourmenté s’éteignent !"
})

-----------------------
--  Nexus Legendary  --
-----------------------
L = DBM:GetModLocalization("NexusLegendary")

L:SetGeneralLocalization({
	name = "Thyrinar"
})

-------------
-- Morchok --
-------------
L= DBM:GetModLocalization(311)

L:SetWarningLocalization({
	KohcromWarning	= "%s : %s"
})

L:SetTimerLocalization({
	KohcromCD		= "Kohcrom mimicks %s"
})

L:SetOptionLocalization({
	KohcromWarning	= "Alerte lorsque Kohcrom imite des compétences",
	KohcromCD		= "Délai avant la prochaine compétence imitiée par Kohcrom",
	RangeFrame		= "Cadre des portées (5) pour le haut fait"
})

L:SetMiscLocalization({
})

---------------------
-- Warlord Zon'ozz --
---------------------
L= DBM:GetModLocalization(324)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
	ShadowYell			= "Yell when you are affected by $spell:104600<br/>(Heroic difficulty only)",
	CustomRangeFrame	= "Range Frame options",
	Never				= "Disabled",
	Normal				= "Normal Range Frame",
	DynamicPhase2		= "Phase2 Debuff Filtering",
	DynamicAlways		= "Always Debuff Filtering"
})

L:SetMiscLocalization({
	voidYell	= "Gul'kafh an'qov N'Zoth."
})

-----------------------------
-- Yor'sahj the Unsleeping --
-----------------------------
L= DBM:GetModLocalization(325)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
	timerOozesActive	= "Gelées attaquables"
})

L:SetOptionLocalization({
	timerOozesActive	= "Délai avant que les gelées ne soient attaquables après leur apparition",
	RangeFrame			= "Cadre des portées (4) pour $spell:104898<br/>(difficulté Normal+)"
})

L:SetMiscLocalization({
	Black			= "|cFF424242noir|r",
	Purple			= "|cFF9932CDviolet|r",
	Red				= "|cFFFF0404rouge|r",
	Green			= "|cFF088A08vert|r",
	Blue			= "|cFF0080FFbleu|r",
	Yellow			= "|cFFFFA901jaune|r"
})

-----------------------
-- Hagara the Binder --
-----------------------
L= DBM:GetModLocalization(317)

L:SetWarningLocalization({
	warnFrostTombCast		= "%s dans 8 sec."
})

L:SetTimerLocalization({
	TimerSpecial			= "1er spécial"
})

L:SetOptionLocalization({
	TimerSpecial			= "Délai avant la première incantation d'une technique spéciale",
	RangeFrame				= "Cadre des portées (3) pour $spell:105269",
	AnnounceFrostTombIcons	= "Annonce des icônes des cibles de $spell:104451 au canal Raid<br/>(nécessite d'être le chef du raid)",
	warnFrostTombCast		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.cast:format(104448),
	SetIconOnFrostTomb		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(104451),
	SetIconOnFrostflake		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(109325)
})

L:SetMiscLocalization({
	TombIconSet				= "Icône de Tombeau de glace {rt%d} placée sur %s"
})

---------------
-- Ultraxion --
---------------
L= DBM:GetModLocalization(331)

L:SetWarningLocalization({
	specWarnHourofTwilightN		= "%s (%%d)"--spellname Count
})

L:SetTimerLocalization({
	TimerCombatStart	= "Ultraxion atterrit"
})

L:SetOptionLocalization({
	TimerCombatStart	= "Durée du RP d'Ultraxion",
	ResetHoTCounter		= "Restart Hour of Twilight counter",--$spell doesn't work in this function apparently so use typed spellname for now.
	Never				= "Never",
	ResetDynamic		= "Reset in sets of 3/2 (heroic/normal)",
	Reset3Always		= "Always Reset in sets of 3"
})

L:SetMiscLocalization({
	Pull				= "Je sens un grand trouble dans l'équilibre qui s'approche. Un chaos tel qu'il me brùle l'esprit !"
})

-------------------------
-- Warmaster Blackhorn --
-------------------------
L= DBM:GetModLocalization(332)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
	TimerCombatStart	= "Début du combat"
})

L:SetOptionLocalization({
	TimerCombatStart	= "Délai avant le début du combat"
})

L:SetMiscLocalization({
	SapperEmote			= "Un drake plonge et dépose un sapeur du Crépuscule sur le pont !",
	Broadside			= "spell:110153",
	DeckFire			= "spell:110095"
})

-------------------------
-- Spine of Deathwing  --
-------------------------
L= DBM:GetModLocalization(318)

L:SetWarningLocalization({
	SpecWarnTendril			= "Accrochez-vous !"
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
	SpecWarnTendril			= "Alerte spéciale quand vous n'avez pas $spell:109454",
	InfoFrame				= "Cadre d'infos indiquant les joueurs sans $spell:109454",
	SetIconOnGrip			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(109459),
	ShowShieldInfo			= "Cadre des vies du boss avec une barre de vie pour $spell:109479"
})

L:SetMiscLocalization({
	Pull		= "Les plaques ! Il tombe en morceaux ! Arrachez les plaques et on aura une chance de le descendre !",
	NoDebuff	= "Sans %s",
	PlasmaTarget	= "Plasma incendiaire : %s",
	DRoll		= "va faire un tonneau"
})

---------------------------
-- Madness of Deathwing  --
---------------------------
L= DBM:GetModLocalization(333)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	Pull				= "Vous n'avez RIEN fait. Je vais mettre votre monde en PIÈCES."
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("DSTrash")

L:SetGeneralLocalization({
	name =	"Dragonsoul Trash"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	UltraxionTrash		= "It is good to see you again, Alexstrasza. I have been busy in my absence." -- à traduire
})
