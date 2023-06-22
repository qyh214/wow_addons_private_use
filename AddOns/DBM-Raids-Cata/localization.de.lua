if GetLocale() ~= "deDE" then return end
local L

----------------
--  Argaloth  --
----------------
L= DBM:GetModLocalization(139)

-----------------
--  Occu'thar  --
-----------------
L= DBM:GetModLocalization(140)

----------------------------------
--  Alizabal, Mistress of Hate  --
----------------------------------
L= DBM:GetModLocalization(339)

L:SetTimerLocalization({
	TimerFirstSpecial		= "Erste Spezialfähigkeit"
})

L:SetOptionLocalization({
	TimerFirstSpecial		= "Zeige Zeit bis erste Spezialfähigkeit nach $spell:105738 (erste Spezialfähigkeit ist zufällig, entweder $spell:105067 oder $spell:104936)"
})

-------------------------------
--  Dark Iron Golem Council  --
-------------------------------
L = DBM:GetModLocalization(169)

L:SetWarningLocalization({
	SpecWarnActivated			= "Wechsel Ziel zu %s!",
	specWarnGenerator			= "Energiegenerator - Zieh %s raus!"
})

L:SetTimerLocalization({
	timerShadowConductorCast	= "Schattenleiter",
	timerArcaneLockout			= "Annihilator Sperre",
	timerArcaneBlowbackCast		= "Arkaner Kurzschluss",
	timerNefAblity				= "Fähigkeitsbuff CD"
})

L:SetOptionLocalization({
	timerShadowConductorCast	= "Zeige Zeit bis $spell:92048 gewirkt wird",
	timerArcaneLockout			= "Zeige Zeit, in der $spell:79710 nicht gewirkt werden kann",
	timerArcaneBlowbackCast		= "Zeige Zeit bis $spell:91879 gewirkt wird",
	timerNefAblity				= "Zeige Abklingzeit für heroische Fähigkeitsverbesserungen",
	SpecWarnActivated			= "Spezialwarnung, wenn ein neuer Boss aktiviert wird",
	specWarnGenerator			= "Spezialwarnung, wenn ein Boss von $spell:79629 profitiert",
	SetIconOnActivated			= "Setze ein Zeichen auf den zuletzt aktivierten Boss"
})

L:SetMiscLocalization({
	YellTargetLock				= "Umschließende Schatten! Weg von mir!"
})

--------------
--  Magmaw  --
--------------
L = DBM:GetModLocalization(170)

L:SetWarningLocalization({
	SpecWarnInferno	= "Loderndes Knochenkonstrukt bald (~4s)"
})

L:SetOptionLocalization({
	SpecWarnInferno	= "Spezialvorwarnung für $spell:92154 (~4s)",
	RangeFrame		= "Zeige Abstandsfenster in Phase 2 (5m)"
})

L:SetMiscLocalization({
	Slump			= "%s schlittert nach vorne und entblößt seine Zangen!",
	HeadExposed		= "%s spießt sich selbst auf, was seinen Kopf freilegt!",
	YellPhase2		= "Unfassbar! Ihr könntet tatsächlich meinen Lavawurm besiegen! Vielleicht kann ich helfen... das Zünglein an der Waage zu sein."
})

-----------------
--  Atramedes  --
-----------------
L = DBM:GetModLocalization(171)

L:SetOptionLocalization({
	InfoFrame				= "Zeige Infofenster für $journal:3072"
})

L:SetMiscLocalization({
	NefAdd					= "Atramedes, die Helden sind direkt DA DRÜBEN!",
	Airphase				= "Ja, lauft! Jeder Schritt lässt Euer Herz stärker klopfen. Laut und heftig... ohrenbetäubend. Es gibt kein Entkommen!"
})

-----------------
--  Chimaeron  --
-----------------
L = DBM:GetModLocalization(172)

L:SetOptionLocalization({
	RangeFrame		= "Zeige Abstandsfenster (6m)",
	InfoFrame		= "Zeige Infofenster für Gesundheit (weniger als 10k Lebenspunkte)"
})

L:SetMiscLocalization({
	HealthInfo	= "Gesundheitsinfo"
})

----------------
--  Maloriak  --
----------------
L = DBM:GetModLocalization(173)

L:SetWarningLocalization({
	WarnPhase			= "%s Phase"
})

L:SetTimerLocalization({
	TimerPhase			= "Nächste Phase"
})

L:SetOptionLocalization({
	WarnPhase			= "Verkünde welche Phase als Nächstes kommt",
	TimerPhase			= "Zeige Zeit bis nächste Phase",
	RangeFrame			= "Zeige Abstandsfenster (6m) während der blauen Phase",
	SetTextures			= "Automatische Deaktivierung der Grafikeinstellung 'Projizierte Texturen' in der dunklen Phase (wird nach Verlassen der Phase autom. wieder aktiviert)"
})

L:SetMiscLocalization({
	YellRed				= "rote|r Phiole in den Kessel!",
	YellBlue			= "blaue|r Phiole in den Kessel!",
	YellGreen			= "grüne|r Phiole in den Kessel!",
	YellDark			= "dunkle|r Magie hinzu!" --needs to be verified (video-captured translation)
})

----------------
--  Nefarian  --
----------------
L = DBM:GetModLocalization(174)

L:SetWarningLocalization({
	OnyTailSwipe			= "Schwanzpeitscher (Onyxia)",
	NefTailSwipe			= "Schwanzpeitscher (Nefarian)",
	OnyBreath				= "Atem (Onyxia)",
	NefBreath				= "Atem (Nefarian)",
	specWarnShadowblazeSoon	= "%s",
	warnShadowblazeSoon		= "%s"
})

L:SetTimerLocalization({
	timerNefLanding			= "Nefarian landet",
	OnySwipeTimer			= "Schwanzpeitscher CD (Ony)",
	NefSwipeTimer			= "Schwanzpeitscher CD (Nef)",
	OnyBreathTimer			= "Atem CD (Ony)",
	NefBreathTimer			= "Atem CD (Nef)"
})

L:SetOptionLocalization({
	OnyTailSwipe			= "Zeige Warnung für Onyxias $spell:77827",
	NefTailSwipe			= "Zeige Warnung für Nefarians $spell:77827",
	OnyBreath				= "Zeige Warnung für Onyxias $spell:77826",
	NefBreath				= "Zeige Warnung für Nefarians $spell:77826",
	specWarnCinderMove		= "Spezialwarnung zum Weglaufen, wenn du von $spell:79339 betroffen bist (5s vor Explosion)",
	warnShadowblazeSoon		= "Zeige Vorwarnungscountdown für $spell:81031 (5s zuvor)<br/>(aus Genauigkeitsgründen erst nach Synchronisierung mit erstem Ausruf)",
	specWarnShadowblazeSoon	= "Spezialvorwarnung für $spell:81031 (aus Genauigkeitsgründen<br/>zu Beginn 5s Vorwarnung, 1s Vorwarnung nach erstem Ausruf)",
	timerNefLanding			= "Zeige Zeit bis Nefarian landet",
	OnySwipeTimer			= "Zeige Abklingzeit für Onyxias $spell:77827",
	NefSwipeTimer			= "Zeige Abklingzeit für Nefarians $spell:77827",
	OnyBreathTimer			= "Zeige Abklingzeit für Onyxias $spell:77826",
	NefBreathTimer			= "Zeige Abklingzeit für Nefarians $spell:77826",
	InfoFrame				= "Zeige Infofenster für $journal:3284",
	SetWater				= "Automatische Deaktivierung der Kameraeinstellung 'Wasserkollision'<br/>bei Kampfbeginn (wird nach Kampfende automatisch wieder aktiviert)",
	RangeFrame				= "Zeige Abstandsfenster (10m) für $spell:79339 (zeigt jeden, falls du den Debuff hast; sonst nur betroffene Spieler)"
})

L:SetMiscLocalization({
	NefAoe					= "Elektrizität lässt die Luft knistern!",
	YellPhase2				= "Verfluchte Sterbliche! Ein solcher Umgang mit dem Eigentum anderer verlangt nach Gewalt!",
	YellPhase3				= "Ich habe versucht, ein guter Gastgeber zu sein, aber ihr wollt einfach nicht sterben! Genug der Spielchen! Ich werde euch einfach... ALLE TÖTEN!",
	YellShadowBlaze			= "Fleisch wird zu Asche!",
	ShadowBlazeExact		= "Schattensengen in %ds",
	ShadowBlazeEstimate		= "Schattensengen bald  (~5s)"
})

-------------------------------
--  Blackwing Descent Trash  --
-------------------------------
L = DBM:GetModLocalization("BWDTrash")

L:SetGeneralLocalization({
	name = "Trash des Pechschwingenabstiegs"
})

--------------------------
--  Halfus Wyrmbreaker  --
--------------------------
L = DBM:GetModLocalization(156)

L:SetOptionLocalization({
	ShowDrakeHealth		= "Zeige die Gesundheit befreiter Drachen (benötigt aktivierte Lebensanzeige)"
})

---------------------------
--  Valiona & Theralion  --
---------------------------
L = DBM:GetModLocalization(157)

L:SetOptionLocalization({
	TBwarnWhileBlackout		= "Warne auch bei aktivem $spell:86788 vor $spell:86369",
	TwilightBlastArrow		= "Zeige DBM-Pfeil, falls $spell:86369 in deiner Nähe ist",
	RangeFrame				= "Zeige Abstandsfenster (10m)",
	BlackoutShieldFrame		= "Zeige Lebensanzeige mit einem Balken für $spell:86788"
})

L:SetMiscLocalization({
	Trigger1				= "Tiefer Atem",
	BlackoutTarget			= "Blackout: %s"
})

----------------------------------
--  Twilight Ascendant Council  --
----------------------------------
L = DBM:GetModLocalization(158)

L:SetWarningLocalization({
	specWarnBossLow			= "%s unter 30%% - nächste Phase bald!",
	SpecWarnGrounded		= "Hole Geerdet",
	SpecWarnSearingWinds	= "Hole Wirbelnde Winde"
})

L:SetTimerLocalization({
	timerTransition			= "Phasenübergang"
})

L:SetOptionLocalization({
	specWarnBossLow			= "Spezialwarnung, wenn Bosse unter 30% Lebenspunkten sind",
	SpecWarnGrounded		= "Spezialwarnung, falls dir der $spell:83581 Buff fehlt<br/>(~10 Sekunden vor dem Wirken von $spell:83067)",
	SpecWarnSearingWinds	= "Spezialwarnung, falls dir der $spell:83500 Buff fehlt<br/>(~10 Sekunden vor dem Wirken von $spell:83565)",
	timerTransition			= "Dauer des Phasenübergangs anzeigen",
	RangeFrame				= "Zeige Abstandsfenster automatisch bei Bedarf",
	yellScrewed				= "Schreie, wenn du gleichzeitig von $spell:83099 und $spell:92307 betroffen bist",
	InfoFrame				= "Zeige Infofenster für Spieler ohne $spell:83581 bzw. $spell:83500"
})

L:SetMiscLocalization({
	Quake			= "Der Boden unter Euch grollt unheilvoll...",
	Thundershock	= "Die Luft beginnt, vor Energie zu knistern...",
	Switch			= "Genug der Spielereien!",--"Wir kümmern uns um sie!" comes 3 seconds after this one
	Phase3			= "Beeindruckende Leistung…",--"SCHMECKT DIE VERDAMMNIS!" is about 13 seconds after; its indeed this special UTF-8 char at end, not "..." (logfiles 5.1.0.16309)
	Kill			= "Unmöglich…", -- its indeed this special UTF-8 char at end, not "..." (logfiles 5.1.0.16309)
	blizzHatesMe	= "Leuchtfeuer & Ableiter auf mir! Aus dem Weg!",
	WrongDebuff		= "Kein %s"
})

----------------
--  Cho'gall  --
----------------
L = DBM:GetModLocalization(167)

L:SetOptionLocalization({
	CorruptingCrashArrow	= "Zeige DBM-Pfeil, falls $spell:81685 nahe bei dir ist",
	InfoFrame				= "Zeige Infofenster für $journal:3165",
	RangeFrame				= "Zeige Abstandsfenster (5m) für $journal:3165"
})

----------------
--  Sinestra  --
----------------
L = DBM:GetModLocalization(168)

L:SetWarningLocalization({
	WarnOrbSoon			= "Schattenkugeln in %d Sekunden!",
	SpecWarnOrbs		= "Schattenkugeln kommen! Aufpassen!",
	warnWrackJump		= "%s gesprungen auf >%s<",
	warnAggro			= "Spieler mit Aggro (Schattenkugeln-Kandidaten): >%s<",
	SpecWarnAggroOnYou	= "Du hast Aggro! Auf Schattenkugeln achten!"
})

L:SetTimerLocalization({
	TimerEggWeakening	= "Zwielichtpanzer zerfällt",   -- ( 4sec timer)
	TimerEggWeaken		= "Zwielichtpanzer Erneuerung", -- (30sec timer)
	TimerOrbs			= "Nächste Schattenkugeln"
})

L:SetOptionLocalization({
	WarnOrbSoon			= "Zeige Vorwarnung für Schattenkugeln (5s zuvor, sekündlich)<br/>(voraussichtlich, kann ungenau sein, kann spammen)",
	warnWrackJump		= "Verkünde Sprungziele von $spell:89421",
	warnAggro			= "Verkünde Spieler mit Aggro, wenn Schattenkugeln erscheinen<br/>(mögliches Ziel der Schattenkugeln)",
	SpecWarnAggroOnYou	= "Spezialwarnung, falls du Aggro hast, wenn Schattenkugeln erscheinen (mögliches Ziel der Schattenkugeln)",
	SpecWarnOrbs		= "Spezialwarnung, wenn Schattenkugeln erscheinen (voraussichtlich)",
	TimerEggWeakening	= "Zeige Timer, wenn $spell:87654 zerfällt",
	TimerEggWeaken		= "Dauer der Erneuerung des $spell:87654 anzeigen",
	TimerOrbs			= "Zeige Zeit bis nächste Schattenkugeln erscheinen<br/>(voraussichtlich, kann ungenau sein)",
	SetIconOnOrbs		= "Setze Zeichen auf Spieler mit Aggro, wenn Schattenkugeln erscheinen<br/>(mögliches Ziel der Schattenkugeln)",
	InfoFrame			= "Zeige Infofenster für Spieler mit Aggro"
})

L:SetMiscLocalization({
	YellDragon			= "Fresst, Kinder! Nährt Euch an ihrem Fleisch!",
	YellEgg				= "Ihr denkt, ich sei schwach? Narren!",
	HasAggro			= "Hat Aggro"
})

-------------------------------------
--  The Bastion of Twilight Trash  --
-------------------------------------
L = DBM:GetModLocalization("BoTrash")

L:SetGeneralLocalization({
	name =	"Trash der Bastion des Zwielichts"
})

------------------------
--  Conclave of Wind  --
------------------------
L = DBM:GetModLocalization(154)

L:SetWarningLocalization({
	warnSpecial			= "Hurrikan/Zephyr/Graupelsturm aktiv",
	specWarnSpecial		= "Spezialfähigkeiten aktiv!",
	warnSpecialSoon		= "Spezialfähigkeiten in 10 Sekunden!"
})

L:SetTimerLocalization({
	timerSpecial		= "Spezialfähigkeiten CD",
	timerSpecialActive	= "Spezialfähigkeiten aktiv"
})

L:SetOptionLocalization({
	warnSpecial			= "Zeige Warnung, wenn Hurrikan/Zephyr/Graupelsturm gewirkt werden",
	specWarnSpecial		= "Spezialwarnung, wenn Spezialfähigkeiten gewirkt werden",
	timerSpecial		= "Zeige Abklingzeit für Spezialfähigkeiten",
	timerSpecialActive	= "Dauer der Spezialfähigkeiten anzeigen",
	warnSpecialSoon		= "Zeige Vorwarnung 10 Sekunden vor den Spezialfähigkeiten",
	OnlyWarnforMyTarget	= "Zeige Warnungen und Timer nur für aktuelles Ziel und Fokusziel<br/>(Versteckt den Rest. Dies beinhaltet den PULL!)"
})

L:SetMiscLocalization({
	gatherstrength	= "%s beinnt von den verbliebenen Windlords Stärke zu beziehen!" --yes the typo is from the logfiles (4.06a) "<356.9> RAID_BOSS_EMOTE#%s beinnt von den verbliebenen Windlords Stärke zu beziehen!#Rohash#####0#0##0#1616##0#false#false", -- [6]
})

---------------
--  Al'Akir  --
---------------
L = DBM:GetModLocalization(155)

L:SetTimerLocalization({
	TimerFeedback 	= "Rückkopplung (%d)"
})

L:SetOptionLocalization({
	TimerFeedback	= "Dauer von $spell:87904 anzeigen",
	RangeFrame		= "Zeige Abstandsfenster (20m), wenn du von $spell:89668 betroffen bist"
})

-----------------
-- Beth'tilac --
-----------------
L= DBM:GetModLocalization(192)

L:SetMiscLocalization({
	EmoteSpiderlings 	= "Spinnlinge sind aus ihrem Nest aufgeschreckt worden!"
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
	WarnNewInitiate		= "Lodernde Kralleninitianden (%s)"
})

L:SetTimerLocalization({
	TimerPhaseChange	= "Phase %d",
	TimerHatchEggs		= "Eierausschlüpfen",
	timerNextInitiate	= "Nächste Initianden (%s)"
})

L:SetOptionLocalization({
	WarnPhase			= "Zeige Warnung für jeden Phasenwechsel",
	WarnNewInitiate		= "Zeige Warnung für neue Lodernde Kralleninitianden",
	timerNextInitiate	= "Zeige Zeit bis nächste Lodernde Kralleninitianden",
	TimerPhaseChange	= "Zeige Zeit bis nächste Phase",
	TimerHatchEggs		= "Zeige Zeit bis nächstes Eierausschlüpfen"
})

L:SetMiscLocalization({
	YellPull		= "Ich diene jetzt einem neuen Meister, Sterbliche!",
	YellPhase2		= "Dieser Himmel ist MEIN.",
	LavaWorms		= "Feurige Lavawürmer brechen aus dem Boden hervor!",
	East			= "Osten",
	West			= "Westen",
	Both			= "beidseitig"
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
	timerStrike			= "Nächster %s",
	TimerBladeActive	= "%s",
	TimerBladeNext		= "Nächste Klinge"
})

L:SetOptionLocalization({
	ResetShardsinThrees	= "Neustart der $spell:99259 Zählung in 3er-Gruppen (25 Spieler) bzw. 2er-Gruppen (10 Spieler)",
	warnStrike			= "Zeige Warnungen für $spell:99353 / $spell:101002",
	timerStrike			= "Zeit bis nächster $spell:99353 / $spell:101002 anzeigen",
	TimerBladeActive	= "Dauer der aktiven Klinge anzeigen",
	TimerBladeNext		= "Zeit bis nächste $spell:99352 / $spell:99350 anzeigen"
})

--------------------------------
-- Majordomo Fandral Staghelm --
--------------------------------
L= DBM:GetModLocalization(197)

L:SetTimerLocalization({
	timerNextSpecial	= "Nächste %s (%d)"
})

L:SetOptionLocalization({
	timerNextSpecial			= "Zeige Zeit bis nächste Spezialfähigkeit ($spell:98474 / $spell:100208)",
	RangeFrameSeeds				= "Zeige Abstandsfenster (12m) für $spell:98450",
	RangeFrameCat				= "Zeige Abstandsfenster (10m) für $spell:98374"
})

--------------
-- Ragnaros --
--------------
L= DBM:GetModLocalization(198)

L:SetWarningLocalization({
	warnRageRagnarosSoon	= "%s auf %s in 5 Sekunden",--Spellname on targetname
	warnSplittingBlow		= "%s im %s",--Spellname in Location
	warnEngulfingFlame		= "%s im %s",--Spellname in Location
	warnEmpoweredSulf		= "%s in 5 Sekunden"
})

L:SetTimerLocalization({
	timerRageRagnaros		= "%s auf %s",--Spellname on targetname
	TimerPhaseSons			= "Phasenübergang endet"
})

L:SetOptionLocalization({
	warnSplittingBlow			= "Zeige Warnungen für Position des $spell:98951",
	warnEngulfingFlame			= "Zeige Warnungen für Position der $spell:99171 auf Normal",
	warnEngulfingFlameHeroic	= "Zeige Warnungen für Position der $spell:99171 auf Heroisch",
	warnSeedsLand				= "Zeige Warnung/Timer für Landung der $spell:98520 (anstatt Erzeugung)",
	TimerPhaseSons				= "Dauer des Phasenübergangs (\"Söhne der Flamme\") anzeigen",
	InfoHealthFrame				= "Zeige Infofenster für Gesundheit (weniger als 100k Lebenspunkte)",
	MeteorFrame					= "Zeige Infofenster für Ziele von $spell:99849",
	AggroFrame					= "Zeige Infofenster für Spieler, die keine Aggro während $journal:2647 haben"
})

L:SetMiscLocalization({
	East				= "Osten",
	West				= "Westen",
	Middle				= "Zentrum",
	North				= "Nahkampfbereich",
	South				= "Außenbereich",
	HealthInfo			= "Unter 100k LP",
	HasNoAggro			= "Keine Aggro",
	MeteorTargets		= "Meteorziele!",
	TransitionEnded1	= "Genug! Ich werde dem ein Ende machen.",
	TransitionEnded2	= "Sulfuras wird Euer Ende sein.",
	TransitionEnded3	= "Auf die Knie, Sterbliche! Das ist das Ende.",
	Defeat				= "Zu früh!… Ihr kommt zu früh...",
	Phase4				= "Zu früh!…"
})

-----------------------
--  Firelands Trash  --
-----------------------
L = DBM:GetModLocalization("FirelandsTrash")

L:SetGeneralLocalization({
	name = "Trash der Feuerlande"
})

----------------
--  Volcanus  --
----------------
L = DBM:GetModLocalization("Volcanus")

L:SetGeneralLocalization({
	name = "Volcanus"
})

L:SetTimerLocalization({
	timerStaffTransition	= "Phasenübergang endet"
})

L:SetOptionLocalization({
	timerStaffTransition	= "Dauer des Phasenübergangs anzeigen"
})

L:SetMiscLocalization({
	StaffEvent			= "Der Zweig von Nordrassil reagiert heftig auf die Berührung von %S+.",--Reg expression pull match
	StaffTrees			= "Brennende Treants brechen aus dem Boden hervor, um dem Beschützer beizustehen!",--Might add a spec warning for this later.
	StaffTransition		= "Die Feuer, die den gepeinigten Beschützer verzehren, erlöschen!"
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
	KohcromWarning	= "%s: %s"
})

L:SetTimerLocalization({
	KohcromCD		= "Kohcrom imitiert %s"
})

L:SetOptionLocalization({
	KohcromWarning	= "Zeige Warnungen, wenn $journal:4262 Fähigkeiten nachahmt",
	KohcromCD		= "Zeige Zeiten bis $journal:4262 Fähigkeiten nachahmt",
	RangeFrame		= "Zeige Abstandsfenster (5m) für Erfolg \"Rück' mir nicht auf die Pelle\""
})

L:SetMiscLocalization({
})

---------------------
-- Warlord Zon'ozz --
---------------------
L= DBM:GetModLocalization(324)

L:SetOptionLocalization({
	ShadowYell			= "Schreie, wenn du von $spell:103434 betroffen bist<br/>(nur heroischer Schwierigkeitsgrad)",
	CustomRangeFrame	= "Abstandsfenster (10m) für Störende Schatten (nur heroischer Schwierigkeitsgrad)",
	Never				= "Deaktiviert",
	Normal				= "Aktiviert (ohne Debufffilter)",
	DynamicPhase2		= "Aktiviert (mit Debufffilter in Phase 2)",
	DynamicAlways		= "Aktiviert (mit Debufffilter in allen Phasen)"
})

L:SetMiscLocalization({
	voidYell	= "Gul'kafh an'qov N'Zoth." -- verified (4.3.0.15050de)
})

-----------------------------
-- Yor'sahj the Unsleeping --
-----------------------------
L= DBM:GetModLocalization(325)

L:SetWarningLocalization({
	warnOozesHit	= "%s absorbierte %s"
})

L:SetTimerLocalization({
	timerOozesActive	= "Kugeln angreifbar",
	timerOozesReach		= "Kugeln erreichen Boss"
})

L:SetOptionLocalization({
	warnOozesHit		= "Verkünde die Farben der Blutkugeln, die den Boss getroffen haben",
	timerOozesActive	= "Zeige Zeit bis Blutkugeln angreifbar sind",
	timerOozesReach		= "Zeige Zeit bis Blutkugeln Yor'sahj erreichen",
	RangeFrame			= "Zeige Abstandsfenster (4m) für $spell:104898<br/>(normaler und heroischer Schwierigkeitsgrad)"
})

L:SetMiscLocalization({
	Black			= "|cFF424242schwarz|r",
	Purple			= "|cFF9932CDpurpur|r",
	Red				= "|cFFFF0404rot|r",
	Green			= "|cFF088A08grün|r",
	Blue			= "|cFF0080FFblau|r",
	Yellow			= "|cFFFFA901gelb|r"
})

-----------------------
-- Hagara the Binder --
-----------------------
L= DBM:GetModLocalization(317)

L:SetWarningLocalization({
	WarnPillars				= "%s: %d verbleibend",
	warnFrostTombCast		= "%s in 8 Sekunden"
})

L:SetTimerLocalization({
	TimerSpecial			= "Erste Spezialfähigkeit"
})

L:SetOptionLocalization({
	WarnPillars				= "Verkünde die Anzahl der verbleibenden $journal:3919 bzw. $journal:4069e",
	TimerSpecial			= "Zeige Zeit bis erste Spezialfähigkeit gewirkt wird",
	RangeFrame				= "Zeige Abstandsfenster für $spell:105269 (3m) bzw. $journal:4327 (10m)",
	AnnounceFrostTombIcons	= "Verkünde Zeichen für Ziele von $spell:104451 im Schlachtzugchat (nur als Leiter)",
	SpecialCount			= "Spiele akustischen Countdown für $spell:105256 bzw. $spell:105465",
	SetBubbles				= "Automatische Deaktivierung d. 'Sprechblasen' bevor $spell:104451 gewirkt wird<br/>(wird nach dem Kampfende auf die vorherige Einstellung zurückgesetzt)"
})

L:SetMiscLocalization({
	TombIconSet				= "Eisgrabzeichen {rt%d} auf %s gesetzt"
})

---------------
-- Ultraxion --
---------------
L= DBM:GetModLocalization(331)

L:SetWarningLocalization({
	specWarnHourofTwilightN		= "%s (%d) in 5 Sek"
})

L:SetTimerLocalization({
	TimerCombatStart	= "Ultraxion aktiv"
})

L:SetOptionLocalization({
	TimerCombatStart	= "Zeige Dauer des Rollenspiels bevor Ultraxion aktiv wird",
	ResetHoTCounter		= "Neustart der Stunde des Zwielichts Zählung",
	Never				= "Nie",
	ResetDynamic		= "In 3er/2er-Gruppen (heroisch/normal)",
	Reset3Always		= "Immer in 3er-Gruppen",
	SpecWarnHoTN		= "Spezialvorwarnung für Stunde des Zwielichts (bei Neustart auf \"Nie\" nach 3er-Gruppenregel)",
	One					= "5 Sekunden vor Zählerstand 1 (1 4 7 ...)",
	Two					= "5 Sekunden vor Zählerstand 2 (2 5 ...)",
	Three				= "5 Sekunden vor Zählerstand 3 (3 6 ...)"
})

L:SetMiscLocalization({
	Pull				= "Ich spüre, wie eine gewaltige Störung in der Harmonie näherkommt. Das Chaos bereitet meiner Seele Schmerzen."
})

-------------------------
-- Warmaster Blackhorn --
-------------------------
L= DBM:GetModLocalization(332)

L:SetWarningLocalization({
	SpecWarnElites	= "Zwielichtelitegegner!"
})

L:SetTimerLocalization({
	TimerAdd			= "Nächste Elitegegner"
})

L:SetOptionLocalization({
	TimerAdd			= "Zeige Zeit bis nächste Zwielichtelitegegner erscheinen",
	SpecWarnElites		= "Spezialwarnung, wenn neue Zwielichtelitegegner erscheinen",
	SetTextures			= "Automatische Deaktivierung der Grafikeinstellung 'Projizierte Texturen' in Phase 1 (wird in Phase 2 automatisch wieder aktiviert)"
})

L:SetMiscLocalization({
	SapperEmote			= "Ein Drache stürzt herab, um einen Zwielichtpionier auf dem Deck abzusetzen!",
	GorionaRetreat			= "schreit vor Schmerzen auf und zieht sich in die wirbelnden Wolken zurück."
})

-------------------------
-- Spine of Deathwing  --
-------------------------
L= DBM:GetModLocalization(318)

L:SetWarningLocalization({
	warnSealArmor			= "%s",
	SpecWarnTendril			= "Festhalten!"
})

L:SetOptionLocalization({
	SpecWarnTendril			= "Spezialwarnung, falls dir der $spell:105563 Buff fehlt",
	InfoFrame				= "Zeige Infofenster für Spieler ohne $spell:105563",
	ShowShieldInfo			= "Zeige Lebensanzeige mit einem Balken für $spell:105479"
})

L:SetMiscLocalization({
	Pull			= "Die Platten! Es zerreißt ihn! Zerlegt die Platten und wir können ihn vielleicht runterbringen.",
	NoDebuff		= "Keine %s",
	PlasmaTarget	= "Sengendes Plasma: %s",
	DRoll			= "wird gleich",
	DLevels			= "stabilisiert sich"
})

---------------------------
-- Madness of Deathwing  --
---------------------------
L= DBM:GetModLocalization(333)

L:SetOptionLocalization({
	RangeFrame			= "Zeige dynamisches Abstandsfenster (10m) basierend auf Spieler-Debuffs für $spell:108649 auf heroischem Schwierigkeitsgrad"
})

L:SetMiscLocalization({
	Pull				= "Ihr habt NICHTS erreicht. Ich werde Eure Welt in STÜCKE reißen."
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("DSTrash")

L:SetGeneralLocalization({
	name =	"Trash der Drachenseele"
})

L:SetWarningLocalization({
	DrakesLeft			= "Zwielichtangreifer verbleibend: %d"
})

L:SetTimerLocalization({
	timerRoleplay		= GUILD_INTEREST_RP,
	TimerDrakes			= "%s"
})

L:SetOptionLocalization({
	DrakesLeft			= "Verkünde die Anzahl der verbleibenden Zwielichtangreifer",
	TimerDrakes			= "Zeige Zeit bis zur $spell:109904 der Zwielichtangreifer"
})

L:SetMiscLocalization({
	firstRP				= "Preiset die Titanen, sie sind zurückgekehrt!",
	UltraxionTrash		= "Es tut gut, Euch wiederzusehen, Alexstrasza. Während meiner Abwesenheit war ich fleißig.",
	UltraxionTrashEnded = "Sie waren bloß Welpen, Experimente, Mittel zu einem Zweck. Ihr werdet sehen, was meine Forschung hervorgebracht hat."
})
