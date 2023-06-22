if GetLocale() ~= "deDE" then return end
local L

---------------
--  Kalecgos --
---------------
L = DBM:GetModLocalization("Kal")

L:SetGeneralLocalization{
	name = "Kalecgos"
}

L:SetWarningLocalization{
	WarnPortal			= "Portal #%d : >%s< (Gruppe %d)",
	SpecWarnWildMagic	= "Wilde Magie - %s!"
}

L:SetOptionLocalization{
	WarnPortal			= "Zeige Warnung für Ziel von $spell:46021",
	SpecWarnWildMagic	= "Spezialwarnung für Wilde Magie",
	ShowFrame			= "Zeige Spektralreichfenster",
	FrameClassColor		= "Benutze Klassenfarben in Spektralreichfenster",
	FrameUpwards		= "Erweitere Spektralreichfenster nach oben",
	FrameLocked			= "Setze Spektralreichfenster auf gesperrt (nicht verschiebbar)"
}

L:SetMiscLocalization{
	Demon				= "Sathrovarr der Verderber",
	Heal				= "Heilung +100%",
	Haste				= "Zauberzeit +100%",
	Hit					= "Trefferchance Nah-/Fernkampf -50%",
	Crit				= "Kritischer Schaden +100%",
	Aggro				= "BEDROHUNG +100%",
	Mana				= "Zauber-/Fähigkeitskosten -50%",
	FrameTitle			= "Spektralreich",
	FrameLock			= "Sperre Fenster",
	FrameClassColor		= "Benutze Klassenfarben",
	FrameOrientation	= "Erweitere nach oben",
	FrameHide			= "Verberge Fenster",
	FrameClose			= "Schließen"
}

----------------
--  Brutallus --
----------------
L = DBM:GetModLocalization("Brutallus")

L:SetGeneralLocalization{
	name = "Brutallus"
}

L:SetMiscLocalization{
	Pull			= "Ah, mehr Lämmer zum Schlachten!",
}

--------------
--  Felmyst --
--------------
L = DBM:GetModLocalization("Felmyst")

L:SetGeneralLocalization{
	name = "Teufelsruch"
}

L:SetWarningLocalization{
	WarnPhase		= "%sphase"
}

L:SetTimerLocalization{
	TimerPhase		= "Nächste %sphase"
}

L:SetOptionLocalization{
	WarnPhase		= "Zeige Warnung für nächste Phase",
	TimerPhase		= "Zeige Zeit bis nächste Phase"
}

L:SetMiscLocalization{
	Air				= "Luft",
	Ground			= "Boden",
	AirPhase		= "Ich bin stärker als je zuvor!",
	Breath			= "%s holt tief Luft."
}

-----------------------
--  The Eredar Twins --
-----------------------
L = DBM:GetModLocalization("Twins")

L:SetGeneralLocalization{
	name = "Eredarzwillinge"
}

L:SetMiscLocalization{
	Nova			= "Sacrolash zielt mit Schattennova auf (.+)%.",
	Conflag			= "Alythess zielt mit Großbrand auf (.+)%.",
	Sacrolash		= "Lady Sacrolash",
	Alythess		= "Großhexenmeisterin Alythess"
}

------------
--  M'uru --
------------
L = DBM:GetModLocalization("Muru")

L:SetGeneralLocalization{
	name = "M'uru"
}

L:SetWarningLocalization{
	WarnHuman		= "Humanoide (%d)",
	WarnVoid		= "Leerenschildwache (%d)",
	WarnFiend		= "Finstere Scheusale erschienen"
}

L:SetTimerLocalization{
	TimerHuman		= "Nächste Humanoide (%s)",
	TimerVoid		= "Nächste Leerenschildwache (%s)",
	TimerPhase		= "Entropius"
}

L:SetOptionLocalization{
	WarnHuman		= "Zeige Warnung für Humanoide",
	WarnVoid		= "Zeige Warnung für Leerenschildwache",
	WarnFiend		= "Zeige Warnung für Finstere Scheusale in Phase 2",
	TimerHuman		= "Zeige Zeit bis Humanoide erscheinen",
	TimerVoid		= "Zeige Zeit bis Leerenschildwache erscheint",
	TimerPhase		= "Dauer des Übergangs in Phase 2 anzeigen"
}

L:SetMiscLocalization{
	Entropius		= "Entropius"
}

----------------
--  Kil'jeden --
----------------
L = DBM:GetModLocalization("Kil")

L:SetGeneralLocalization{
	name = "Kil'jaeden"
}

L:SetWarningLocalization{
	WarnDarkOrb		= "Schildkugeln erschienen",
	WarnBlueOrb		= "Drachenkugel bereit",
	SpecWarnDarkOrb	= "Schildkugeln erschienen!",
	SpecWarnBlueOrb	= "Drachenkugel bereit!"
}

L:SetTimerLocalization{
	TimerBlueOrb	= "Drachenkugelaktivierung"
}

L:SetOptionLocalization{
	WarnDarkOrb		= "Zeige Warnung für Schildkugeln",
	WarnBlueOrb		= "Zeige Warnung für Drachenkugeln",
	SpecWarnDarkOrb	= "Spezialwarnung für Schildkugeln",
	SpecWarnBlueOrb	= "Spezialwarnung für Drachenkugeln",
	TimerBlueOrb	= "Zeige Zeit bis Drachenkugeln bereit sind"
}

L:SetMiscLocalization{
	YellPull		= "Die Entbehrlichen sind dahin - so sei es! Jetzt werde ich dort erfolgreich sein, wo Sargeras versagt hat! Ich werde diese jämmerliche Welt ausbluten lassen und meinen Platz als wahrer Meister der Brennenden Legion einnehmen! Das Ende ist gekommen! Lasst uns diese Welt dem Erdboden gleichmachen!",
	OrbYell1		= "Ich werde die Kugeln mit meiner Macht erfüllen! Seid bereit!",--needs to be verified (wowhead-captured translation)
	OrbYell2		= "Eine weitere Kugel ist von meiner Macht erfüllt! Benutzt sie, schnell!",
	OrbYell3		= "Eine weitere Kugel ist bereit! Sputet Euch!",--needs to be verified (wowhead-captured translation)
	OrbYell4		= "Ich habe getan, was ich konnte! Die Macht liegt in Euren Händen!"

}

-----------------
--  Najentus  --
-----------------
L = DBM:GetModLocalization("Najentus")

L:SetGeneralLocalization{
	name = "Oberster Kriegsfürst Naj'entus"
}

L:SetMiscLocalization{
	HealthInfo	= "Gesundheitsinfo"
}

----------------
-- Supremus --
----------------
L = DBM:GetModLocalization("Supremus")

L:SetGeneralLocalization{
	name = "Supremus"
}

L:SetWarningLocalization{
	WarnPhase		= "%sphase"
}

L:SetTimerLocalization{
	TimerPhase		= "Nächste %sphase"
}

L:SetOptionLocalization{
	WarnPhase		= "Zeige Warnung für nächste Phase",
	TimerPhase		= "Zeige Zeit bis nächste Phase",
	KiteIcon		= "Setze Zeichen auf das verfolgte Ziel"
}

L:SetMiscLocalization{
	PhaseTank		= "schlägt wütend auf den Boden!",
	PhaseKite		= "Der Boden beginnt aufzubrechen!",
	ChangeTarget	= "wählt ein neues Ziel!",
	Kite			= "Kite",
	Tank			= "Tank"
}

-------------------------
--  Shape of Akama  --
-------------------------
L = DBM:GetModLocalization("Akama")

L:SetGeneralLocalization{
	name = "Akamas Schemen"
}

-------------------------
--  Teron Gorefiend  --
-------------------------
L = DBM:GetModLocalization("TeronGorefiend")

L:SetGeneralLocalization{
	name = "Teron Blutschatten"
}

L:SetTimerLocalization{
	TimerVengefulSpirit		= "Geist : %s"
}

L:SetOptionLocalization{
	TimerVengefulSpirit		= "Dauer der Rachsüchtigen Geister anzeigen"
}

----------------------------
--  Gurtogg Bloodboil  --
----------------------------
L = DBM:GetModLocalization("Bloodboil")

L:SetGeneralLocalization{
	name = "Gurtogg Siedeblut"
}

--------------------------
--  Essence Of Souls  --
--------------------------
L = DBM:GetModLocalization("Souls")

L:SetGeneralLocalization{
	name = "Reliquiar der Seelen"
}

L:SetWarningLocalization{
	WarnMana		= "Null Mana in 30 Sek"
}

L:SetTimerLocalization{
	TimerMana		= "Null Mana"
}

L:SetOptionLocalization{
	WarnMana		= "Zeige Warnung für 0 Mana in Phase 2",
	TimerMana		= "Zeige Zeit bis 0 Mana in Phase 2"
}

L:SetMiscLocalization{
	Suffering		= "Essenz des Leidens",
	Desire			= "Essenz der Begierde",
	Anger			= "Essenz des Zorns",
	Phase1End		= "Ich will nicht zurück!",
	Phase2End		= "Ich bin immer in Eurer Nähe!"
}

-----------------------
--  Mother Shahraz --
-----------------------
L = DBM:GetModLocalization("Shahraz")

L:SetGeneralLocalization{
	name = "Mutter Shahraz"
}

L:SetTimerLocalization{
	timerAura	= "%s"
}

L:SetOptionLocalization{
	timerAura	= "Dauer der Prismatischen Auren anzeigen"
}

----------------------
--  Illidari Council  --
----------------------
L = DBM:GetModLocalization("Council")

L:SetGeneralLocalization{
	name = "Der Rat der Illidari"
}

L:SetWarningLocalization{
	Immune			= "Malande - %s für 15 Sek"
}

L:SetOptionLocalization{
	Immune			= "Spezialwarnung, wenn Malande gegen magische oder körperliche Angriffe immun wird"
}

L:SetMiscLocalization{
	Gathios			= "Gathios der Zerschmetterer",
	Malande			= "Lady Malande",
	Zerevor			= "Hochnethermant Zerevor",
	Veras			= "Veras Schwarzschatten",
	Melee			= "Körperliche Immunität",
	Spell			= "Magieimmunität"
}

-------------------------
--  Illidan Stormrage --
-------------------------
L = DBM:GetModLocalization("Illidan")

L:SetGeneralLocalization{
	name = "Illidan Sturmgrimm"
}

L:SetWarningLocalization{
	WarnHuman		= "Normalform",
	WarnDemon		= "Dämonenform"
}

L:SetTimerLocalization{
	TimerNextHuman		= "Normalform",
	TimerNextDemon		= "Dämonenform"
}

L:SetOptionLocalization{
	WarnHuman		= "Zeige Warnung für Normalform",
	WarnDemon		= "Zeige Warnung für Dämonenform",
	TimerNextHuman	= "Zeige Zeit bis nächste Normalform",
	TimerNextDemon	= "Zeige Zeit bis nächste Dämonenform",
	RangeFrame		= "Zeige Abstandsfenster (10m) in Phase 3 und 4"
}

L:SetMiscLocalization{
	Pull			= "Akama. Euer falsches Spiel überrascht mich nicht. Ich hätte Euch und Eure missgestalteten Brüder schon vor langer Zeit abschlachten sollen.",
	Eyebeam			= "Blickt in die Augen des Verräters!",
	Demon			= "Erzittert vor der Macht des Dämonen!",
	Phase4			= "War's das schon, Sterbliche? Ist das alles, was Ihr zu bieten habt?",
}

------------------------
--  Rage Winterchill  --
------------------------
L = DBM:GetModLocalization("Rage")

L:SetGeneralLocalization{
	name = "Furor Winterfrost"
}

-----------------
--  Anetheron  --
-----------------
L = DBM:GetModLocalization("Anetheron")

L:SetGeneralLocalization{
	name = "Anetheron"
}

----------------
--  Kazrogal  --
----------------
L = DBM:GetModLocalization("Kazrogal")

L:SetGeneralLocalization{
	name = "Kaz'rogal"
}

---------------
--  Azgalor  --
---------------
L = DBM:GetModLocalization("Azgalor")

L:SetGeneralLocalization{
	name = "Azgalor"
}

------------------
--  Archimonde  --
------------------
L = DBM:GetModLocalization("Archimonde")

L:SetGeneralLocalization{
	name = "Archimonde"
}

----------------
-- WaveTimers --
----------------
L = DBM:GetModLocalization("HyjalWaveTimers")

L:SetGeneralLocalization{
	name 		= "Wellen (HdZ 3)"
}
L:SetWarningLocalization{
	WarnWave	= "%s",
}
L:SetTimerLocalization{
	TimerWave	= "Nächste Welle"
}
L:SetOptionLocalization{
	WarnWave		= "Warne, wenn eine neue Welle kommt",
	DetailedWave	= "Detaillierte Warnung, wenn eine neue Welle kommt (welche Mobs)",
	TimerWave		= "Zeige Zeit bis nächste Welle"
}
L:SetMiscLocalization{
	HyjalZoneName	= "Hyjalgipfel",
	Thrall			= "Thrall",
	Jaina			= "Lady Jaina Prachtmeer",
	GeneralBoss		= "Boss kommt",
	RageWinterchill	= "Furor Winterfrost kommt",
	Anetheron		= "Anetheron kommt",
	Kazrogal		= "Kaz'rogal kommt",
	Azgalor			= "Azgalor kommt",
	WarnWave_0		= "Welle %s/8",
	WarnWave_1		= "Welle %s/8 - %s %s",
	WarnWave_2		= "Welle %s/8 - %s %s und %s %s",
	WarnWave_3		= "Welle %s/8 - %s %s, %s %s und %s %s",
	WarnWave_4		= "Welle %s/8 - %s %s, %s %s, %s %s und %s %s",
	WarnWave_5		= "Welle %s/8 - %s %s, %s %s, %s %s, %s %s und %s %s",
	RageGossip		= "Meine Gefährten und ich werden Euch zur Seite stehen, Lady Prachtmeer.",
	AnetheronGossip	= "Was auch immer Archimonde gegen uns ins Feld schicken mag, wir sind bereit, Lady Prachtmeer.",
	KazrogalGossip	= "Ich werde Euch zur Seite stehen, Thrall!",
	AzgalorGossip	= "Wir haben nichts zu befürchten.",
	Ghoul			= "Ghule",
	Abomination		= "Monstrositäten",
	Necromancer		= "Nekromanten",
	Banshee			= "Banshees",
	Fiend			= "Gruftbestien",
	Gargoyle		= "Gargoyles",
	Wyrm			= "Frostwyrm",
	Stalker			= "Teufelspirscher",
	Infernal		= "Höllenbestien"
}

-----------
--  Alar --
-----------
L = DBM:GetModLocalization("Alar")

L:SetGeneralLocalization{
	name = "Al'ar"
}

L:SetTimerLocalization{
	NextPlatform	= "Max. Plattformdauer"
}

L:SetOptionLocalization{
	NextPlatform	= "Zeige Zeit bis Al'ar spätestens die Plattform wechselt<br/>(wechselt möglicherweise früher, aber fast nie später)"
}

------------------
--  Void Reaver --
------------------
L = DBM:GetModLocalization("VoidReaver")

L:SetGeneralLocalization{
	name = "Leerhäscher"
}

--------------------------------
--  High Astromancer Solarian --
--------------------------------
L = DBM:GetModLocalization("Solarian")

L:SetGeneralLocalization{
	name = "Hochastromantin Solarian"
}

L:SetWarningLocalization{
	WarnSplit		= "Verschwinden",
	WarnSplitSoon	= "Verschwinden in 5 Sekunden",
	WarnAgent		= "Agenten erscheinen",
	WarnPriest		= "Priester und Solarian erscheinen"

}

L:SetTimerLocalization{
	TimerSplit		= "Nächstes Verschwinden",
	TimerAgent		= "Agenten kommen",
	TimerPriest		= "Priester & Solarian kommen"
}

L:SetOptionLocalization{
	WarnSplit		= "Zeige Warnung für Verschwinden",
	WarnSplitSoon	= "Zeige Vorwarnung für Verschwinden",
	WarnAgent		= "Zeige Warnung, wenn Agenten erscheinen",
	WarnPriest		= "Zeige Warnung, wenn Priester und Solarian erscheinen",
	TimerSplit		= "Zeige Zeit bis Verschwinden",
	TimerAgent		= "Zeige Zeit bis Agenten erscheinen",
	TimerPriest		= "Zeige Zeit bis Priester und Solarian erscheinen"
}

L:SetMiscLocalization{
	YellSplit1		= "Ich werde Euch Euren Hochmut austreiben!",
	YellSplit2		= "Ihr seid eindeutig in der Unterzahl!",
	YellPhase2		= "Ich werde eins mit der Leere!"
}

---------------------------
--  Kael'thas Sunstrider --
---------------------------
L = DBM:GetModLocalization("KaelThas")

L:SetGeneralLocalization{
	name = "Kael'thas Sonnenwanderer"
}

L:SetWarningLocalization{
	WarnGaze		= "Blick auf >%s<",
	WarnMobDead		= "%s tot",
	WarnEgg			= "Phönixei erschienen",
	SpecWarnGaze	= "Blick auf DIR - Renn weg!",
	SpecWarnEgg		= "Phönixei erschienen - Wechsel Ziel!"
}

L:SetTimerLocalization{
	TimerPhase		= "Nächste Phase",
	TimerPhase1mob	= "%s",
	TimerNextGaze	= "Nächstes Blickziel",
	TimerRebirth	= "Phönix schlüpft"
}

L:SetOptionLocalization{
	WarnGaze		= "Zeige Warnung für Ziele von Thaladreds Blick",
	WarnMobDead		= "Zeige Warnung für getötete Waffen in Phase 2",
	WarnEgg			= "Zeige Warnung, wenn Phönixei erscheint",
	SpecWarnGaze	= "Spezialwarnung, wenn dich Thaladred anblickt",
	SpecWarnEgg		= "Spezialwarnung, wenn Phönixei erscheint",
	TimerPhase		= "Zeige Zeit bis nächste Phase",
	TimerPhase1mob	= "Zeige Zeit bis Berater in Phase 1 aktiv werden",
	TimerNextGaze	= "Zeige Zeit bis Thaladred ein neues Ziel anblickt",
	TimerRebirth	= "Zeige Zeit bis Phönix aus Phönixei schlüpft",
	GazeIcon		= "Zeichen auf Thaladreds Ziel setzen"
}

L:SetMiscLocalization{
	YellPhase2	= "Wie Ihr seht, habe ich viele Waffen in meinem Arsenal...",
	YellPhase3	= "Vielleicht habe ich Euch unterschätzt. Es wäre ungerecht, Euch gegen meine vier Berater gleichzeitig kämpfen zu lassen, aber... mein Volk wurde auch nie gerecht behandelt. Ich vergelte nur Gleiches mit Gleichem.",
	YellPhase4	= "Ach, manchmal muss man die Dinge selbst in die Hand nehmen. Balamore shanal!",
	YellPhase5	= "Ich bin nicht so weit gekommen, um jetzt noch aufgehalten zu werden! Die Zukunft, die ich geplant habe, wird nicht gefährdet werden. Jetzt bekommt Ihr wahre Macht zu spüren!",
	YellSang	= "Ihr habt gegen einige meiner besten Berater bestanden... aber niemand kommt gegen die Macht des Bluthammers an. Erzittert vor Lord Sanguinar!",
	YellCaper	= "Capernian wird dafür sorgen, dass Euer Aufenthalt hier nicht lange währt.",
	YellTelo	= "Gut gemacht. Ihr habt Euch würdig erwiesen, gegen meinen Meisteringenieur Telonicus anzutreten.",
	EmoteGaze	= "behält ([^%s]+) im Blickfeld!",
	Thaladred	= "Thaladred der Verfinsterer",
	Sanguinar	= "Lord Sanguinar",
	Capernian	= "Großastromantin Capernian",
	Telonicus	= "Meisteringenieur Telonicus",
	Bow			= "Netherbespannter Langbogen",
	Axe			= "Macht der Verwüstung",
	Mace		= "Kosmische Macht",
	Dagger		= "Klinge der Unendlichkeit",
	Sword		= "Warpschnitter",
	Shield		= "Phasenverschobenes Bollwerk",
	Staff		= "Stab der Auflösung",
	Egg			= "Phönixei"
}

---------------------------
--  Hydross the Unstable --
---------------------------
L = DBM:GetModLocalization("Hydross")

L:SetGeneralLocalization{
	name = "Hydross der Unstete"
}

L:SetWarningLocalization{
	WarnMark 		= "%s : %s",
	WarnPhase		= "%sphase",
	SpecWarnMark	= "%s : %s"
}

L:SetTimerLocalization{
	TimerMark	= "Nächstes %s : %s"
}

L:SetOptionLocalization{
	WarnMark		= "Zeige Warnung für Male",
	WarnPhase		= "Zeige Warnung für nächste Phase",
	SpecWarnMark	= "Spezialwarnung, wenn Schaden durch Male Debuff um 100% oder mehr erhöht ist",
	TimerMark		= "Zeige Zeit bis nächste Male"
}

L:SetMiscLocalization{
	Frost	= "Frost",
	Nature	= "Natur"
}

-----------------------
--  The Lurker Below --
-----------------------
L = DBM:GetModLocalization("LurkerBelow")

L:SetGeneralLocalization{
	name = "Das Grauen aus der Tiefe"
}

L:SetWarningLocalization{
	WarnSubmerge		= "Abtauchen",
	WarnEmerge			= "Auftauchen"
}

L:SetTimerLocalization{
	TimerSubmerge		= "Abtauchen CD",
	TimerEmerge			= "Auftauchen CD"
}

L:SetOptionLocalization{
	WarnSubmerge		= "Zeige Warnung für Abtauchen",
	WarnEmerge			= "Zeige Warnung für Auftauchen",
	TimerSubmerge		= "Abklingzeit von Abtauchen anzeigen",
	TimerEmerge			= "Abklingzeit von Auftauchen anzeigen"
}

--------------------------
--  Leotheras the Blind --
--------------------------
L = DBM:GetModLocalization("Leotheras")

L:SetGeneralLocalization{
	name = "Leotheras der Blinde"
}

L:SetWarningLocalization{
	WarnPhase		= "%s Phase"
}

L:SetTimerLocalization{
	TimerPhase	= "Nächste %s Phase"
}

L:SetOptionLocalization{
	WarnPhase		= "Zeige Warnung für nächste Phase",
	TimerPhase		= "Zeige Zeit bis nächste Phase"
}

L:SetMiscLocalization{
	Human		= "Humanoide",
	Demon		= "Dämonen",
	YellDemon	= "Hinfort, unbedeutender Elf%.%s*Ich habe jetzt die Kontrolle!",
	YellPhase2	= "Nein... nein! Was habt Ihr getan? Ich bin der Meister! Hört Ihr? Ich! Ich... aaaaah! Ich kann ihn... nicht aufhalten..."
}

-----------------------------
--  Fathom-Lord Karathress --
-----------------------------
L = DBM:GetModLocalization("Fathomlord")

L:SetGeneralLocalization{
	name = "Tiefenlord Karathress"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
}

L:SetMiscLocalization{
	Caribdis	= "Tiefenwächterin Caribdis",
	Tidalvess	= "Tiefenwächter Flutvess",
	Sharkkis	= "Tiefenwächter Haikis"
}

--------------------------
--  Morogrim Tidewalker --
--------------------------
L = DBM:GetModLocalization("Tidewalker")

L:SetGeneralLocalization{
	name = "Morogrim Gezeitenwandler"
}

L:SetWarningLocalization{
	SpecWarnMurlocs	= "Murlocs kommen!"
}

L:SetTimerLocalization{
	TimerMurlocs	= "Murlocs"
}

L:SetOptionLocalization{
	SpecWarnMurlocs	= "Spezialwarnung, wenn Murlocs erscheinen",
	TimerMurlocs	= "Zeige Zeit bis Murlocs erscheinen"
}

L:SetMiscLocalization{
}

-----------------
--  Lady Vashj --
-----------------
L = DBM:GetModLocalization("Vashj")

L:SetGeneralLocalization{
	name = "Lady Vashj"
}

L:SetWarningLocalization{
	WarnElemental		= "Besudelter Elementar bald (%s)",
	WarnStrider			= "Schreiter bald (%s)",
	WarnNaga			= "Naga bald (%s)",
	WarnShield			= "Schildgenerator %d/4 zerstört",
	WarnLoot			= ">%s< hat den Besudelten Kern",
	SpecWarnElemental	= "Besudelter Elementar - Ziel wechseln!"
}

L:SetTimerLocalization{
	TimerElementalActive	= "Elementar aktiv",
	TimerElemental			= "Elementar CD (%d)",
	TimerStrider			= "Nächster Schreiter (%d)",
	TimerNaga				= "Nächster Naga (%d)"
}

L:SetOptionLocalization{
	WarnElemental		= "Zeige Vorwarnung für nächsten Besudelter Elementar",
	WarnStrider			= "Zeige Vorwarnung für nächsten Schreiter",
	WarnNaga			= "Zeige Vorwarnung für nächsten Naga",
	WarnShield			= "Zeige Warnung für zerstörte Schildgeneratoren in Phase 2",
	WarnLoot			= "Spieler mit Besudelten Kern ansagen",
	TimerElementalActive	= "Zeige Zeit bis Besudelter Elementar verschwindet",
	TimerElemental		= "Abklingzeit von Besudelter Elementar anzeigen",
	TimerStrider		= "Zeige Zeit bis nächster Schreiter",
	TimerNaga			= "Zeige Zeit bis nächster Naga",
	SpecWarnElemental	= "Spezialwarnung, wenn Besudelter Elementar kommt",
	AutoChangeLootToFFA	= "Plündermodus in Phase 2 automatisch auf 'Jeder gegen jeden' einstellen"
}

L:SetMiscLocalization{
	DBM_VASHJ_YELL_PHASE2	= "Die Zeit ist gekommen! Lasst keinen am Leben!",
	DBM_VASHJ_YELL_PHASE3	= "Geht besser in Deckung!",
	LootMsg					= "([^%s]+).*Hitem:(%d+)"
}

--Maulgar
L = DBM:GetModLocalization("Maulgar")

L:SetGeneralLocalization{
	name = "Hochkönig Maulgar"
}


--Gruul the Dragonkiller
L = DBM:GetModLocalization("Gruul")

L:SetGeneralLocalization{
	name = "Gruul der Drachenschlächter"
}

L:SetWarningLocalization{
	WarnGrowth	= "%s (%d)"
}

L:SetOptionLocalization{
	WarnGrowth	= "Zeige Warnung für $spell:36300"
}


-- Magtheridon
L = DBM:GetModLocalization("Magtheridon")

L:SetGeneralLocalization{
	name = "Magtheridon"
}

L:SetTimerLocalization{
	timerP2	= "Phase 2"
}

L:SetOptionLocalization{
	timerP2	= "Zeige Zeit bis Phase 2 beginnt"
}

L:SetMiscLocalization{
	DBM_MAG_EMOTE_PULL		= "Die Fesseln von %s werden schwächer!",
	DBM_MAG_YELL_PHASE2		= "Ich... bin... frei!",
	DBM_MAG_YELL_PHASE3		= "Ich lasse mich nicht so leicht bezwingen! Lasst die Mauern dieses Kerkers erzittern... und einstürzen!"
}

if WOW_PROJECT_ID == (WOW_PROJECT_MAINLINE or 1) then return end--Anything below here is only needed for classic wrath or classic bc

---------------
--  Nalorakk --
---------------
L = DBM:GetModLocalization("Nalorakk")

L:SetGeneralLocalization{
	name = "Nalorakk"
}

L:SetWarningLocalization{
	WarnBear		= "Bärform",
	WarnBearSoon	= "Bärform in 5 Sek",
	WarnNormal		= "Normale Form",
	WarnNormalSoon	= "Normale Form in 5 Sek"
}

L:SetTimerLocalization{
	TimerBear		= "Bär",
	TimerNormal		= "Normale Form"
}

L:SetOptionLocalization{
	WarnBear		= "Show warning for Bear form",--Translate
	WarnBearSoon	= "Show pre-warning for Bear form",--Translate
	WarnNormal		= "Show warning for Normal form",--Translate
	WarnNormalSoon	= "Show pre-warning for Normal form",--Translate
	TimerBear		= "Show timer for Bear form",--Translate
	TimerNormal		= "Show timer for Normal form"--Translate
}

L:SetMiscLocalization{
	YellBear 	= "Ihr provoziert die Bestie, jetzt werdet Ihr sie kennenlernen!",
	YellNormal	= "Macht Platz für Nalorakk!"
}

---------------
--  Akil'zon --
---------------
L = DBM:GetModLocalization("Akilzon")

L:SetGeneralLocalization{
	name = "Akil'zon"
}

---------------
--  Jan'alai --
---------------
L = DBM:GetModLocalization("Janalai")

L:SetGeneralLocalization{
	name = "Jan'alai"
}

L:SetMiscLocalization{
	YellBomb	= "Jetzt sollt Ihr brennen!",
	YellAdds	= "Wo is' meine Brut? Was ist mit den Eiern?"
}

--------------
--  Halazzi --
--------------
L = DBM:GetModLocalization("Halazzi")

L:SetGeneralLocalization{
	name = "Halazzi"
}

L:SetWarningLocalization{
	WarnSpirit	= "Geist spawned",
	WarnNormal	= "Geist despawned"
}

L:SetOptionLocalization{
	WarnSpirit	= "Show warning for Spirit phase",--Translate
	WarnNormal	= "Show warning for Normal phase"--Translate
}

L:SetMiscLocalization{
	YellSpirit	= "Ich kämpfe mit wildem Geist...",
	YellNormal	= "Geist, zurück zu mir!"
}

--------------------------
--  Hex Lord Malacrass --
--------------------------
L = DBM:GetModLocalization("Malacrass")

L:SetGeneralLocalization{
	name = "Hexlord Malacrass"
}

L:SetMiscLocalization{
	YellPull	= "Der Schatten wird Euch verschlingen..."
}

--------------
--  Zul'jin --
--------------
L = DBM:GetModLocalization("ZulJin")

L:SetGeneralLocalization{
	name = "Zul'jin"
}

L:SetMiscLocalization{
	YellPhase2	= "Sagt 'Hallo' zu Bruder Bär...",
	YellPhase3	= "Niemand versteckt sich vor dem Adler!",
	YellPhase4	= "Lernt meine Brüder kennen: Reißzahn und Klaue!",
	YellPhase5	= "Was starrt Ihr in die Luft? Der Drachenfalke steht schon vor Euch!"
}
