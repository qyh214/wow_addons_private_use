if GetLocale() ~= "frFR" then return end
local L

---------------
-- Kurinnaxx --
---------------
L = DBM:GetModLocalization("Kurinnaxx")

L:SetGeneralLocalization{
	name 		= "Kurinnaxx"
}
------------
-- Rajaxx --
------------
L = DBM:GetModLocalization("Rajaxx")

L:SetGeneralLocalization{
	name 		= "Général Rajaxx"
}
L:SetWarningLocalization{
	WarnWave	= "Vague %s"
}
L:SetOptionLocalization{
	WarnWave	= "Afficher l'annonce pour la prochaine vague entrante"
}
L:SetMiscLocalization{
	Wave12		= "Ils arrivent. Essayez de ne pas vous faire tuer, bleusaille.",
	Wave12Alt	= "Alors, Rajaxx, tu te souviens que j’avais dit que je te tuerais le dernier ?",
	Wave3		= "L’heure de notre vengeance sonne enfin ! Que les ténèbres règnent dans le cœur de nos ennemis !",
	Wave4		= "C’en est fini d’attendre derrière des portes fermées et des murs de pierre ! Nous ne serons pas privés de notre vengeance ! Les dragons eux-mêmes trembleront devant notre courroux !",
	Wave5		= "La peur est pour l’ennemi ! La peur et la mort !",
	Wave6		= "Forteramure pleurnichera pour avoir la vie sauve, comme l’a fait son morveux de fils ! En ce jour, mille ans d’injustice s’achèvent !",
	Wave7		= "Fandral ! Ton heure est venue ! Va te cacher dans le Rêve d’Emeraude, et prie pour que nous ne te trouvions jamais !",
	Wave8		= "Imbécile imprudent ! Je vais te tuer moi-même !"
}

----------
-- Moam --
----------
L = DBM:GetModLocalization("Moam")

L:SetGeneralLocalization{
	name 		= "Moam"
}

----------
-- Buru --
----------
L = DBM:GetModLocalization("Buru")

L:SetGeneralLocalization{
	name 		= "Buru Grandgosier"
}
L:SetWarningLocalization{
	WarnPursue		= "Poursuivre >%s<",
	SpecWarnPursue	= "Te poursuivre",
	WarnDismember	= "%s sur >%s< (%s)"
}
L:SetOptionLocalization{
	WarnPursue		= "Annoncer des cibles de poursuite",
	SpecWarnPursue	= "Afficher un avertissement spécial lorsque vous êtes poursuivi",
	WarnDismember	= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(96)
}
L:SetMiscLocalization{
	PursueEmote 	= "%s pose ses yeux sur"
}

-------------
-- Ayamiss --
-------------
L = DBM:GetModLocalization("Ayamiss")

L:SetGeneralLocalization{
	name 		= "Ayamiss le Chasseur"
}

--------------
-- Ossirian --
--------------
L = DBM:GetModLocalization("Ossirian")

L:SetGeneralLocalization{
	name 		= "Ossirian l'Intouché"
}
L:SetWarningLocalization{
	WarnVulnerable	= "%s"
}
L:SetTimerLocalization{
	TimerVulnerable	= "%s"
}
L:SetOptionLocalization{
	WarnVulnerable	= "Annoncer les sensibilités",
	TimerVulnerable	= "Afficher le timer pour les sensibilités"
}

----------------
-- AQ20 Trash --
----------------
L = DBM:GetModLocalization("AQ20Trash")

L:SetGeneralLocalization{
	name = "AQ20: Ennemis communs"
}

------------
-- Skeram --
------------
L = DBM:GetModLocalization("Skeram")

L:SetGeneralLocalization{
	name = "Le Prophète Skeram"
}

----------------
-- Three Bugs --
----------------
L = DBM:GetModLocalization("ThreeBugs")

L:SetGeneralLocalization{
	name = "Trio d'insectes"
}
L:SetMiscLocalization{
	Yauj = "Princesse Yauj",
	Vem = "Vem",
	Kri = "Seigneur Kri"
}

-------------
-- Sartura --
-------------
L = DBM:GetModLocalization("Sartura")

L:SetGeneralLocalization{
	name = "Garde de guerre Sartura"
}

--------------
-- Fankriss --
--------------
L = DBM:GetModLocalization("Fankriss")

L:SetGeneralLocalization{
	name = "Fankriss l'Inflexible"
}

--------------
-- Viscidus --
--------------
L = DBM:GetModLocalization("Viscidus")

L:SetGeneralLocalization{
	name = "Viscidus"
}
L:SetWarningLocalization{
	WarnFreeze	= "Gel : %d/3",
	WarnShatter	= "Briser : %d/3"
}
L:SetOptionLocalization{
	WarnFreeze	= "Annoncer l'état de Gel",
	WarnShatter	= "Annoncer l'état de Briser"
}
L:SetMiscLocalization{
	Slow	= "commence à ralentir !",
	Freezing= "est gelé !",
	Frozen	= "est congelé !",
	Phase4 	= "commence à se briser !",
	Phase5 	= "semble prêt à se briser !",
	Phase6 	= "explose !",

	HitsRemain	= "Touche restante",
	Frost		= "Givre",
	Physical	= "Physique"
}
-------------
-- Huhuran --
-------------
L = DBM:GetModLocalization("Huhuran")

L:SetGeneralLocalization{
	name = "Princesse Huhuran"
}
---------------
-- Twin Emps --
---------------
L = DBM:GetModLocalization("TwinEmpsAQ")

L:SetGeneralLocalization{
	name = "Empereurs Jumeaux"
}
L:SetMiscLocalization{
	Veklor = "Empereur Vek'lor",
	Veknil = "Empereur Vek'nilash"
}

------------
-- C'Thun --
------------
L = DBM:GetModLocalization("CThun")

L:SetGeneralLocalization{
	name = "C'Thun"
}
L:SetWarningLocalization{
	WarnEyeTentacle			= "Tentacule oculaire",
	WarnClawTentacle2		= "Tentacule griffu",
	WarnGiantEyeTentacle	= "Tentacule oculaire géant",
	WarnGiantClawTentacle	= "Tentacule griffu géant",
	SpecWarnWeakened		= "C'Thun est affaibli !"
}
L:SetTimerLocalization{
	TimerEyeTentacle		= "Prochain Tentacule oculaire",
	TimerClawTentacle		= "Prochain Tentacule griffu",
	TimerGiantEyeTentacle	= "Prochain Tentacule oculaire géant",
	TimerGiantClawTentacle	= "Prochain Tentacule griffu géant",
	TimerWeakened			= "Faiblesse terminé"
}
L:SetOptionLocalization{
	WarnEyeTentacle			= "Afficher l'avertissement pour Tentacule oculaire",
	WarnClawTentacle2		= "Afficher l'avertissement pour Tentacule griffu",
	WarnGiantEyeTentacle	= "Afficher l'avertissement pour Tentacule oculaire géant",
	WarnGiantClawTentacle	= "Afficher l'avertissement pour Tentacule griffu géant",
	SpecWarnWeakened		= "Afficher un avertissement spécial lorsque le boss s'affaiblit",
	TimerEyeTentacle		= "Afficher le timer pour le prochain Tentacule oculaire",
	TimerClawTentacle		= "Afficher le timer pour le prochain Tentacule griffu",
	TimerGiantEyeTentacle	= "Afficher le timer pour le prochain Tentacule oculaire géant",
	TimerGiantClawTentacle	= "Afficher le timer pour le prochain Tentacule griffu géant",
	TimerWeakened			= "Afficher le timer pour la durée d'affaiblissement du boss",
	RangeFrame				= "Afficher le cadre de portée (10 m)"
}
L:SetMiscLocalization{
	Stomach		= "Estomac",
	Eye			= "Oeil de C'Thun",
	FleshTent	= "Tentacule de chair",
	Weakened 	= "est affaibli !",
	NotValid	= "AQ40 partiellement effacé. %s bosses optionnels restent."
}
----------------
-- Ouro --
----------------
L = DBM:GetModLocalization("Ouro")

L:SetGeneralLocalization{
	name = "Ouro"
}
L:SetWarningLocalization{
	WarnSubmerge		= "Submerger",
	WarnEmerge			= "Émerger"
}
L:SetTimerLocalization{
	TimerSubmerge		= "Submerger",
	TimerEmerge			= "Émerger"
}
L:SetOptionLocalization{
	WarnSubmerge		= "Afficher l'avertissement pour submerger",
	TimerSubmerge		= "Afficher le timer pour submerger",
	WarnEmerge			= "Afficher l'avertissement pour émerger",
	TimerEmerge			= "Afficher le timer pour émerger"
}

----------------
-- AQ40 Trash --
----------------
L = DBM:GetModLocalization("AQ40Trash")

L:SetGeneralLocalization{
	name = "AQ40: Ennemis communs"
}

-------------------
--  Venoxis  --
-------------------
L = DBM:GetModLocalization("Venoxis")

L:SetGeneralLocalization{
	name = "Grand prêtre Venoxis"
}

-------------------
--  Jeklik  --
-------------------
L = DBM:GetModLocalization("Jeklik")

L:SetGeneralLocalization{
	name = "Grande prêtresse Jeklik"
}

-------------------
--  Marli  --
-------------------
L = DBM:GetModLocalization("Marli")

L:SetGeneralLocalization{
	name = "Grande prêtresse Mar'li"
}

-------------------
--  Thekal  --
-------------------
L = DBM:GetModLocalization("Thekal")

L:SetGeneralLocalization{
	name = "Grand prêtre Thekal"
}

L:SetWarningLocalization({
	WarnSimulKill	= "Premier serviteur mort - Résurrection en ~15 secondes"
})

L:SetTimerLocalization({
	TimerSimulKill	= "Résurrection"
})

L:SetOptionLocalization({
	WarnSimulKill	= "Annoncez le premier serviteur mort",
	TimerSimulKill	= "Montre le timer pour la résurrection des prêtres"
})

L:SetMiscLocalization({
	PriestDied	= "%s meurt.",
	YellPhase2	= "Shirvallah, que ta RAGE m’envahisse !",
	YellKill	= "Hakkar ne me domine plus ! Je connais enfin la paix !",
	Thekal		= "Grand prêtre Thekal",
	Zath		= "Zélote Zath",
	LorKhan		= "Zélote Lor'Khan"
})

-------------------
--  Arlokk  --
-------------------
L = DBM:GetModLocalization("Arlokk")

L:SetGeneralLocalization{
	name = "Grande prêtresse Arlokk"
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
	name = "Seigneur sanglant Mandokir"
}
L:SetMiscLocalization{
	Bloodlord 	= "Seigneur sanglant Mandokir",
	Ohgan		= "Ohgan",
	GazeYell	= "je vous ai à l'œil"
}

-------------------
--  Edge of Madness  --
-------------------
L = DBM:GetModLocalization("EdgeOfMadness")

L:SetGeneralLocalization{
	name = "Frontière de la folie"
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
	name = "Jin'do le Maléficieur"
}

-----------------
--  Razorgore  --
-----------------
L = DBM:GetModLocalization("Razorgore")

L:SetGeneralLocalization{
	name = "Tranchetripe l'Indompté"
}
L:SetTimerLocalization{
	TimerAddsSpawn	= "Premiers serviteurs"
}
L:SetOptionLocalization{
	TimerAddsSpawn	= "Afficher le timer pour les premiers serviteurs"
}
L:SetMiscLocalization{
	Phase2Emote	= "s'enfuit car le contrôle de l'orbe s'affaiblit.",
	YellEgg1 = "Vous allez payer pour m'avoir forcé à faire ça !",
	YellEgg2 = "Imbéciles ! Vous n'avez pas idée de la valeur de ces œufs !",
	YellEgg3 = "Non, pas un autre ! J'aurai vos têtes pour venger cette atrocité !",
	YellPull = "La chambre des œufs est envahie ! Sonnez l'alarme ! Protégez les œufs à tout prix !"
}
-------------------
--  Vaelastrasz  --
-------------------
L = DBM:GetModLocalization("Vaelastrasz")

L:SetGeneralLocalization{
	name				= "Vaelastrasz le Corrompu"
}

L:SetMiscLocalization{
	Event				= "Trop tard, mes amis ! La corruption de Nefarius s'empare de moi… Je ne peux plus… me contrôler."
}
-----------------
--  Broodlord  --
-----------------
L = DBM:GetModLocalization("Broodlord")

L:SetGeneralLocalization{
	name	= "Seigneur des couvées Lashlayer"
}

L:SetMiscLocalization{
	Pull	= "Aucun membre de votre espèce ne devrait être ici ! Vous vous êtes condamnés vous-mêmes !"
}

---------------
--  Firemaw  --
---------------
L = DBM:GetModLocalization("Firemaw")

L:SetGeneralLocalization{
	name = "Gueule-de-feu"
}

---------------
--  Ebonroc  --
---------------
L = DBM:GetModLocalization("Ebonroc")

L:SetGeneralLocalization{
	name = "Rochébène"
}

----------------
--  Flamegor  --
----------------
L = DBM:GetModLocalization("Flamegor")

L:SetGeneralLocalization{
	name = "Flamegor"
}


-----------------------
--  Vulnerabilities  --
-----------------------
-- Chromaggus, Death Talon Overseer and Death Talon Wyrmguard
L = DBM:GetModLocalization("TalonGuards")

L:SetGeneralLocalization{
	name = "Gardes Griffemort"
}
L:SetWarningLocalization{
	WarnVulnerable		= "Vulnérabilité : %s"
}
L:SetOptionLocalization{
	WarnVulnerable		= "Afficher un avertissement pour les vulnérabilités des sorts"
}
L:SetMiscLocalization{
	Fire		= "Feu",
	Nature		= "Nature",
	Frost		= "Givre",
	Shadow		= "Ombre",
	Arcane		= "Arcanes",
	Holy		= "Sacré"
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
	WarnVulnerable	= "Vulnérabilité : %s"
}
L:SetTimerLocalization{
	TimerBreathCD	= "%s recharge",
	TimerBreath		= "%s lancement",
	TimerVulnCD		= "Recharge de Vulnérabilité"
}
L:SetOptionLocalization{
	WarnBreath		= "Afficher un avertissement lorsque Chromaggus lance un de ses souffles",
	WarnVulnerable	= "Afficher un avertissement pour les vulnérabilités des sorts",
	TimerBreathCD	= "Afficher le temps de recharge de souffle",
	TimerBreath		= "Afficher le lancement du souffle",
	TimerVulnCD		= "Afficher le temps de recharge de vulnérabilité"
}
L:SetMiscLocalization{
	Breath1		= "Premier souffle",
	Breath2		= "Deuxième souffle",
	VulnEmote	= "%s grimace lorsque sa peau se met à briller.",
	Fire		= "Feu",
	Nature		= "Nature",
	Frost		= "Givre",
	Shadow		= "Ombre",
	Arcane		= "Arcanes",
	Holy		= "Sacré"
}

----------------
--  Nefarian  --
----------------
L = DBM:GetModLocalization("Nefarian-Classic")

L:SetGeneralLocalization{
	name = "Nefarian"
}
L:SetWarningLocalization{
	WarnAddsLeft		= "%d restants",
	WarnClassCall		= "L'appel de %s",
	specwarnClassCall	= "Votre appel de classe !"
}
L:SetTimerLocalization{
	TimerClassCall		= "L'appel de %s termine"
}
L:SetOptionLocalization{
	TimerClassCall		= "Afficher le timer pour la durée de l'appel en classe",
	WarnAddsLeft		= "Annoncer les éliminations restantes jusqu'au déclenchement de la phase 2",
	WarnClassCall		= "Annoncer les appels de classe",
	specwarnClassCall	= "Afficher un avertissement spécial lorsque vous êtes affecté par un appel de classe"
}
L:SetMiscLocalization{
    YellP1			= "Que les jeux commencent !",
    YellP2			= "Beau travail ! Le courage des mortels commence à faiblir ! Voyons maintenant s'ils peuvent lutter contre le véritable seigneur du pic Blackrock !",
    YellP3			= "C'est impossible ! Relevez-vous, serviteurs ! Servez une nouvelle fois votre maître !",
    YellShaman		= "Chamans, montrez-moi ce que vos totems peuvent faire !",
    YellPaladin		= "Les paladins... J'en entendu dire que vous aviez de nombreuses vies... Montrez-moi.",
    YellDruid		= "Les druides et leur stupides changements de forme. Voyons ce qu'ils donnent en vrai...",
    YellPriest		= "Prêtres ! Si vous continuez à soigner comme ça, nous pourrions rendre le processus plus intéressant !",
    YellWarrior		= "Guerriers, je sais que vous pouvez frapper plus fort que ça ! Voyons ça !",
    YellRogue		= "Voleurs, arrêtez de vous cacher et affrontez-moi !",
    YellWarlock		= "Démonistes, vous ne devriez pas jouer avec une magie qui vous dépasse. Vous voyez ce qui arrive ?",
    YellHunter		= "Ah, les chasseurs et les stupides sarbacanes !",
    YellMage		= "Les mages aussi ? Vous devriez être plus prudents lorsque vous jouez avec la magie."
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
	name = "Baron Geddon"
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
	name = "Messager de Sulfuron"
}

----------------
--  Golemagg  --
----------------
L = DBM:GetModLocalization("Golemagg")

L:SetGeneralLocalization{
	name = "Golemagg l'Incinérateur"
}

-----------------
--  Majordomo  --
-----------------
L = DBM:GetModLocalization("Majordomo")

L:SetGeneralLocalization{
	name = "Chambellan Executus"
}
L:SetTimerLocalization{
	timerShieldCD		= "Bouclier suivant"
}
L:SetOptionLocalization{
	timerShieldCD		= "Afficher le timer pour le prochain bouclier de dégâts / Renvoi de la magie"
}

----------------
--  Ragnaros  --
----------------
L = DBM:GetModLocalization("Ragnaros-Classic")

L:SetGeneralLocalization{
	name = "Ragnaros"
}
L:SetWarningLocalization{
	WarnSubmerge		= "Submergé",
	WarnEmerge			= "Émergé"
}
L:SetTimerLocalization{
	TimerSubmerge		= "Submergé",
	TimerEmerge			= "Émergé",
}
L:SetOptionLocalization{
	WarnSubmerge		= "Afficher un avertissement pour submergé",
	TimerSubmerge		= "Afficher le timer pour submergé",
	WarnEmerge			= "Afficher un avertissement pour émergé",
	TimerEmerge			= "Afficher le timer pour émergé",
}
L:SetMiscLocalization{
	Submerge	= "VENEZ, MES SERVITEURS ! DÉFENDEZ VOTRE MAÎTRE !",
	Pull		= "Impudents imbéciles ! Vous vous êtes précipités vers votre propre mort ! Voyez, à présent, le Maître remue !"
}

-----------------
--  MC: Trash  --
-----------------
L = DBM:GetModLocalization("MCTrash")

L:SetGeneralLocalization{
	name = "CM: Ennemis communs"
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
	Breath = "%s prend une grande inspiration...",
	YellPull = "Quelle chance ! D'habitude, je dois quitter mon repaire pour me nourrir.",
	YellP2 = "Cet exercice dénué de sens m'ennuie. Je vais vous incinérer d'un seul coup !",
	YellP3 = "Il semble que vous ayez besoin d'une autre leçon, mortels !"
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
	ArachnophobiaTimer	= "Arachnophobia",
	Pull1				= "Oui, courez ! Faites circulez le sang !",
	Pull2				= "Rien qu'une petite bouchée…"
})

----------------------------
--  Grand Widow Faerlina  --
----------------------------
L = DBM:GetModLocalization("Faerlina")

L:SetGeneralLocalization({
	name = "Grande veuve Faerlina"
})

L:SetWarningLocalization({
	WarningEmbraceExpire	= "Fin du baisé de la veuve dans 5 sec",
	WarningEmbraceExpired	= "Baisé de la veuve terminé"
})

L:SetOptionLocalization({
	WarningEmbraceExpire	= "Activer l'avertissement de fin du baisé de la veuve",
	WarningEmbraceExpired	= "Afficher un avertissement quand le baisé de la veuve va se terminer"
})

L:SetMiscLocalization({
	Pull					= "À genoux, vermisseau !"--Not actually pull trigger, but often said on pull
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
	TimerTeleportBack		= "Activer le timer pour le retour de Noth"
})

L:SetMiscLocalization({
	Pull				= "Mourez, intrus !",
	AddsYell			= "Levez-vous, soldats ! Levez-vous et combattez une fois encore !",
	Adds				= "invoque des guerriers squelettes !",
	AddsTwo				= "lève encore d'autres squelettes !"
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

L:SetMiscLocalization({
	Pull				= "Vous êtes à moi, maintenant."
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
	name = "Le Recousu"
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	yell1 		     	= "R'cousu veut jouer !",
	yell2 		     	= "R'cousu avatar de guerre pour Kel'Thuzad !"
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
	AirowsEnabled			= "Afficher les flèches (stratégie normale : \"2 camps\")",
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
	name = "Instructeur Razuvious"
})

L:SetMiscLocalization({
	Yell1 					= "Pas de quartier !",
	Yell2 					= "Les cours sont terminés ! Montrez-moi ce que vous avez appris !",
	Yell3 					= "Faites ce que vous ai appris !",
	Yell4 					= "Frappe-le à la jambe… Ça te pose un problème ?"
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
	name = "Gothik le Moissonneur"
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
	name = "Les Quatre Cavaliers"
})

L:SetOptionLocalization({
	TimerMark					= "Afficher le timer des Marques",
	WarningMarkSoon				= "Activer le pré-avertissement des Marques",
	SpecialWarningMarkOnPlayer	= "Avertissement spécial quand vous avez plus de 4 marques sur vous"
})

L:SetTimerLocalization({
	TimerMark 					= "Marque %d"
})

L:SetWarningLocalization({
	WarningMarkSoon				= "Marque %d dans 3 sec",
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
	TimerIceBlast		   	= "Afficher le timer du Souffle de givre",
	WarningDeepBreath		= "Activer l'avertissement spécial pour le Souffle de givre",
	WarningIceblock			= "Crie dans un glaçon"
})

L:SetMiscLocalization({
	EmoteBreath			    = "prend une grande inspiration",
	WarningYellIceblock	= "Je suis un bloc de glace !"
})

L:SetWarningLocalization({
	WarningAirPhaseSoon	= "Envol dans 10 sec",
	WarningAirPhaseNow	= "Dans les airs",
	WarningLanded		    = "Atterrissage de Sapphiron",
	WarningDeepBreath	  = "Souffle de givre !"
})

L:SetTimerLocalization({
	TimerAir		   		  = "Envol",
	TimerLanding			  = "Atterrissage dans",
	TimerIceBlast			  = "Souffle de givre"
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
	Yell 					= "Serviteurs, valets et soldats des ténèbres glaciales ! Répondez à l'appel de Kel'Thuzad !"
})

L:SetWarningLocalization({
	specwarnP2Soon  		= "Kel'Thuzad sera actif dans 10 secondes"
})

L:SetTimerLocalization({
	TimerPhase2				= "Phase 2",
})
