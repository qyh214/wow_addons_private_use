if GetLocale() ~= "frFR" then return end

local L

----------------
--  Archavon  --
----------------

L = DBM:GetModLocalization("Archavon")

L:SetGeneralLocalization({
	name = "Archavon"
})

L:SetWarningLocalization({
	WarningShards	= "Eclats de pierre sur >%s<",
	WarningGrab		= "Archavon a Empalé >%s<"
})

L:SetTimerLocalization({
	TimerShards 	= "Eclats de pierre: %s"
})

L:SetMiscLocalization({
	TankSwitch		 = "%%s lunges for (%S+)!"
})

L:SetOptionLocalization({
	TimerShards 	= "Montre le timer pour les Eclats de pierre",
	WarningShards 	= "Montre les alertes pour les Eclats de pierre",
	WarningGrab 	= "Montre l'alerte pour le tank qui a été empalé"
})

--------------
--  Emalon  --
--------------

L = DBM:GetModLocalization("Emalon")

L:SetGeneralLocalization{
	name = "Emalon le guetteur d’orage"
}

L:SetWarningLocalization{
	specWarnNova		= "Nova de foudre",
	warnNova 			= "Alerte pour la Nova de foudre",
	warnOverCharge		= "Surcharger"
}

L:SetTimerLocalization{
	timerMobOvercharge	= "Explosion de Surcharge"
}

L:SetOptionLocalization{
	specWarnNova 		= ("Montre une alerte spéciale pour |cff71d5ff|Hspell:%d|h%s|h|r"):format(64216, "Nova de foudre"),
	warnNova 			= ("Montre une alerte pour |cff71d5ff|Hspell:%d|h%s|h|r"):format(64216, "Nova de foudre"),
	warnOverCharge 		= ("Montre une alerte pour |cff71d5ff|Hspell:%d|h%s|h|r"):format(64218, "Surcharge explosive"),
	timerMobOvercharge	= "Montre le timer pour le séide surchargé (debuff empilable)"
}

---------------
--  Koralon  --
---------------

L = DBM:GetModLocalization("Koralon")

L:SetGeneralLocalization{
	name = "Koralon"
}

L:SetWarningLocalization{
	SpecWarnCinder		= "Vous êtes sur une Braise enflammée ! BOUGEZ !"
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
	SpecWarnCinder		= "Montre une alerte spéciale quand vous êtes dans les Braises enflammées"
}

L:SetMiscLocalization{
	Meteor				= "%s lance Poings météoriques !"
}

-------------------
--  Anub'Rekhan  --
-------------------
L = DBM:GetModLocalization("Anub'Rekhan")

L:SetGeneralLocalization({
	name = "Anub'Rekhan"
})

L:SetWarningLocalization({
	SpecialLocust		= "Nuée de sauterelles!",
	WarningLocustFaded	= "Fin de la nuée de sauterelles"
})

L:SetOptionLocalization({
	SpecialLocust		= "Activer l'avertissement special pour la Nuée de sauterelles",
	WarningLocustFaded	= "Avertir à la fin de la Nuée de sauterelles",
	TimerLocustFade 	= "Afficher le timer pour la fin de la Nuée de sauterelles"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "Arachnophobia"
})

----------------------------
--  Grand Widow Faerlina  --
----------------------------
L = DBM:GetModLocalization("Faerlina")

L:SetGeneralLocalization({
	name = "Grande Veuve Faerlina"
})

L:SetWarningLocalization({
	WarningEmbraceExpire	= "Fin du baisé de la veuve dans 5 sec",
	WarningEmbraceExpired	= "Baisé de la veuve terminé"
})

L:SetOptionLocalization({
	WarningEmbraceExpire	= "Activer l'avertissement de fin du baisé de la veuve",
	WarningEmbraceExpired	= "Afficher un avertissement quand le baisé de la veuve va se terminer"
})

---------------
--  Maexxna  --
---------------
L = DBM:GetModLocalization("Maexxna")

L:SetGeneralLocalization({
	name = "Maexxna"
})

L:SetWarningLocalization({
	WarningSpidersSoon	= "Araignées dans 5 sec",
	WarningSpidersNow	= "Arrivée des araignées!"
})

L:SetTimerLocalization({
	TimerSpider			= "Araignées"
})

L:SetOptionLocalization({
	WarningSpidersSoon	= "Activer le pré-avertissement pour les araignées",
	WarningSpidersNow	= "Activer l'avertissement pour les araignées",
	TimerSpider			= "Montre le timer pour l'arrivée des araignées"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "Arachnophobia"
})

------------------------------
--  Noth the Plaguebringer  --
------------------------------
L = DBM:GetModLocalization("Noth")

L:SetGeneralLocalization({
	name = "Noth le Porte-peste"
})

L:SetWarningLocalization({
	WarningTeleportNow		= "Téléportation!",
	WarningTeleportSoon		= "Téléportation dans in 20 sec"
})

L:SetTimerLocalization({
	TimerTeleport			= "Téléportation",
	TimerTeleportBack		= "Retour de TP"
})

L:SetOptionLocalization({
	WarningTeleportNow		= "Activer l'avertissement pour la téléporation",
	WarningTeleportSoon		= "Activer le pré-avertissement pour la téléporation",
	TimerTeleport			= "Activer le timer pour la téléporation",
	TimerTeleportBack		= "Activer le timer pour le retour de North"
})

--------------------------
--  Heigan the Unclean  --
--------------------------
L = DBM:GetModLocalization("Heigan")

L:SetGeneralLocalization({
	name = "Heigan l'Impur"
})

L:SetWarningLocalization({
	WarningTeleportNow		= "Téléportation!",
	WarningTeleportSoon		= "Téléporation dans %d sec"
})

L:SetTimerLocalization({
	TimerTeleport			= "Téléporation"
})

L:SetOptionLocalization({
	WarningTeleportNow		= "Activer l'avertissement de Téléporation",
	WarningTeleportSoon		= "Activer le pré-avertissement de Téléporation",
	TimerTeleport			= "Activer le timer pour la Téléporation"
})

----------------
--  Lolotheb  --
----------------
L = DBM:GetModLocalization("Loatheb")

L:SetGeneralLocalization({
	name = "Horreb"
})

L:SetWarningLocalization({
	WarningHealSoon		= "Soins possibles dans 3 sec",
	WarningHealNow		= "SOIGNEZ MAINTENANT!"
})

L:SetOptionLocalization({
	WarningHealSoon		= "Activer l'avertissement \"Soins dans 3 sec\" ",
	WarningHealNow		= "Activer l'avertissement \"SOIGNEZ MAINTENANT\" "
})

-----------------
--  Patchwerk  --
-----------------
L = DBM:GetModLocalization("Patchwerk")

L:SetGeneralLocalization({
	name = "Le recousu"
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	yell1 		     	= "R'cousu veut jouer !",
	yell2 		     	= "R'cousu avatar de guerre pour Kel'Thuzad !"
})

-----------------
--  Grobbulus  --
-----------------
L = DBM:GetModLocalization("Grobbulus")

L:SetGeneralLocalization({
	name = "Grobbulus"
})

-------------
--  Gluth  --
-------------
L = DBM:GetModLocalization("Gluth")

L:SetGeneralLocalization({
	name = "Gluth"
})

----------------
--  Thaddius  --
----------------
L = DBM:GetModLocalization("Thaddius")

L:SetGeneralLocalization({
	name = "Thaddius"
})

L:SetMiscLocalization({
	Yell					= "Stalagg écraser toi !",
	Emote					= "%s entre en surcharge !",
	Emote2					= "Bobine de Tesla entre en surcharge !",
	Boss1 					= "Feugen",
	Boss2 					= "Stalagg",
	Charge1 				= "négative",
	Charge2 				= "positive"
})

L:SetOptionLocalization({
	WarningChargeChanged	= "Activer l'avertissement spécial quand votre polarité a changé",
	WarningChargeNotChanged	= "Activer l'avertissement spécial quand votre polarité n'a pas changé",
	TimerShiftCast			= "Afficher le timer pour le cast du changement de polarité",
	AirowEnabled			= "Afficher les flèches (stratégie normale : \"2 camps\")",
	ArrowsRightLeft			= "Afficher les flèches droite/gauche pour la stratégie \"4 camps\" (flèche gauche si la polarité a changé et droite sinon)",
	ArrowsInverse			= "Inverser la statégie \"4 camps\" (afficher la flèche droite si la polarité a changé et la gauche sinon)"
})

L:SetWarningLocalization({
	WarningChargeChanged	= "Polarité changée : %s",
	WarningChargeNotChanged	= "Même polarité"
})

-----------------
--  Razuvious  --
-----------------
L = DBM:GetModLocalization("Razuvious")

L:SetGeneralLocalization({
	name = "Razuvious"
})

L:SetMiscLocalization({
	Yell1 					= "Pas de quartier !",
	Yell2 					= "Les cours sont terminés ! Montrez-moi ce que vous avez appris !",
	Yell3 					= "Faites ce que vous ai appris !",
	Yell4 					= "Frappe-le à la jambe"
})

L:SetOptionLocalization({
	WarningShieldWallSoon	= "Activer l'avertissement du Mur de Bouclier"
})

L:SetWarningLocalization({
	WarningShieldWallSoon	= "Mur de Bouclier expire dans 5 sec"
})

--------------
--  Gothik  --
--------------
L = DBM:GetModLocalization("Gothik")

L:SetGeneralLocalization({
	name = "Gothik"
})

L:SetOptionLocalization({
	TimerWave			= "Afficher le timer des vagues",
	TimerPhase2			= "Afficher le timer pour la Phase 2",
	WarningWaveSoon		= "Activer le pré-avertissement pour les Vagues",
	WarningWaveSpawned	= "Avertir quand une vague est arrivée",
	WarningRiderDown	= "Avertir quand un Cavalier meurt",
	WarningKnightDown	= "Avertir quand un Chevalier meurt",
	WarningPhase2		= "Activer l'avertissement pour la Phase 2"
})

L:SetTimerLocalization({
	TimerWave			= "Vague #%d",
	TimerPhase2			= "Phase 2"
})

L:SetWarningLocalization({
	WarningWaveSoon		= "Vague %d: %s dans 3 sec",
	WarningWaveSpawned	= "Vague %d: %s arrivée",
	WarningRiderDown	= "Cavalier down",
	WarningKnightDown	= "Chevalier down",
	WarningPhase2		= "Phase 2"
})

L:SetMiscLocalization({
	yell				= "Dans votre folie, vous avez provoqué votre propre mort.",
	WarningWave1		= "%d %s",
	WarningWave2		= "%d %s et %d %s",
	WarningWave3		= "%d %s, %d %s et %d %s",
	Trainee				= "Recrues",
	Knight				= "Chevaliers",
	Rider				= "Cavaliers"
})

----------------
--  Horsemen  --
----------------
L = DBM:GetModLocalization("Horsemen")

L:SetGeneralLocalization({
	name = "Les quatre Cavaliers"
})

L:SetOptionLocalization({
	TimerMark					= "Afficher le timer des Marques",
	WarningMarkSoon				= "Activer le pré-avertissement des Marques",
	WarningMarkNow				= "Activer l'avertissement des Marques",
	SpecialWarningMarkOnPlayer	= "Avertissement spécial quand vous avez plus de 4 marques sur vous"
})

L:SetTimerLocalization({
	TimerMark 					= "Marque %d"
})

L:SetWarningLocalization({
	WarningMarkSoon				= "Marque %d dans 3 sec",
	WarningMarkNow				= "Marque %d!",
	SpecialWarningMarkOnPlayer	= "%s: %s"
})

L:SetMiscLocalization({
	Korthazz					= "Thane Korth'azz",
	Rivendare					= "Baron Vaillefendre",
	Blaumeux					= "Dame Blaumeux",
	Zeliek						= "Sire Zeliek"
})

-----------------
--  Sapphiron  --
-----------------
L = DBM:GetModLocalization("Sapphiron")

L:SetGeneralLocalization({
	name = "Sapphiron"
})

L:SetOptionLocalization({
	WarningAirPhaseSoon	= "Activer le pré-avertissement de la phase en vol",
	WarningAirPhaseNow	= "Activer l'avertissement de la phase en vol",
	WarningLanded		    = "Activer l'avertissement pour la phase au sol",
	TimerAir			    	= "Afficher le timer de la phase en vol",
	TimerLanding		   	= "Afficher le timer de l'atterrissage",
	WarningIceblock			= "Crie dans un glaçon"
})

L:SetMiscLocalization({
	EmoteBreath			    = "prend une grande inspiration",
	WarningYellIceblock	= "Je suis un bloc de glace !"
})

L:SetWarningLocalization({
	WarningAirPhaseSoon	= "Envol dans 10 sec",
	WarningAirPhaseNow	= "Dans les airs",
	WarningLanded		    = "Atterrissage de Sapphiron"
})

L:SetTimerLocalization({
	TimerAir		   		  = "Envol",
	TimerLanding			  = "Atterrissage dans"
})

------------------
--  Kel'thuzad  --
------------------

L = DBM:GetModLocalization("Kel'Thuzad")

L:SetGeneralLocalization({
	name = "Kel'Thuzad"
})

L:SetOptionLocalization({
	TimerPhase2				= "Afficher le timer pour la Phase 2",
	specwarnP2Soon 			= "Montre un timer pour prévenir 10 secondes avant l'arrivée de Kel'Thuzad"
})

L:SetMiscLocalization({
	Yell 					= "Serviteurs, valets et soldats des ténèbres glaciales ! Répondez à l'appel de Kel'Thuzad !"
})

L:SetWarningLocalization({
	specwarnP2Soon  		= "Kel'Thuzad sera actif dans 10 secondes"
})

L:SetTimerLocalization({
	TimerPhase2				= "Phase 2",
	BlastTimer				= "Heal Maintenant !"
})

---------------
--  Shadron  --
---------------
L = DBM:GetModLocalization("Shadron")

L:SetGeneralLocalization({
	name = "Obscuron"
})

---------------
--  Tenebron  --
---------------
L = DBM:GetModLocalization("Tenebron")

L:SetGeneralLocalization({
	name = "Ténébron"
})

---------------
--  Vesperon  --
---------------
L = DBM:GetModLocalization("Vesperon")

L:SetGeneralLocalization({
	name = "Vespéron"
})

---------------
--  Sartharion  --
---------------
L = DBM:GetModLocalization("Sartharion")

L:SetGeneralLocalization({
	name = "Sartharion"
})

L:SetWarningLocalization({
	WarningTenebron			= "Ténébron Arrive",
	WarningShadron			= "Obscuron Arrive",
	WarningVesperon			= "Vespéron Arrive",
	WarningFireWall			= "Tsunami de flammes !",
	WarningVesperonPortal	= "Portail de Vespéron",
	WarningTenebronPortal	= "Portail de Ténébron",
	WarningShadronPortal	= "Portail d'Obscuron"
})

L:SetTimerLocalization({
	TimerTenebron	= "Ténébron Arrive",
	TimerShadron	= "Obscuron Arrive",
	TimerVesperon	= "Vespéron Arrive"
})

L:SetOptionLocalization({
	AnnounceFails		= "Affiche les joueurs qui n'ont pas évité les zones de vide / Tsunamis de flammes (Nécessite l'activation des annonces et être promu ou leader)",
	TimerTenebron		= "Montre le timer pour Ténébron",
	TimerShadron		= "Montre le timer pour Obscuron",
	TimerVesperon		= "Montre le timer pour Vespéron",
	WarningFireWall		= "Montre une alerte spéciale pour les Tsunamis de flammes",
	WarningTenebron		= "Montre le timer avant que Ténébron arrive",
	WarningShadron		= "Montre le timer avant qu'Obscuron arrive",
	WarningVesperon		= "Montre le timer avant que Vespéron arrive",
	WarningTenebronPortal	= "Montre une alerte spéciale pour les portails de Ténébron",
	WarningShadronPortal	= "Montre une alerte spéciale pour les portails d'Obscuron",
	WarningVesperonPortal	= "Montre une alerte spéciale pour les portails de Vespéron"
})

L:SetMiscLocalization({
	Wall			= "lave qui entoure",
	Portal			= "commence à incanter un portail",
	NameTenebron	= "Ténébron",
	NameShadron		= "Obscuron",
	NameVesperon	= "Vespéron",
	FireWallOn		= "Tsunamis de flammes: %s",
	VoidZoneOn		= "Zone de vide : %s",
	VoidZones		= "Zones de vide ratées (cet essai): %s",
	FireWalls		= "Tsunamis de flammes ratés (cet essai): %s"
})

---------------
--  Malygos  --
---------------
L = DBM:GetModLocalization("Malygos")

L:SetGeneralLocalization({
	name = "Malygos"
})

L:SetMiscLocalization({
	YellPull		= "Ma patience a ses limites. Je vais me débarrasser de vous !",
	EmoteSpark		= "de puissance surgit",
	YellPhase2		= "Je pensais mettre rapidement fin à vos existences",
	YellBreath		= "Vous n'arriverez à rien tant qu'il me restera un souffle !",
	YellPhase3		= "Vos bienfaiteurs font enfin leur entrée, mais ils arrivent trop tard !"
})

----------------------
--  FlameLeviathan  --
----------------------
L = DBM:GetModLocalization("FlameLeviathan")

L:SetGeneralLocalization{
	name = "Léviathan des flammes"
}

L:SetTimerLocalization{
}

L:SetMiscLocalization{
	YellPull		= "Entités hostiles détectées. Protocole d'estimation de menace actif. Acquisition de la cible primaire. Décompte avant réévaluation : 30 secondes.",
	Emote			= "%%s poursuit (%S+)%."
}

L:SetWarningLocalization{
	PursueWarn				= "Poursuit >%s<!",
	warnNextPursueSoon		= "Changement de cible dans 5 Sec",
	SpecialPursueWarnYou	= "Vous êtes poursuivi !",
	SystemOverload			= "Extinction des systèmes !",
	warnWardofLife			= "Gardien de Vie vient d'arriver",
	warnWrithingLasher		= "Flagellant frémissant viens d'arriver"
}

L:SetOptionLocalization{
	SystemOverload			= "Afficher l'avertissement spécial pour la surchage du système",
	SpecialPursueWarnYou	= "Afficher l'avertissement spécial quand un joueur est poursuivi",
	PursueWarn				= "Afficher l'avertissement quand vous êtes poursuivi",
	warnNextPursueSoon		= "Prévenir avant la prochaine poursuite",
	warnWardofLife			= "Montre une alerte quand un Gardien de Vie arrive",
	warnWrithingLasher		= "Montre une alerte quand un Flagellant frémissant arrive"
}

-------------
--  Ignis  --
-------------
L = DBM:GetModLocalization("Ignis")

L:SetGeneralLocalization{
	name = "Ignis le maître de la Fournaise"
}

L:SetTimerLocalization{
}

L:SetWarningLocalization{
	WarningSlagPot			= "Marmite de scories sur >%s<",
	SpecWarnJetsCast		= "Flots de flammes - Stop Incantation"
}

L:SetOptionLocalization{
	SpecWarnJetsCast		= "Activer l'avertissement spécial pour les Flots de flammes (contresort)",
	WarningSlagPot			= "Annoncer la cible de la Marmite de scories",
	SlagPotIcon				= "Mettre une icône sur la cible de la Marmite de scories"
}

------------------
--  Razorscale  --
------------------
L = DBM:GetModLocalization("Razorscale")

L:SetGeneralLocalization{
	name = "Tranchécaille"
}

L:SetWarningLocalization{
	SpecWarnDevouringFlame		= "Flamme dévorante - BOUGEZ",
	warnTurretsReadySoon		= "Quatrième tourelle à harpon prête dans 20 Sec",
	warnTurretsReady			= "Quatrième tourelle à harpon prête",
	SpecWarnDevouringFlameCast	= "Flamme dévorante sur Vous",
	WarnDevouringFlameCast		= "Flamme dévorante sur >%s<"
}

L:SetTimerLocalization{
	timerTurret1			= "Tourelle 1",
	timerTurret2			= "Tourelle 2",
	timerTurret3			= "Tourelle 3",
	timerTurret4			= "Tourelle 4",
	timerGrounded		= "Sur le sol"
}

L:SetOptionLocalization{
	SpecWarnDevouringFlame		= "Activer l'avertissement spécial pour les Flammes dévorantes",
	warnTurretsReadySoon		= "Activer le pré-avertissement pour les tourelles",
	warnTurretsReady			= "Activer l'avertissement pour les tourelles",
	SpecWarnDevouringFlameCast	= "Montre une alerte spéciale quand les Flammes dévorantes sont cast sur Vous",
	timerTurret1				= "Montre le timer pour la tourelle 1",
	timerTurret2				= "Montre le timer pour la tourelle 2",
	timerTurret3				= "Montre le timer pour la tourelle 3 (Héroique)",
	timerTurret4				= "Montre le timer pour la tourelle 4 (Héroique)",
	OptionDevouringFlame		= "Annonce la cible des Flammes dévorantes (Incertain)",
	timerGrounded			= "Montre le timer pour la phase au sol"
}

L:SetMiscLocalization{
	YellAir 			= "Laissez un instant pour préparer la construction des tourelles.",
	YellAir2			= "Incendie éteint ! Reconstruisons les tourelles !",
	YellGround		= "Faites vite ! Elle va pas rester au sol très longtemps !",
	EmotePhase2			= "bloquée au sol",
	FlamecastUnknown	= DBM_COMMON_L.UNKNOWN
}

-------------
--  XT002  --
-------------
L = DBM:GetModLocalization("XT002")

L:SetGeneralLocalization{
	name = "Déconstructeur XT-002"
}

L:SetTimerLocalization{
}

L:SetWarningLocalization{
	SpecialWarningLightBomb 	= "Bombe de lumière sur TOI",
	SpecialWarningGravityBomb	= "Bombe à gravité sur TOI",
	specWarnConsumption			= "Zone de Vide - BOUGEZ !"
}

L:SetOptionLocalization{
	SpecialWarningLightBomb		= "Activer l'avertissement spécial quand vous êtes affecté par la bombe de lumière",
	SpecialWarningGravityBomb	= "Activer l'avertissement spécial quand vous êtes affecté par la bombe à gravité",
	specWarnConsumption			= "Montre une alerte spéciale quand vous subissez des dégats venant des Zone de Vide ( Hard-mode )"
}

-------------------
--  IronCouncil  --
-------------------
L = DBM:GetModLocalization("IronCouncil")

L:SetGeneralLocalization{
	name = "Assemblée du Fer"
}

L:SetWarningLocalization{
	WarningSupercharge			= "Supercharge imminente",
	RuneofDeath					= "Rune de mort - BOUGEZ",
	LightningTendrils			= "Vrilles de foudre - COURREZ",
	Overload					= "Surchage - BOUGEZ"
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
	WarningSupercharge			= "Activer l'avertissement quand la Supercharge est incanté",
	LightningTendrils			= "Activer l'avertissement spécial pour les Vrilles d'éclair",
	RuneofDeath					= "Activer l'avertissement spécial pour les runes de mort",
	Overload					= "Montre une alerte spéciale pour la Surcharge",
	AlwaysWarnOnOverload		= "Toujours alerter pour la surcharge (sinon seulement quand ciblé)"
}

L:SetMiscLocalization{
	Steelbreaker		= "Brise-acier",
	RunemasterMolgeim	= "Maître des runes Molgeim",
	StormcallerBrundir 	= "Mande-foudre Brundir"
}

---------------
--  Algalon  --
---------------
L = DBM:GetModLocalization("Algalon")

L:SetGeneralLocalization{
	name = "Algalon l'Observateur"
}

L:SetTimerLocalization{
	NextCollapsingStar		= "Prochain choc cosmique",
	TimerCombatStart		= "Le combat débute dans"
}

L:SetWarningLocalization{
	WarningPhasePunch		= "Coup de poing phasique sur >%s<",
	WarningBlackHole		= "Trou noir",
	SpecWarnBigBang			= "Big Bang",
	PreWarningBigBang		= "Big Bang dans ~10 sec"
}

L:SetOptionLocalization{
	SpecWarnPhasePunch		= "Activer l'avertissement spécial quand vous êtes la cible du coup de poing phasique",
	PreWarningBigBang		= "Pré annonce le Big Bang",
	SpecWarnBigBang			= "Montre une alerte spéciale pour le Big Bang",
	WarningPhasePunch		= "Annoncer la cible du Coup de poing phasique",
	WarningBlackHole		= "Annoncer les trous noirs",
	NextCollapsingStar		= "Montre un timer pour le prochain choque cosmique",
	TimerCombatStart		= "Montre le timer avant le début du combat"
}

L:SetMiscLocalization{
	YellPull				= "Vos actions sont illogiques. Tous les résultats possibles de cette rencontre ont été calculés. Le panthéon recevra le message de l'Observateur quelque soit l'issue.",
	Emote_CollapsingStar	= "commence à lancer un effondrement",
	PullCheck				= "Signal de détresse d'Algalon transmis dans= (%d+) min."
}

----------------
--  Kologarn  --
----------------
L = DBM:GetModLocalization("Kologarn")

L:SetGeneralLocalization{
	name = "Kologarn"
}

L:SetWarningLocalization{
	SpecialWarningEyebeam	= "Rayon de l'Œil sur TOI - ECARTE-TOI",
	WarningEyeBeam			= "Rayon de l'Œil sur >%s<",
	WarnGrip				= "Poigne sur >%s<",
	SpecWarnCrunchArmor2	= "Broie armure >%d< sur Vous"
}

L:SetTimerLocalization{
	timerLeftArm			= "Repop du bras gauche",
	timerRightArm			= "Repop du bras droit",
	achievementDisarmed		= "Temps pour Désarmement"
}

L:SetOptionLocalization{
	SpecialWarningEyebeam	= "Activer l'avertissement spécial quand vous êtes la cible du Rayon de l'Œil",
	SpecWarnCrunchArmor2	= "Montre une alerte spéciale pour Broie armure (>=2 stacks)",
	WarningEyeBeam			= "Annoncer la cible du Rayon de l'Œil",
	timerLeftArm			= "Afficher un timer pour le repop du bras gauche",
	timerRightArm			= "Afficher un timer pour le repop du bras droit",
	achievementDisarmed		= "Afficher un timer pour le Haut Fait Désarmement",
	WarnGrip				= "Annonce les cibles de la poigne"
}

L:SetMiscLocalization{
	Yell_Trigger_arm_left	= "Juste une éraflure !",
	Yell_Trigger_arm_right	= "Une blessure superficielle !",
	Health_Body				= "Torse de Kologarn",
	Health_Right_Arm		= "Bras droit",
	Health_Left_Arm			= "Bras gauche",
	FocusedEyebeam			= "%s concentre son regard sur vous !"
}

---------------
--  Auriaya  --
---------------
L = DBM:GetModLocalization("Auriaya")

L:SetGeneralLocalization{
	name = "Auriaya"
}

L:SetMiscLocalization{
	Defender 			= "Défenseur farouche (%d)",
	YellPull 			= "Certaines choses ne doivent pas être dérangées !"
}

L:SetTimerLocalization{
	timerDefender		= "Défenseur farouche activé"
}

L:SetWarningLocalization{
	SpecWarnVoid		= "Zone de Vide - BOUGEZ!",
	WarnCatDied 		= "Défenseur farouche mort (%d vies restantes)",
	WarnCatDiedOne 		= "Défenseur farouche mort (1 vie en moins)",
	WarnFearSoon 		= "Hurlement terrifiant imminent"
}

L:SetOptionLocalization{
	SpecWarnVoid		= "Montre une alerte spéciale quand vous êtes dans une Zone de Vide",
	WarnFearSoon 		= "Activer l'avertissement pour le Hurlement terrifiant imminent",
	WarnCatDied 		= "Activer l'avertissement quand un défenseur farouche meurt",
	WarnCatDiedOne		= "Montre une alerte spéciale quand un Défenseur farouche meurt",
	timerDefender       = "Montre un timer quand le Défenseur farouche est activé"
}

-------------
--  Hodir  --
-------------
L = DBM:GetModLocalization("Hodir")

L:SetGeneralLocalization{
	name = "Hodir"
}

L:SetWarningLocalization{
	WarningFlashFreeze	= "Gel instantané",
	specWarnBitingCold	= "Froid mordant - BOUGEZ"
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
	WarningFlashFreeze		= "Activer l'avertissement pour le gel instantané",
	YellOnStormCloud		= "Crie quand la tempête de glace est active",
	specWarnBitingCold		= "Montre une alerte spéciale quand vous êtes affecter par Froid mordant"
}

L:SetMiscLocalization{
	YellKill		= "Je suis... libéré de son emprise... enfin.",
	YellCloud		= "Tempête de glace sur moi!"
}

--------------
--  Thorim  --
--------------
L = DBM:GetModLocalization("Thorim")

L:SetGeneralLocalization{
	name = "Thorim"
}

L:SetWarningLocalization{
	LightningOrb 			= "Horion de foudre sur TOI! Bouge!"
}

L:SetTimerLocalization{
	TimerHardmode	= "Mode difficile"
}

L:SetOptionLocalization{
	TimerHardmode			= "Afficher le timer pour le mode difficile",
	AnnounceFails			= "Affiche les joueurs qui n'ont pas évité les Charges de foudre (Nécessite l'activation des annonces et être promu ou leader)",
	LightningOrb			= "Montre une alerte spéciale pour les Charges de foudre"
}

L:SetMiscLocalization{
	YellPhase1		= "Des intrus ! Mortels, vous qui osez me déranger en plein divertissement allez pay -  Attendez, vous -",
	YellPhase2		= "Avortons impertinents, vous osez me défier sur mon piédestal ? Je vais vous écraser moi-même !",
	YellKill		= "Retenez vos coups ! Je me rends !",
	ChargeOn		= "Charge(s) de foudre: %s",
	Charge			= "Charge(s) de foudre non évitée(s) (cet essai): %s"
}

-------------
--  Freya  --
-------------
L = DBM:GetModLocalization("Freya")

L:SetGeneralLocalization{
	name = "Freya"
}

L:SetMiscLocalization{
	SpawnYell 	= "Mes enfants, venez m'aider !",
	WaterSpirit = "Esprit de l'eau ancien",
	Snaplasher 	= "Flagellant mordant",
	StormLasher = "Flagellant des tempêtes",
	YellKill	= "Son emprise sur moi se dissipe. J'y vois à nouveau clair. Merci, héros.",
	TrashRespawnTimer		= "Respawn des Trashs de Freya"
}

L:SetWarningLocalization{
	WarnSimulKill 	= "Premier add mort - Résurrection dans 1 minute",
	SpecWarnFury 	= "Fureur de la nature sur VOUS!",
	WarningTremor   = "Tremblement de terre - Arretez d'incanter!",
	WarnRoots		= "Racines de fer sur >%s<",
	UnstableEnergy	= "Energie instable - BOUGEZ!"
}

L:SetTimerLocalization{
	TimerSimulKill 			= "Résurrection"
}

L:SetOptionLocalization{
	WarnSimulKill	= "Annonce la mort du premier mob",
	WarnRoots		= "Annonce les cibles des racines de fer",
	SpecWarnFury	= "Montre des alertes spéciales pour la Fureur de la Nature",
	WarningTremor	= "Montre une alerte spéciale pour le tremblement de terre (Hard-Mode)",
	TimerSimulKill	= "Montre le timer de la résurrection des mobs",
	UnstableEnergy	= "Montre une alerte spéciale pour l'énergie instable"
}

----------------------
--  Freya's Elders  --
----------------------
L = DBM:GetModLocalization("Freya_Elders")

L:SetGeneralLocalization{
	name = "Freya's Elders"
}

L:SetMiscLocalization{
	TrashRespawnTimer	= "Respawn des Trashs de Freya"
}

L:SetWarningLocalization{
	SpecWarnGroundTremor	= "Tremblement de terre - Arrêtez les sorts !",
	SpecWarnFistOfStone		= "Poings de pierre"
}

L:SetOptionLocalization{
	SpecWarnFistOfStone		= "Montre une alerte spéciale pour le coup de poings de pierre",
	SpecWarnGroundTremor	= "Montre une alerte spéciale pour le tremblement de terre",
	TrashRespawnTimer		= "Montre le timer du repop des trashs"
}

-------------------
--  Mimiron  --
-------------------
L = DBM:GetModLocalization("Mimiron")

L:SetGeneralLocalization{
	name = "Mimiron"
}

L:SetWarningLocalization{
	DarkGlare			= "Barrage laser",
	MagneticCore		= ">%s< vient de loot le Core Magnétique",
	WarningShockBlast	= "Horion explosif - BOUGEZ",
	WarnBombSpawn		= "Robot Bombe vient de pop"
}

L:SetTimerLocalization{
	TimerHardmode		= "Hard Mode - Autodestruction",
	TimeToPhase2		= "Phase 2",
	TimeToPhase3		= "Phase 3",
	TimeToPhase4		= "Phase 4"
}

L:SetOptionLocalization{
	DarkGlare				= "Montre une alerte spéciale pour le Barrage laser",
	TimeToPhase2			= "Montre le timer pour la Phase 2",
	TimeToPhase3			= "Montre le timer pour la Phase 3",
	TimeToPhase4			= "Montre le timer pour la Phase 4",
	MagneticCore			= "Annonce qui a loot le Core Magnétique",
	WarnBombSpawn			= "Annonce les Robots Bombes",
	TimerHardmode			= "Montre le timer pour le Hard Mode",
	ShockBlastWarningInP1	= "Montre une alerte spéciale pour les Horions explosifs durant la Phase 1",
	ShockBlastWarningInP4	= "Montre une alerte spéciale pour les Horions explosifs durant la Phase 4"
}

L:SetMiscLocalization{
	MobPhase1		= "Léviathan Mod. II",
	MobPhase2		= "VX-001",
	MobPhase3		= "Unité de commandement aérien",
	YellPull		= "Nous n'avons pas beaucoup de temps, les amis ! Vous allez m'aider à tester ma dernière création en date, la plus grande de toutes. Avant de changer d'avis, n'oubliez pas que que vous me devez bien ça après m'avoir complètement déglingué le XT-002.",
	YellHardPull	= "Mais, pourquoi",
	YellPhase2		= "MERVEILLEUX ! Résultats parfaitement formidables !",
	YellPhase3		= "Merci, les amis !",
	YellPhase4		= "Fin de la phase d'essais préliminaires"
}


--------------------
--  General Vezax  --
--------------------
L = DBM:GetModLocalization("GeneralVezax")

L:SetGeneralLocalization{
	name = "Général Vezax"
}

L:SetTimerLocalization{
	hardmodeSpawn = "Arriver d'Animus de saronite"
}

L:SetWarningLocalization{
	SpecialWarningShadowCrash		= "Déferlante d'ombre sur VOUS",
	SpecialWarningSurgeDarkness		= "Vague de ténèbres",
	WarningShadowCrash				= "Déferlante d'ombre sur >%s<",
	SpecialWarningShadowCrashNear	= "Déferlante d'ombre à côté de VOUS!",
	WarningLeechLife				= "Marque du Sans-visage sur >%s<",
	SpecialWarningLLYou				= "Marque du Sans-visage sur VOUS!",
	SpecialWarningLLNear			= "Marque du Sans-visage sur %s à côté de VOUS!"
}

L:SetOptionLocalization{
	WarningShadowCrash				= "Montre une alerte spéciale pour les Déferlante d'ombre",
	SpecialWarningSurgeDarkness		= "Montre une alerte spéciale pour les Vague de ténèbres",
	SpecialWarningShadowCrash		= "Montre une alerte spéciale pour les Déferlante d'ombre",
	SpecialWarningShadowCrashNear	= "Montre une alerte spéciale quand la Déferlante d'ombre tombe à côté de vous",
	SpecialWarningLLYou				= "Montre une alerte spéciale quand la Marque du Sans-visage est sur Vous",
	SpecialWarningLLNear			= "Montre une alerte spéciale quand la Marque du Sans-visage est à côté de vous",
	CrashWhisper					= "Envoie un whisp à la cible de la Déferlante d'ombre",
	YellOnLifeLeech					= "Crie pour la Marque du Sans-visage",
	YellOnShadowCrash				= "Crie pour la Déferlante d'ombre",
	WarningLeechLife				= "Annonce la cible de la Marque du Sans-visage",
	hardmodeSpawn					= "Montre le timer pour l'arriver d'Animus de saronite (Hard Mode)"
}

L:SetMiscLocalization{
	EmoteSaroniteVapors	= "nuage de vapeurs saronitiques",
	CrashWhisper		= "Déferlante d'ombre sur toi ! BOUGE !",
	YellLeech			= "Marque du Sans-visage sur moi !",
	YellCrash			= "Déferlante d'ombre sur moi !"
}

------------------
--  Yogg Saron  --
------------------
L = DBM:GetModLocalization("YoggSaron")

L:SetGeneralLocalization{
	name = "Yogg-Saron"
}

L:SetMiscLocalization{
	YellPull 						= "Il sera bientôt temps de frapper la tête de la bête ! Concentrez votre rage et votre haine sur ses laquais !",
	YellPhase2 						= "Je suis le rêve éveillé",
	Sara 							= "Sara",
	WhisperBrainLink 				= "Votre cerveau est lié ! Courez vers %s !"
}

L:SetWarningLocalization{
	WarningGuardianSpawned 			= "Un gardien vient d'arriver",
	WarningCrusherTentacleSpawned	= "Une Tentacule écraseur vient d'arriver",
	WarningBrainLink 				= "Cerveaux liés sur >%s< et >%s<",
	SpecWarnBrainLink 				= "Cerveaux liés sur Vous!",
	WarningSanity 					= "%d de Santé mentale restant",
	SpecWarnSanity 					= "%d de Santé mentale restant",
	SpecWarnGuardianLow				= "Arretez d'attaquer ce gardien !",
	SpecWarnMadnessOutNow			= "Incantation de Susciter la folie fini - SORTEZ",
	WarnBrainPortalSoon				= "Portail dans 3 sec",
	SpecWarnFervor					= "Ferveur de Sara sur VOUS",
	SpecWarnFervorCast				= "Ferveur de Sara commence a incanter sur vous",
	WarnEmpowerSoon					= "Renforcement des ombres Bientôt !",
	SpecWarnDeafeningRoar			= "Rugissement assourdissant",
	specWarnBrainPortalSoon			= "Portail bientôt"
}

L:SetTimerLocalization{
	NextPortal			= "Portail du Cerveau"
}

L:SetOptionLocalization{
	WarningGuardianSpawned			= "Annonce l'arrivée des Gardiens",
	WarningCrusherTentacleSpawned	= "Annonce l'arrivée des Tentacules",
	WarningBrainLink				= "Annonce les Cerveaux liés",
	SpecWarnBrainLink				= "Montre une alerte spéciale quand il y a des Cerveaux liés",
	WarningSanity					= "Montre une alerte quand la Santé mentale est basse",
	SpecWarnSanity					= "Montre une alerte quand la Santé mentale est très basse",
	SpecWarnGuardianLow				= "Montre une alerte spéciale quand les gardiens (P1) n'a plus beaucoup de vie",
	WarnBrainPortalSoon				= "Annonce les Portails",
	SpecWarnMadnessOutNow			= "Montre une alerte spéciale avant la fin du cast de Susciter la folie",
	SpecWarnFervor					= "Montre une alerte spéciale pour la ferveur de Sara",
	SpecWarnFervorCast				= "Montre une alerte spéciale quand la Ferveur de Sara commence a cast sur vous (Il faut avoir Sara en Target/Focus)",
	specWarnBrainPortalSoon			= "Annonce l'arrivée d'un portail",
	NextPortal						= "Montre un timer avant le prochain portail",
	WhisperBrainLink				= "Envoie un whisp aux Cerveaux liés",
	WarnEmpowerSoon					= "Alerte avant le Renforcement des ombres",
	SpecWarnDeafeningRoar			= "Montre une alerte spéciale pour le Rugissement assourdissant (silence et haut-fait)"
}

--------------
--  Onyxia  --
--------------
L = DBM:GetModLocalization("Onyxia")

L:SetGeneralLocalization{
	name = "Onyxia"
}

L:SetWarningLocalization{
	WarnWhelpsSoon		= "Les Jeunes dragonnets onyxien arrivent bientôt"
}

L:SetTimerLocalization{
	TimerWhelps = "Arrivée des Jeunes dragonnets onyxien"
}

L:SetOptionLocalization{
	TimerWhelps				= "Montre le timer pour l'arrivée des Jeunes dragonnets onyxien",
	WarnWhelpsSoon			= "Montre une pré-alerte avant l'arrivée des Jeunes dragonnets onyxien",
	SoundWTF3				= "Joue des sons amusants du légendaire raid classic d'Onyxia"
}

L:SetMiscLocalization{
	YellP2 = "exercice dénué de sens",
	YellP3 = "semble que vous ayez besoin"
}

------------------------
--  Northrend Beasts  --
------------------------
L = DBM:GetModLocalization("NorthrendBeasts")

L:SetGeneralLocalization{
	name = "Les Bêtes du Norfendre"
}

L:SetMiscLocalization{
	Charge			= "fusille (%S+) du regard",
	CombatStart		= "Arrivant tout droit des plus noires et profondes cavernes des pics Foudroyés, Gormok l'Empaleur !",
	Phase2			= "car voici que les terreurs jumelles",
	Phase3			= "de notre prochain combattant",
	Gormok			= "Gormok l'Empaleur",
	Acidmaw			= "Gueule-d'acide",
	Dreadscale		= "Ecaille-d'effroi",
	Icehowl			= "Glace-hurlante"
}

L:SetOptionLocalization{
	WarningSnobold				= "Montre une alerte quand les Vassal arrivent",
	ClearIconsOnIceHowl			= "Enlève toutes les icônes avant la prochaine charge",
	TimerNextBoss				= "Montre le timer pour l'arrivée du prochain boss",
	TimerEmerge					= "Montre le timer avant que les vers rentre dans le sol",
	TimerSubmerge				= "Montre le timer avant que les vers sortent du sol"
}

L:SetTimerLocalization{
	TimerNextBoss				= "Prochain boss dans",
	TimerEmerge					= "Sort du sol",
	TimerSubmerge				= "Rentre dans le sol"
}

L:SetWarningLocalization{
	WarningSnobold				= "Un Vassal frigbold viens d'arriver"
}

-------------------
-- Lord Jaraxxus --
-------------------
L = DBM:GetModLocalization("Jaraxxus")

L:SetGeneralLocalization{
	name = "Seigneur Jaraxxus"
}

L:SetOptionLocalization{
	IncinerateShieldFrame		= "Montre la vie du Boss avec une barre de vie pour Incinérer la chair"
}

L:SetMiscLocalization{
	IncinerateTarget			= "Incinérer la chair: %s"
}

-----------------------
-- Faction Champions --
-----------------------
L = DBM:GetModLocalization("Champions")

L:SetGeneralLocalization{
	name = "Champion des Factions"
}

L:SetMiscLocalization{
	AllianceVictory    = "GLORY TO THE ALLIANCE!",
	HordeVictory       = "That was just a taste of what the future brings. FOR THE HORDE!",
	YellKill				= "Une victoire tragique et depourvue de sens. La perte subie aujourd'hui nous affaiblira tous, car qui d'autre que le roi-liche pourrait beneficier d'une telle folie?? De grands guerriers ont perdu la vie. Et pour quoi?? La vraie menace plane à l'horizon?: le roi-liche nous attend, tous, dans la mort."
}

------------------
-- Valkyr Twins --
------------------
L = DBM:GetModLocalization("ValkTwins")

L:SetGeneralLocalization{
	name = "Soeurs Val'kyr"
}

L:SetTimerLocalization{
	TimerSpecialSpell	= "Prochaine Capacité Spéciale"
}

L:SetWarningLocalization{
	WarnSpecialSpellSoon		= "Capacité spéciale Bientôt !",
	SpecWarnSpecial				= "Changement de couleur !",
	SpecWarnEmpoweredDarkness	= "Ténèbres surpuissantes",
	SpecWarnEmpoweredLight		= "Lumière surpuissante",
	SpecWarnSwitchTarget		= "Changement de cible !",
	SpecWarnKickNow				= "Casser Maintenant !",
	WarningTouchDebuff			= "Toucher sur >%s<",
	WarningPoweroftheTwins2		= "Puissance des jumelles - plus de soins sur >%s<",
	SpecWarnPoweroftheTwins		= "Puissance des jumelles!"
}

L:SetMiscLocalization{
	Fjola 		= "Fjola Plaie-lumineuse",
	Eydis		= "Eydis Plaie-sombre"
}

L:SetOptionLocalization{
	TimerSpecialSpell			= "Montre une alerte spéciale pour la prochaine Capacité spéciale",
	WarnSpecialSpellSoon		= "Montre une Pré-Alerte pour la prochaine Capacité spéciale",
	SpecWarnSpecial				= "Montre une alerte spéciale quand vous devez changer de couleur",
	SpecWarnEmpoweredDarkness	= "Montre une alerte spéciale pour les Ténèbres surpuissantes",
	SpecWarnEmpoweredLight		= "Montre une alerte spéciale pour la Lumière surpuissante",
	SpecWarnSwitchTarget		= "Montre une alerte spéciale quand l'autre boss est en train d'incanter",
	SpecWarnKickNow				= "Montre une alerte spéciale quand vous devez interrompre l'incantation",
	SpecialWarnOnDebuff			= "Montre une alerte spéciale quand vous avez un Toucher (pour changer de debuff)",
	SetIconOnDebuffTarget		= "Met des icônes sur les cibles des Toucher (héroique)",
	WarningTouchDebuff			= "Annoncer les cibles des débuff Toucher de Lumière/des Ténèbres",
	WarningPoweroftheTwins2		= "Annoncer la cible pour Puissance des jumelles",
	SpecWarnPoweroftheTwins		= "Montre une alerte spéciale quand vous êtes en train de tanker une Jumelle puissante"
}

-----------------
--  Anub'arak  --
-----------------
L = DBM:GetModLocalization("Anub'arak_Coliseum")

L:SetGeneralLocalization{
	name 					= "Anub'arak"
}

L:SetTimerLocalization{
	TimerEmerge				= "Sort du sol",
	TimerSubmerge			= "Rentre dans le sol",
	timerAdds				= "Nouveaux add dans"
}

L:SetWarningLocalization{
	WarnEmerge				= "Anub'arak Sort du sol",
	WarnEmergeSoon			= "Anub'arak Sort du sol dans 10 sec",
	WarnSubmerge			= "Anub'arak Rentre dans le sol",
	WarnSubmergeSoon		= "Anub'arak Rentre dans le sol dans 10 sec",
	warnAdds				= "Les add arrivent"
}

L:SetMiscLocalization{
	Emerge					= "surgit de la terre",
	Burrow					= "enfonce dans le sol",
	PcoldIconSet			= "Pcold Icon {rt%d} set on %s",
	PcoldIconRemoved		= "Pcold Icon removed from %s"
}

L:SetOptionLocalization{
	WarnEmerge				= "Montre une alerte quand le boss sort du sol",
	WarnEmergeSoon			= "Montre une alerte avant que le boss sorte du sol",
	WarnSubmerge			= "Montre une alerte quand le boss rentre dans le sol",
	WarnSubmergeSoon		= "Montre une alerte avant que le boss ne rentre dans le sol",
	warnAdds				= "Montre une alerte pour l'arrivée des add",
	timerAdds				= "Montre le timer avant l'arrivée des nouveaux add",
	TimerEmerge				= "Montre le timer pour la sortie du boss",
	TimerSubmerge			= "Montre le timer pour la rentrée du boss dans la terre",
	AnnouncePColdIcons		= "Marque les icones des cible du Froid pénétrant dans le chatt (Requiert les annonces activer et être le leader ou avoir une promot)"
}

----------------------
--  Lord Marrowgar  --
----------------------
L = DBM:GetModLocalization("LordMarrowgar")

L:SetGeneralLocalization{
	name = "Seigneur Gargamoelle"
}

L:SetTimerLocalization{
	AchievementBoned		= "Temps pour libérer"
}

L:SetWarningLocalization{
	WarnImpale				= ">%s< est empalé(e)"
}

L:SetOptionLocalization{
	WarnImpale				= "Annonce les cibles de $spell:69062",
	AchievementBoned		= "Montre le timer pour le haut-fait Dans l'os",
	SetIconOnImpale			= "Met des icônes sur les cibles de $spell:69062"
}

-------------------------
--  Lady Deathwhisper  --
-------------------------
L = DBM:GetModLocalization("Deathwhisper")

L:SetGeneralLocalization{
	name = "Dame Murmemort"
}

L:SetTimerLocalization{
	TimerAdds						= "Nouveaux Adds"
}

L:SetWarningLocalization{
	WarnReanimating					= "Les adds revivent",
	WarnTouchInsignificance			= "%s sur >%s< (%s)",
	WarnAddsSoon					= "Nouveaux adds bientôt"
}

L:SetOptionLocalization{
	WarnAddsSoon					= "Montre une pré-alerte avant que les adds arrivent",
	WarnReanimating					= "Montre une alerte quand les adds vont revenir a la vie",
	TimerAdds						= "Montre le timer pour les nouveaux adds"
}

L:SetMiscLocalization{
	YellReanimatedFanatic			= "Lève-toi, dans l'exultation de cette nouvelle pureté",
	Fanatic1						= "Membres du culte",
	Fanatic2						= "Fanatique déformé",
	Fanatic3						= "Fanatique réanimé"
}

-----------------------------
--  Deathbringer Saurfang  --
-----------------------------
L = DBM:GetModLocalization("Deathbringer")

L:SetGeneralLocalization{
	name = "Porte-Mort Saurcroc"
}

L:SetWarningLocalization{
	WarnFrenzySoon		= "Frénésie bientôt"
}

L:SetOptionLocalization{
	WarnFrenzySoon		= "Montre une pré-alerte pour la Frénésie (à ~33%)",
	RangeFrame			= "Montre la fenêtre de proximité",
	MarkCastIcon		= "Met des icones sur les cibles de $spell:72444 durant l'incantation (Experimental)",
	RunePowerFrame		= "Montre la barre de vie du boss + la barre de $spell:72371"
}

L:SetMiscLocalization{
	RunePower			= "Bêtes de sang",
	PullAlliance		= "Bon allez, on se bouge",
	PullHorde			= "surveillez bien vos arrières"
}

----------------------
--  Gunship Battle  --
----------------------
L = DBM:GetModLocalization("GunshipBattle")

L:SetGeneralLocalization{
	name = "La Bataille aérienne en Canonnière"
}

L:SetWarningLocalization{
	WarnBattleFury		= "%s (%d)",
	WarnAddsSoon		= "Nouveaux Add Bientôt"
}

L:SetOptionLocalization{
	WarnAddsSoon		= "Montre une alerte avant que les adds arrivent",
	TimerAdds			= "Montre le timer pour les nouveaux adds"
}

L:SetTimerLocalization{
	TimerAdds			= "Nouveaux Adds"
}

L:SetMiscLocalization{
	PullAlliance		= "Faites chauffer les moteurs",
	KillAlliance		= "Vous direz pas que j'vous avais pas prévenus",
	PullHorde			= "nous affrontons le plus haï de nos ennemis",
	KillHorde			= "L'Alliance baisse pavillon"
}

-----------------
--  Festergut  --
-----------------
L = DBM:GetModLocalization("Festergut")

L:SetGeneralLocalization{
	name = "Pulentraille"
}

L:SetWarningLocalization{
	InhaledBlight		= "Prochain Chancre >%d<",
	WarnGastricBloat	= "%s sur >%s< (%s)"
}

L:SetOptionLocalization{
	InhaledBlight		= "Montre une alerte pour le $spell:71912",
	RangeFrame			= "Montre la fenêtre de portée (8 Mètres)"
}

---------------
--  Rotface  --
---------------
L = DBM:GetModLocalization("Rotface")

L:SetGeneralLocalization{
	name = "Trognepus"
}

L:SetWarningLocalization{
	WarnOozeSpawn				= "Les Limons sont arrivées",
	WarnUnstableOoze			= "%s sur >%s< (%s)",
	SpecWarnLittleOoze			= "Les Limons vous attaque - COUREZ"
}

L:SetTimerLocalization{
	NextPoisonSlimePipes		= "Prochain distributeur de poison :"
}

L:SetOptionLocalization{
	NextPoisonSlimePipes		= "Montre le timer pour le prochain distributeur de poison",
	SpecWarnMutatedInfection 	= "Montre une alerte spéciale quand vous êtes affecté par Infection mutée",
	InfectionIcon				= "Met des icones sur la cible de l'Infection mutée",
	WarnOozeSpawn				= "Montre une alerte pour l'arrivée des Limons",
	SpecWarnLittleOoze			= "Montre une alerte spéciale quand vous êtes attaquer par des Limons"
}

L:SetMiscLocalization{
	YellSlimePipes1				= "réparé le distributeur de poison",	-- Professor Putricide
	YellSlimePipes2				= "Great news, everyone! The slime is flowing again!"	-- Professor Putricide
}

---------------------------
--  Professor Putricide  --
---------------------------
L = DBM:GetModLocalization("Putricide")

L:SetGeneralLocalization{
	name = "Professeur Putricide"
}

L:SetWarningLocalization{
	WarnPhase2Soon				= "Phase 2 bientôt",
	WarnPhase3Soon				= "Phase 3 bientôt",
	WarnMutatedPlague			= "%s sur >%s< (%s)",
	SpecWarnMalleableGoo		= "Gelée malléable sur Vous - BOUGEZ",
	SpecWarnMalleableGooNear	= "Gelée malléable à coter de Vous - Regardez",
	SpecWarnUnboundPlague		= "Perdez la Peste déliée",
	SpecWarnNextPlageSelf		= "Vous êtes le prochain pour la Peste déliée - Soyez pret"
}

L:SetOptionLocalization{
	WarnPhase2Soon				= "Montre une alerte avant la Phase 2 (at ~83%)",
	WarnPhase3Soon				= "Montre une alerte avant la 3 (at ~38%)",
	SpecWarnMalleableGoo		= "Montre une alerte spéciale si la Gelée malléable va sur vous (Marche seulement si vous êtes la première cible)",
	SpecWarnMalleableGooNear	= "Montre une alerte spéciale si la Gelée malléable va sur un joueur a coter de vous (Marche seulement si le joueur a coter de vous est la première cible)",
	MalleableGooIcon			= "Met une icone sur la première cible de $spell:72295",
	NextUnboundPlagueTargetIcon	= "Met une icone sur la prochaine cible de $spell:72856",
	SpecWarnUnboundPlague		= "Montre une alerte spéciale pour le transfert de $spell:72856",
	SpecWarnNextPlageSelf		= "Montre une alerte spéciale si vous êtes la cible suivante de $spell:72856"
}

L:SetMiscLocalization{
	YellMalleable	= "Gelée malléable sur MOI !"
}

----------------------------
--  Blood Prince Council  --
----------------------------
L = DBM:GetModLocalization("BPCouncil")

L:SetGeneralLocalization{
	name = "Princes de Sang"
}

L:SetWarningLocalization{
	WarnTargetSwitch		= "Changement de cible sur : %s",
	WarnTargetSwitchSoon	= "Changement de cible bientôt",
	SpecWarnVortex			= "Vortex de choc sur VOUS - BOUGEZ",
	SpecWarnVortexNear		= "Vortex de choc à coter de Vous - REGARDEZ"
}

L:SetTimerLocalization{
	TimerTargetSwitch		= "Possible changement de cible"
}

L:SetOptionLocalization{
	WarnTargetSwitch		= "Montre l'alerte pour le changement de cible",
	WarnTargetSwitchSoon	= "Montre une pré-alerte pour le changement de cible",
	TimerTargetSwitch		= "Montre un timer pour le changement de cible",
	SpecWarnVortex			= "Montre une alerte spéciale pour le $spell:72037 sur vous",
	SpecWarnVortexNear		= "Montre une alerte spéciale pour le $spell:72037 à coter de vous",
	ActivePrinceIcon		= "Place l'icône de raid principale sur le prince de sang actuellement surpuissant (nécessite d'être assistant ou mieux)."
}

L:SetMiscLocalization{
	Keleseth				= "Prince Keleseth",
	Taldaram				= "Prince Taldaram",
	Valanar					= "Prince Valanar",
	EmpoweredFlames			= "L'Embrasement surpuissant (%S+)!"
}

-----------------------------
--  Blood-Queen Lana'thel  --
-----------------------------
L = DBM:GetModLocalization("Lanathel")

L:SetGeneralLocalization{
	name = "Reine de sang Lana'thel"
}

L:SetMiscLocalization{
	SwarmingShadows			= "Shadows amass and swarm around (%S+)!"
}

-----------------------------
--  Valithria Dreamwalker  --
-----------------------------
L = DBM:GetModLocalization("Valithria")

L:SetGeneralLocalization{
	name = "Valithria Marcherêve"
}

L:SetWarningLocalization{
	WarnCorrosion	= "%s sur >%s< (%s)",
	WarnPortalOpen	= "Portails actifs !"
}

L:SetTimerLocalization{
	TimerPortalsOpen	= "Arrivée des portails"
}

L:SetOptionLocalization{
	SetIconOnBlazingSkeleton	= "Met une icone sur le Squelette flamboyant (Tête de mort)",
	WarnPortalOpen				= "Prévient via une alerte quand Valithria ouvre des portails.",
	TimerPortalsOpen			= "Montre une timer pour voir quand Valithria ouvre des portails."
}

L:SetMiscLocalization{
	YellPull		= "Ne gardez que les os et les tendons",
	YellKill		= "JE REVIS",
	YellPortals		= "Vous y trouverez votre salut",
	YellPhase2		= "My strength is returning. Press on, heroes!"
}

------------------
--  Sindragosa  --
------------------
L = DBM:GetModLocalization("Sindragosa")

L:SetGeneralLocalization{
	name = "Sindragosa"
}

L:SetTimerLocalization{
	TimerNextAirphase		= "Prochaine phase dans les airs",
	TimerNextGroundphase	= "Prochaine phase sur le sol",
	AchievementMystic		= "Time to clear Mystic stacks"
}

L:SetWarningLocalization{
	WarnAirphase			= "Phase dans les airs",
	WarnGroundphaseSoon		= "Sindragosa atterrie bientôt",
	WarnPhase2soon			= "Phase 2 bientôt",
	WarnInstability			= "Instabiliter >%d<",
	WarnChilledtotheBone	= "Transi jusqu'aux os >%d<",
	WarnMysticBuffet		= "Rafale mystique >%d<"
}

L:SetOptionLocalization{
	WarnAirphase				= "Annonce la phase dans les airs",
	WarnGroundphaseSoon			= "Montre une pré-alerte pour la phase au sol",
	TimerNextAirphase			= "Montre un timer pour la prochaine phase dans les airs",
	TimerNextGroundphase		= "Montre un timer pour la prochaine phase au sol",
	WarnPhase2soon				= "Montre une alerte pour la phase 2 (at ~38%)",
	WarnInstability				= "Montre une alerte pour les stacks de $spell:69766",
	WarnChilledtotheBone		= "Montre une alerte pour les stacks de $spell:70106",
	WarnMysticBuffet			= "Montre une alerte pour les stacks de $spell:70128",
	AnnounceFrostBeaconIcons	= "Annonce les icones pour les cibles de $spell:70126 dans le chat de raid (requires announce to be enabled and leader/promoted status)",
	ClearIconsOnAirphase		= "Retire toutes les icones avant la phase d'envol",
	RangeFrame					= "Montre la fenêtre de portée (10 normal, 20 heroic) (Montre uniquement les icones marquer sur les joueurs)"
}

L:SetMiscLocalization{
	YellAirphase	= "Votre incursion s'arrête ici",
	YellPhase2		= "Sentez maintenant le pouvoir infini de mon",
	YellAirphaseDem		= "Rikk zilthuras rikk zila Aman adare tiriosh ",--Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	YellPhase2Dem		= "Zar kiel xi romathIs zilthuras revos ruk toralar ",--Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	BeaconIconSet	= "Icone de Guide de givre {rt%d} mis sur %s"
}

---------------------
--  The Lich King  --
---------------------
L = DBM:GetModLocalization("LichKing")

L:SetGeneralLocalization{
	name = "Le Roi Liche"
}

L:SetWarningLocalization{
	WarnPhase2Soon				= "Transition de la Phase 2 bientôt",
	WarnPhase3Soon				= "Transition de la Phase 3 bientôt",
	SpecWarnDefileCast			= "Profanation sur VOUS - BOUGEZ",
	SpecWarnDefileNear			= "Profanation à coter de VOUS - Regardez Autour",
	SpecWarnTrapNear			= "Piège d'ombre à coter de VOUS - Regardez Autour",
	WarnNecroticPlagueJump		= "La Peste nécrotique a sauter sur >%s<",
	WarningValkyrSpawned 		= "Val'kyr(s) spawn (%d)",
	SpecWarnValkyrLow		= "Valkyr below 55%"
}

L:SetTimerLocalization{
	TimerRoleplay				= "Jeux de role",
	PhaseTransition				= "Phase de transition",
	TimerNecroticPlagueCleanse 	= "Peste nécrotique Dispell"
}

L:SetOptionLocalization{
	TimerRoleplay				= "Montre le timer pour l'event de role",
	WarnNecroticPlagueJump		= "Annonce sur qui saute la $spell:73912",
	TimerNecroticPlagueCleanse	= "Montre le timer pour dispell la Peste nécrotique avant le premier tic",
	PhaseTransition				= "Montre le timer pour la phase de transition",
	WarnPhase2Soon				= "Montre une alerte avant la transition de la phase 2 (at ~73%)",
	WarningValkyrSpawned		= "Montre une alerte pour l'arrivée des Val'kyr(s)",
	WarnPhase3Soon				= "Montre une alerte avant la transition de la phase 3 (at ~43%)",
	SpecWarnDefileCast			= "Montre une alerte spéciale pour la $spell:72762 sur vous",
	SpecWarnDefileNear			= "Montre une alerte spéciale pour la $spell:72762 à coter de vous",
	SpecWarnTrapNear			= "Montre une alerte spéciale pour le $spell:73539 à coter de vous",
	SpecWarnValkyrLow		= "Show special warning when Valkyr is below 55% HP"
}

L:SetMiscLocalization{
	LKPull			= "la fameuse justice de la Lumière",
	YellKill		= "No questions remain unanswered. No doubts linger. You ARE Azeroth's greatest champions. You overcame every challenge I laid before you. My mightiest servants have fallen before your relentless onslaught... your unbridled fury...",
	LKRoleplay		= "Is it truly righteousness that drives you? I wonder...",
	PlagueWhisper	= "Vous êtes infecter par"
}

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("ICCTrash")

L:SetGeneralLocalization{
	name = "Icecrown Trash"
}

L:SetWarningLocalization{
	SpecWarnTrapL		= "Trap Activated! - Deathbound Ward released",
	SpecWarnTrapP		= "Trap Activated! - Vengeful Fleshreapers incoming",
	SpecWarnGosaEvent	= "Sindragosa gauntlet started!"
}

L:SetOptionLocalization{
	SpecWarnTrapL		= "Show special warning for Deathbound Ward trap activation",
	SpecWarnTrapP		= "Show special warning for engeful Fleshreapers trap activation",
	SpecWarnGosaEvent	= "Show special warning for Sindragosa gauntlet event"
}

L:SetMiscLocalization{
	WarderTrap1			= "Who... goes there...?",
	WarderTrap2			= "I... awaken!",
	WarderTrap3			= "The master's sanctum has been disturbed!",
	FleshreaperTrap1	= "Quickly! We'll ambush them from behind!",
	FleshreaperTrap2	= "You... cannot escape us!",
	FleshreaperTrap3	= "The living... here?!",
	SindragosaEvent		= "You must not approach the Frost Queen. Quickly, stop them!"
}

------------------------
--  The Ruby Sanctum  --
------------------------
--  Baltharus the Warborn  --
-----------------------------
L = DBM:GetModLocalization("Baltharus")

L:SetGeneralLocalization({
	name = "Baltharus the Warborn"
})

L:SetWarningLocalization({
	WarningSplitSoon	= "Split soon"
})

L:SetOptionLocalization({
	WarningSplitSoon	= "Show pre-warning for Split"
})

-------------------------
--  Saviana Ragefire  --
-------------------------
L = DBM:GetModLocalization("Saviana")

L:SetGeneralLocalization({
	name = "Saviana Ragefire"
})

--------------------------
--  General Zarithrian  --
--------------------------
L = DBM:GetModLocalization("Zarithrian")

L:SetGeneralLocalization({
	name = "General Zarithrian"
})

L:SetWarningLocalization({
	WarnAdds	= "New adds",
	warnCleaveArmor	= "%s on >%s< (%s)"		-- Cleave Armor on >args.destName< (args.amount)
})

L:SetTimerLocalization({
	TimerAdds	= "New adds"
})

L:SetOptionLocalization({
	WarnAdds		= "Announce new adds",
	TimerAdds		= "Show timer for new adds"
})

L:SetMiscLocalization({
	SummonMinions	= "Turn them to ash, minions!"--needs translation
})

-------------------------------------
--  Halion the Twilight Destroyer  --
-------------------------------------
L = DBM:GetModLocalization("Halion")

L:SetGeneralLocalization({
	name = "Halion the Twilight Destroyer"
})

L:SetWarningLocalization({
	TwilightCutterCast	= "Casting Twilight Cutter: 5 sec"
})

L:SetOptionLocalization({
	TwilightCutterCast		= "Show warning when $spell:77844 is being cast",
	AnnounceAlternatePhase	= "Show warnings/timers for phase you aren't in as well"
})

L:SetMiscLocalization({
	MeteorCast				= "Les cieux s'embrasent !",
	Phase2					= "Vous ne trouverez que souffrance au royaume du crépuscule ! Entrez si vous l'osez !",
	Phase3					= "Je suis la lumière et l'ombre ! Tremblez, mortels, devant le héraut d'Aile-de-mort !",--needs Verification
	twilightcutter			= "Les sphères volantes rayonnent d'énergie noire !",
	Kill					= "Relish this victory, mortals, for it will be your last. This world will burn with the master's return!"--needs translation
})
