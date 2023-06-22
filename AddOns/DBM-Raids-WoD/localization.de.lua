if GetLocale() ~= "deDE" then
	return
end
local L

---------------
-- Kargath Bladefist --
---------------
L = DBM:GetModLocalization(1128)

L:SetTimerLocalization({
	timerSweeperCD	= "Nächster Arena Sweeper"
})

---------------------------
-- The Butcher --
---------------------------
L = DBM:GetModLocalization(971)

---------------------------
-- Tectus, the Living Mountain --
---------------------------
L = DBM:GetModLocalization(1195)

L:SetMiscLocalization({
	pillarSpawn	= "ERHEBT EUCH, BERGE!"
})

------------------
-- Brackenspore, Walker of the Deep --
------------------
L = DBM:GetModLocalization(1196)

L:SetOptionLocalization({
	InterruptCounter	= "Setze \"Verrottung\"-Zähler zurück nach",
	Two					= "zwei Wirkungen",
	Three				= "drei Wirkungen",
	Four				= "vier Wirkungen"
})

--------------
-- Twin Ogron --
--------------
L = DBM:GetModLocalization(1148)

L:SetOptionLocalization({
	PhemosSpecial		= "Spiele akustischen Countdown für Phemos' Spezialfähigkeiten",
	PolSpecial			= "Spiele akustischen Countdown für Pols Spezialfähigkeiten",
	PhemosSpecialVoice	= "Spiele gesprochene Warnungen für Phemos' Spezialfähigkeiten",
	PolSpecialVoice		= "Spiele gesprochene Warnungen für Pols Spezialfähigkeiten"
})

--------------------
--Koragh --
--------------------
L = DBM:GetModLocalization(1153)

L:SetWarningLocalization({
	specWarnExpelMagicFelFades	= "Teufelsenergie endet in 5s - geh zum Start"
})

L:SetOptionLocalization({
	specWarnExpelMagicFelFades	= "Spezialwarnung zum Hingehen zur Startposition, wenn $spell:172895 endet"
})

L:SetMiscLocalization({
	supressionTarget1	= "Ich werde Euch zermalmen!",
	supressionTarget2	= "Schweigt!",
	supressionTarget3	= "Ruhe!",
	supressionTarget4	= "Ich reiße Euch in Stücke!"
})

--------------------------
-- Imperator Mar'gok --
--------------------------
L = DBM:GetModLocalization(1197)

L:SetTimerLocalization({
	timerNightTwistedCD	= "Nächste Nachtsiechende Gläubiger"
})

L:SetOptionLocalization({
	GazeYellType		= "Typ des Schreis für Starren des Abgrunds",
	Countdown			= "Countdown bis zum Ablauf",
	Stacks				= "Stapelanzahl beim Erhalt",
	timerNightTwistedCD	= "Zeige Zeit bis nächste Nachtsiechende Gläubiger erscheinen"
})

L:SetMiscLocalization({
	BrandedYell		= "Gebrandmarkt (%d) %dm",
	GazeYell		= "Starren endet in %d",
	GazeYell2		= "Starren (%d) auf %s",
	PlayerDebuffs	= "Nächste zum Vorgeschmack"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("HighmaulTrash")

L:SetGeneralLocalization({
	name	= "Trash des Hochfels"
})

---------------
-- Gruul --
---------------
L = DBM:GetModLocalization(1161)

L:SetOptionLocalization({
	MythicSoakBehavior	= "Strategie für Infernoschlitzer im mythischen Schwierigkeitsgrad (für Spezialwarnungen)",
	ThreeGroup			= "3 Gruppen (jede 1 Stapel)",
	TwoGroup			= "2 Gruppen (jede 2 Stapel)"
})

---------------------------
-- Oregorger, The Devourer --
---------------------------
L = DBM:GetModLocalization(1202)

L:SetOptionLocalization({
	InterruptBehavior	= "Verhalten der Unterbrechungswarnungen",
	Smart				= "basierend auf dem Stapel von Schwarzfelsstacheln des Bosses",
	Fixed				= "immer 5er- oder 3er-Sequenz nutzen (selbst wenn sich der Boss nicht so verhält)"
})

---------------------------
-- The Blast Furnace --
---------------------------
L = DBM:GetModLocalization(1154)

L:SetWarningLocalization({
	warnRegulators			= "Hitzeregler verbleibend: %d",
	warnBlastFrequency		= "Flammenzunge Häufigkeit erhöht: ca. alle %d Sekunden",
	specWarnTwoVolatileFire	= "Doppeltes Flüchtiges Feuer auf dir!"
})

L:SetOptionLocalization({
	warnRegulators			= "Verkünde die Anzahl der verbleibenden Hitzeregler",
	warnBlastFrequency		= "Verkünde, wenn sich die $spell:155209 Häufigkeit erhöht",
	specWarnTwoVolatileFire	= "Spezialwarnung, wenn du $spell:176121 doppelt hast",
	InfoFrame				= "Zeige Infofenster für $spell:155192 und $spell:155196",
	VFYellType2				= "Typ des Schreis für Flüchtiges Feuer (nur mythischer Schwierigkeitsgrad)",
	Countdown				= "Countdown bis zum Ablauf",
	Apply					= "nur Erhalt"
})

L:SetMiscLocalization({
	heatRegulator	= "Hitzeregler",
	Regulator		= "Regler %d",
	bombNeeded		= "%d Bombe(n)"
})

--------------------------
-- Operator Thogar --
--------------------------
L = DBM:GetModLocalization(1147)

L:SetWarningLocalization({
	specWarnSplitSoon	= "Schlachtzugteilung in 10"
})

L:SetOptionLocalization({
	specWarnSplitSoon	= "Spezialwarnung 10 Sekunden bevor sich der Schlachtzug teilt",
	InfoFrameSpeed		= "Infofenster zeigt nächste Zuginformation",
	Immediately			= "sobald sich die Türen für den aktuellen Zug öffnen",
	Delayed				= "nachdem der aktuelle Zug herausgekommen ist",
	HudMapUseIcons		= "Benutze Schlachtzugzeichen für HudMap statt grünen Kreis",
	TrainVoiceAnnounce	= "Gesprochene Warnungen für Züge",
	LanesOnly			= "Verkünde nur Gleise mit ankommenden Zügen",
	MovementsOnly		= "Verkünde nur Bewegungen zu einem anderen Gleis (nur mythisch)",
	LanesandMovements	= "Verkünde Gleise mit ankommenden Zügen und Bewegungen (nur mythisch)"
})

L:SetMiscLocalization({
	Train			= "Zug",
	lane			= "Gleis",
	oneTrain		= "ein zufälliges Gleis: Zug",
	oneRandom		= "erscheinen auf einem zufälligen Gleis",
	threeTrains		= "drei zufällige Gleise: Zug",
	threeRandom		= "erscheinen auf drei zufälligen Gleisen",
	helperMessage	= "Dieser Kampf kann durch das Drittanbieter-Addon \"Thogar Assist\" oder einen der zahlreichen DBM-Sprachpacks (diese sagen die Züge akustisch an) erleichtert werden, verfügbar auf Curse."
})

--------------------------
-- The Iron Maidens --
--------------------------
L = DBM:GetModLocalization(1203)

L:SetWarningLocalization({
	specWarnReturnBase	= "Kehre zum Dock zurück!"
})

L:SetOptionLocalization({
	specWarnReturnBase	= "Spezialwarnung, wenn Spieler auf dem Schiff gefahrlos zum Dock zurückkehren können",
	filterBladeDash3	= "Keine Spezialwarnung für $spell:155794, wenn du von $spell:170395 betroffen bist",
	filterBloodRitual3	= "Keine Spezialwarnung für $spell:158078, wenn du von $spell:170405 betroffen bist"
})

L:SetMiscLocalization({
	shipMessage		= "bereitet sich darauf vor, die Hauptkanone des Schlachtschiffs zu bemannen!",
	EarlyBladeDash	= "Zu langsam."
})

--------------------------
-- Blackhand --
--------------------------
L = DBM:GetModLocalization(959)

L:SetWarningLocalization({
	specWarnMFDPosition		= "Todesurteil Position: %s",
	specWarnSlagPosition	= "Bombe Position: %s"
})

L:SetOptionLocalization({
	PositionsAllPhases	= "Gebe Position in $spell:156096 Schreien während allen Phasen an (anstatt nur in Phase 3) (im Wesentlichen für Testzwecke, nicht notwendig)",
	InfoFrame			= "Zeige Infofenster für $spell:155992 und $spell:156530"
})

L:SetMiscLocalization({
	customMFDSay	= "Todesurteil %s auf %s",
	customSlagSay	= "Bombe %s auf %s"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("BlackrockFoundryTrash")

L:SetGeneralLocalization({
	name	= "Trash der Schwarzfelsgießerei"
})

---------------
-- Hellfire Assault --
---------------
L = DBM:GetModLocalization(1426)

L:SetTimerLocalization({
	timerSiegeVehicleCD	= "Nächste Maschine %s"
})

L:SetOptionLocalization({
	timerSiegeVehicleCD = "Zeige Zeit bis nächste Belagerungsmaschinen erscheinen"
})

L:SetMiscLocalization({
	AddsSpawn1	= "Comin' in hot!",--translate (trigger) (unused)
	AddsSpawn2	= "Fire in the hole!",--translate (trigger) (unused)
	BossLeaving	= "Ich bin gleich wieder da..."
})

---------------------------
-- Hellfire High Council --
---------------------------
L = DBM:GetModLocalization(1432)

L:SetWarningLocalization({
	reapDelayed	= "Ernte nachdem Erscheinung endet"
})

--------------
-- Kilrogg Deadeye --
--------------
L = DBM:GetModLocalization(1396)

L:SetMiscLocalization({
	BloodthirstersSoon	= "Kommt, Brüder! Eure Bestimmung wartet!"
})

--------------------
--Gorefiend --
--------------------
L = DBM:GetModLocalization(1372)

L:SetTimerLocalization({
	SoDDPS2		= "Nächste Schatten (%s)",
	SoDTank2	= "Nächste Schatten (%s)",
	SoDHealer2	= "Nächste Schatten (%s)"
})

L:SetOptionLocalization({
	SoDDPS2			= "Zeige Zeit bis nächste $spell:179864 die DDs betreffen",
	SoDTank2		= "Zeige Zeit bis nächste $spell:179864 die Tanks betreffen",
	SoDHealer2		= "Zeige Zeit bis nächste $spell:179864 die Heiler betreffen",
	ShowOnlyPlayer	= "Zeige HudMap für $spell:179909 nur, falls du beteiligt bist"
})

--------------------------
-- Shadow-Lord Iskar --
--------------------------
L = DBM:GetModLocalization(1433)

L:SetWarningLocalization({
	specWarnThrowAnzu	=	"Wirf Auge von Anzu zu %s!"
})

L:SetOptionLocalization({
	specWarnThrowAnzu	=	"Spezialwarnung, wenn du das $spell:179202 werfen musst"
})

--------------------------
-- Fel Lord Zakuun --
--------------------------
L = DBM:GetModLocalization(1391)

L:SetOptionLocalization({
	SeedsBehavior	= "Auswahl der Positionierungsschreie für Saat der Zerstörung (nur als Schlachtzugsleiter)",
	Iconed			= "Stern, Kreis, Diamant, Dreieck, Mond (für Strategien mit Weltmarkierungen)",
	Numbered		= "1, 2, 3, 4, 5 (für Strategien mit nummerierten Positionen)",
	DirectionLine	= "Links, Mitte Links, Mitte, Mitte Rechts, Rechts (typisch für geradlinige Formationen)",
	FreeForAll		= "Nur Standardschrei verwenden (ohne Positionszuweisung)"
})

L:SetMiscLocalization({
	DBMConfigMsg	= "Die Positionierungsschreie für Saat der Zerstörung wurden wie beim Schlachtzugsleiter auf \"%s\" gesetzt.",
	BWConfigMsg		= "Der Schlachtzugsleiter nutzt \"BigWigs\". DBM wird für die Schreie für Saat der Zerstörung automatisch \"nummerierte Positionen\" verwenden."
})

--------------------------
-- Xhul'horac --
--------------------------
L = DBM:GetModLocalization(1447)

L:SetOptionLocalization({
	ChainsBehavior	= "Warnverhalten bei Dämonenketten",
	Cast			= "nur ursprüngliches Ziel bei Zauberbeginn (Timersynchronisierung auf Zauberbeginn)",
	Applied			= "nur betroffene Ziele bei Zauberende (Timersynchronisierung auf Zauberende)",
	Both			= "urspüngliches Ziel bei Zauberbeginn und betroffene Ziele bei Zauberende"
})

--------------------------
-- Socrethar the Eternal --
--------------------------
L = DBM:GetModLocalization(1427)

L:SetOptionLocalization({
	InterruptBehavior	= "Auswahl des Unterbrechungsverhaltens für Vorherrschaft (nur als Schlachtzugsleiter)",
	Count3Resume		= "3-Personen-Rotation, die fortgesetzt wird, wenn die Barriere fällt",
	Count3Reset			= "3-Personen-Rotation, die auf 1 zurückgesetzt wird, wenn die Barriere fällt",
	Count4Resume		= "4-Personen-Rotation, die fortgesetzt wird, wenn die Barriere fällt",
	Count4Reset			= "4-Personen-Rotation, die auf 1 zurückgesetzt wird, wenn die Barriere fällt"
})

--------------------------
-- Mannoroth --
--------------------------
L = DBM:GetModLocalization(1395)

L:SetOptionLocalization({
	CustomAssignWrath	= "Setze $spell:186348 Zeichen basierend auf Spielerrollen (muss vom Schlachtzugsleiter aktiviert werden, kann zu Konflikten mit \"BigWigs\" oder veralteten DBM-Versionen führen)"
})

L:SetMiscLocalization({
	felSpire	= "beginnt, die Teufelsspitze zu verstärken!"
})

--------------------------
-- Archimonde --
--------------------------
L = DBM:GetModLocalization(1438)

L:SetWarningLocalization({
	specWarnBreakShackle	= "Gefesselte Pein: Breche als %s!"
})

L:SetOptionLocalization({
	specWarnBreakShackle	= "Spezialwarnung, wenn du von $spell:184964 betroffen bist (diese Warnung weist zur Minimierung des gleichzeitigen Schadens die Brechungsreihenfolge automatisch zu)",
	ExtendWroughtHud3		= "Erweitere die HudMap-Linien über das Ziel von $spell:185014 hinaus (kann die Liniengenauigkeit verringern)",
	AlternateHudLine		= "Nutze alternative Linientextur für HudMap-Linien zwischen Zielen von $spell:185014",
	NamesWroughtHud			= "Zeige Spielernamen in HudMap für Ziele von $spell:185014",
	FilterOtherPhase		= "Zeige keine Warnungen für Ereignisse, die sich nicht in deiner Phase befinden",
	MarkBehavior			= "Auswahl der Positionierungsschreie für Mal der Legion (nur als Schlachtzugsleiter)",
	Numbered				= "Stern, Kreis, Diamant, Dreieck (für Strategien mit Weltmarkierungen)",
	LocSmallFront			= "Nah L/R (Stern, Kreis), Fern L/R (Diamant, Dreieck), kurze Debuffs Nah",
	LocSmallBack			= "Nah L/R (Stern, Kreis), Fern L/R (Diamant, Dreieck), kurze Debuffs Fern",
	NoAssignment			= "Deaktiviere Positionierungsschreie, -zeichen und -HUD bei allen im Schlachtzug",
	overrideMarkOfLegion	= "Blockiere Überschreiben des Mal der Legion Verhaltens durch den Schlachtzugsleiter (nur empfohlen für Experten, die sich sicher sind, dass ihre eigenen Einstellungen den Absichten des Schlachtzugsleiters nicht widersprechen)"
})

L:SetMiscLocalization({
	phase2point5	= "Seht die endlosen Ränge der Brennenden Legion und erkennt die Ausichtslosigkeit Eurer Widerwehr!",
	First			= "Erster",
	Second			= "Zweiter",
	Third			= "Dritter"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("HellfireCitadelTrash")

L:SetGeneralLocalization({
	name	= "Trash der Höllenfeuerzitadelle"
})
