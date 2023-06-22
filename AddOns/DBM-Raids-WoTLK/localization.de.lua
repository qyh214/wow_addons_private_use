if GetLocale() ~= "deDE" then return end
local L

----------------------------------
--  Archavon the Stone Watcher  --
----------------------------------
L = DBM:GetModLocalization("Archavon")

L:SetGeneralLocalization({
	name = "Archavon der Steinwächter"
})

L:SetWarningLocalization({
	WarningGrab	= "Archavon durchbohrt >%s<"
})

L:SetTimerLocalization({
	ArchavonEnrage	= "Berserker (Archavon)"
})

L:SetMiscLocalization({
	TankSwitch	= "%%s stürzt sich auf (%S+)!"
})

L:SetOptionLocalization({
	WarningGrab		= "Verkünde Ziele von $spell:58666",
	ArchavonEnrage	= "Zeige Zeit bis $spell:26662"
})

--------------------------------
--  Emalon the Storm Watcher  --
--------------------------------
L = DBM:GetModLocalization("Emalon")

L:SetGeneralLocalization{
	name = "Emalon der Sturmwächter"
}

L:SetTimerLocalization{
	timerMobOvercharge	= "Überladener Schlag",
	EmalonEnrage		= "Berserker (Emalon)"
}

L:SetOptionLocalization{
	timerMobOvercharge	= "Zeige Zeit bis $spell:64219 (erfolgt bei 10 Stapeln von $spell:64217)",
	EmalonEnrage		= "Zeige Zeit bis $spell:26662"
}

---------------------------------
--  Koralon the Flame Watcher  --
---------------------------------
L = DBM:GetModLocalization("Koralon")

L:SetGeneralLocalization{
	name = "Koralon der Flammenwächter"
}

L:SetTimerLocalization{
	KoralonEnrage	= "Berserker (Koralon)"
}

L:SetOptionLocalization{
	KoralonEnrage		= "Zeige Zeit bis $spell:26662"
}

L:SetMiscLocalization{
	Meteor	= "%s wirkt 'Meteorfäuste'!"
}

-------------------------------
--  Toravon the Ice Watcher  --
-------------------------------
L = DBM:GetModLocalization("Toravon")

L:SetGeneralLocalization{
	name = "Toravon der Eiswächter"
}

L:SetTimerLocalization{
	ToravonEnrage	= "Berserker (Toravon)"
}

L:SetMiscLocalization{
	ToravonEnrage	= "Zeige Zeit bis $spell:26662"
}

-------------------
--  Anub'Rekhan  --
-------------------
L = DBM:GetModLocalization("Anub'Rekhan")

L:SetGeneralLocalization({
	name = "Anub'Rekhan"
})

L:SetOptionLocalization({
	ArachnophobiaTimer	= "Zeige Timer für Erfolg 'Arachnophobie'"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "Arachnophobie",
	Pull1				= "Rennt! Das bringt das Blut in Wallung!",
	Pull2				= "Nur einmal kosten..." --needs to be verified (wowhead-captured translation)
})

----------------------------
--  Grand Widow Faerlina  --
----------------------------
L = DBM:GetModLocalization("Faerlina")

L:SetGeneralLocalization({
	name = "Großwitwe Faerlina"
})

L:SetWarningLocalization({
	WarningEmbraceExpire	= "Umarmung endet in 5 Sek",
	WarningEmbraceExpired	= "Umarmung Ende"
})

L:SetOptionLocalization({
	WarningEmbraceExpire	= "Zeige Vorwarnung für das Ende von $spell:28732",
	WarningEmbraceExpired	= "Zeige Warnung, wenn $spell:28732 endet"
})

L:SetMiscLocalization({
	Pull					= "Kniet nieder, Wurm!" --needs to be verified (wowhead-captured translation)
})

---------------
--  Maexxna  --
---------------
L = DBM:GetModLocalization("Maexxna")

L:SetGeneralLocalization({
	name = "Maexxna"
})

L:SetWarningLocalization({
	WarningSpidersSoon	= "Maexxnaspinnlinge in 5 Sek",
	WarningSpidersNow	= "Maexxnaspinnlinge erschienen"
})

L:SetTimerLocalization({
	TimerSpider	= "Nächste Maexxnaspinnlinge"
})

L:SetOptionLocalization({
	WarningSpidersSoon	= "Zeige Vorwarnung für Maexxnaspinnlinge",
	WarningSpidersNow	= "Zeige Warnung für Maexxnaspinnlinge",
	TimerSpider			= "Zeige Zeit bis nächste Maexxnaspinnlinge erscheinen"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "Arachnophobie"
})

------------------------------
--  Noth the Plaguebringer  --
------------------------------
L = DBM:GetModLocalization("Noth")

L:SetGeneralLocalization({
	name = "Noth der Seuchenfürst"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "Teleportiert",
	WarningTeleportSoon	= "Teleport in 20 Sek"
})

L:SetTimerLocalization({
	TimerTeleport		= "Teleport",
	TimerTeleportBack	= "Teleport zurück"
})

L:SetOptionLocalization({
	WarningTeleportNow	= "Zeige Warnung für Teleport",
	WarningTeleportSoon	= "Zeige Vorwarnung für Teleport",
	TimerTeleport		= "Zeige Zeit bis sich Noth auf den Balkon teleportiert",
	TimerTeleportBack	= "Zeige Zeit bis sich Noth zurück teleportiert"
})

L:SetMiscLocalization({
	Pull				= "Sterbt, Eindringling!",
	Adds				= "summons forth Skeletal Warriors!",--translate (trigger)
	AddsTwo				= "raises more skeletons!"--translate (trigger)
})

--------------------------
--  Heigan the Unclean  --
--------------------------
L = DBM:GetModLocalization("Heigan")

L:SetGeneralLocalization({
	name = "Heigan der Unreine"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "Teleportiert",
	WarningTeleportSoon	= "Teleport in %d Sek"
})

L:SetTimerLocalization({
	TimerTeleport	= "Teleport"
})

L:SetOptionLocalization({
	WarningTeleportNow	= "Zeige Warnung für Teleport",
	WarningTeleportSoon	= "Zeige Vorwarnung für Teleport",
	TimerTeleport		= "Zeige Zeit bis Teleport"
})

L:SetMiscLocalization({
	Pull				= "Ihr gehört mir..."
})

---------------
--  Loatheb  --
---------------
L = DBM:GetModLocalization("Loatheb")

L:SetGeneralLocalization({
	name = "Loatheb"
})

L:SetWarningLocalization({
	WarningHealSoon	= "Heilung in 3 Sek möglich",
	WarningHealNow	= "Jetzt heilen"
})

L:SetOptionLocalization({
	WarningHealSoon		= "Zeige Vorwarnung für 3-Sekunden-Heilfenster",
	WarningHealNow		= "Zeige Warnung für 3-Sekunden-Heilfenster"
})

-----------------
--  Patchwerk  --
-----------------
L = DBM:GetModLocalization("Patchwerk")

L:SetGeneralLocalization({
	name = "Flickwerk"
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	yell1			= "Flickwerk spielen möchte!",
	yell2			= "Kel’Thuzad macht Flickwerk zu seinem Abgesandten des Kriegs!"
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
	Yell	= "Stalagg zerquetschen!",
	Emote	= "%s überlädt!",
	Emote2	= "Teslaspule überlädt!",
	Boss1	= "Feugen",
	Boss2	= "Stalagg",
	Charge1 = "negativ",
	Charge2 = "positiv"
})

L:SetOptionLocalization({
	WarningChargeChanged	= "Spezialwarnung, wenn deine Polarität gewechselt hat",
	WarningChargeNotChanged	= "Spezialwarnung, wenn deine Polarität nicht gewechselt hat",
	AirowEnabled			= "Zeige Pfeile (normale \"2-Camps\"-Strategie)",
	ArrowsRightLeft			= "Zeige Links-/Rechtspfeil für die \"4-Camps\"-Strategie<br/>(Linkspfeil bei Polaritätsänderung, Rechtspfeil bei keiner Änderung)",
	ArrowsInverse			= "Umgedrehte \"4-Camps\"-Strategie<br/>(Rechtspfeil bei Polaritätsänderung, Linkspfeil bei keiner Änderung)"
})

L:SetWarningLocalization({
	WarningChargeChanged	= "Polarität geändert zu %s",
	WarningChargeNotChanged	= "Polarität hat sich nicht geändert"
})

----------------------------
--  Instructor Razuvious  --
----------------------------
L = DBM:GetModLocalization("Razuvious")

L:SetGeneralLocalization({
	name = "Instrukteur Razuvious"
})

L:SetMiscLocalization({
	Yell1 = "Lasst keine Gnade walten!",
	Yell2 = "Die Zeit des Übens ist vorbei! Zeigt mir, was ihr gelernt habt!",
	Yell3 = "Befolgt meine Befehle!",
	Yell4 = "Streckt sie nieder... oder habt ihr ein Problem damit?"
})

L:SetOptionLocalization({
	WarningShieldWallSoon	= "Zeige Vorwarnung, wenn $spell:29061 endet"
})

L:SetWarningLocalization({
	WarningShieldWallSoon	= "Knochenbarriere endet in 5 Sekunden"
})

----------------------------
--  Gothik the Harvester  --
----------------------------
L = DBM:GetModLocalization("Gothik")

L:SetGeneralLocalization({
	name = "Gothik der Ernter"
})

L:SetOptionLocalization({
	TimerWave			= "Zeige Zeit bis nächste Welle",
	TimerPhase2			= "Zeige Zeit bis Phase 2",
	WarningWaveSoon		= "Warne, wenn bald eine neue Welle kommt",
	WarningWaveSpawned	= "Warne, wenn eine neue Welle kommt",
	WarningRiderDown	= "Zeige Warnung, wenn ein Unerbittlicher Reiter stirbt",
	WarningKnightDown	= "Zeige Warnung, wenn ein Unerbittlicher Todesritter stirbt"
})

L:SetTimerLocalization({
	TimerWave	= "Welle %d",
	TimerPhase2	= "Phase 2"
})

L:SetWarningLocalization({
	WarningWaveSoon		= "Welle %d: %s in 3 Sek",
	WarningWaveSpawned	= "Welle %d: %s erschienen",
	WarningRiderDown	= "Reiter tot",
	WarningKnightDown	= "Ritter tot",
	WarningPhase2		= "Phase 2"
})

L:SetMiscLocalization({
	yell			= "Ihr Narren habt euren eigenen Untergang heraufbeschworen.",
	WarningWave1	= "%d %s",
	WarningWave2	= "%d %s und %d %s",
	WarningWave3	= "%d %s, %d %s und %d %s",
	Trainee			= "Lehrlinge",
	Knight			= "Ritter",
	Rider			= "Reiter"
})

---------------------
--  Four Horsemen  --
---------------------
L = DBM:GetModLocalization("Horsemen")

L:SetGeneralLocalization({
	name = "Die vier Reiter"
})

L:SetOptionLocalization({
	WarningMarkSoon				= "Zeige Vorwarnung für Mal",
	WarningMarkNow				= "Zeige Warnung für Mal",
	SpecialWarningMarkOnPlayer	= "Spezialwarnung, wenn sich ein Mal mehr als 4-mal auf dir stapelt"
})

L:SetTimerLocalization({
})

L:SetWarningLocalization({
	WarningMarkSoon				= "Mal %d in 3 Sekunden",
	WarningMarkNow				= "Mal %d",
	SpecialWarningMarkOnPlayer	= "%s: %s"
})

L:SetMiscLocalization({
	Korthazz	= "Than Korth'azz",
	Rivendare	= "Baron Totenschwur",
	Blaumeux	= "Lady Blaumeux",
	Zeliek		= "Sir Zeliek"
})

-----------------
--  Sapphiron  --
-----------------
L = DBM:GetModLocalization("Sapphiron")

L:SetGeneralLocalization({
	name = "Saphiron"
})

L:SetOptionLocalization({
	WarningAirPhaseSoon	= "Zeige Vorwarnung, wenn Saphiron bald abhebt",
	WarningAirPhaseNow	= "Zeige Warnung, wenn Saphiron abhebt",
	WarningLanded		= "Zeige Warnung, wenn Saphiron landet",
	TimerAir			= "Zeige Zeit bis nächste Luftphase",
	TimerLanding		= "Zeige Zeit bis nächste Bodenphase"
})

L:SetMiscLocalization({
	EmoteBreath			= "%s holt tief Luft."
})

L:SetWarningLocalization({
	WarningAirPhaseSoon	= "Luftphase in 10 Sek",
	WarningAirPhaseNow	= "Luftphase",
	WarningLanded		= "Bodenphase"
})

L:SetTimerLocalization({
	TimerAir		= "Nächste Luftphase",
	TimerLanding	= "Nächste Bodenphase"
})

------------------
--  Kel'Thuzad  --
------------------

L = DBM:GetModLocalization("Kel'Thuzad")

L:SetGeneralLocalization({
	name = "Kel'Thuzad"
})

L:SetOptionLocalization({
	TimerPhase2			= "Zeige Zeit bis Phase 2",
	specwarnP2Soon		= "Spezialwarnung 10 Sekunden bevor Kel'Thuzad angreift",
	warnAddsSoon		= "Zeige Vorwarnung für Wächter von Eiskrone"
})

L:SetMiscLocalization({
	Yell = "Lakaien, Diener, Soldaten der eisigen Finsternis! Folgt dem Ruf von Kel'Thuzad!"
})

L:SetWarningLocalization({
	specwarnP2Soon	= "Kel'Thuzad greift in 10 Sekunden an",
	warnAddsSoon	= "Wächter von Eiskrone bald"
})

L:SetTimerLocalization({
	TimerPhase2	= "Phase 2"
})

----------------------------
--  The Obsidian Sanctum  --
----------------------------
--  Shadron  --
---------------
L = DBM:GetModLocalization("Shadron")

L:SetGeneralLocalization({
	name = "Shadron"
})

----------------
--  Tenebron  --
----------------
L = DBM:GetModLocalization("Tenebron")

L:SetGeneralLocalization({
	name = "Tenebron"
})

----------------
--  Vesperon  --
----------------
L = DBM:GetModLocalization("Vesperon")

L:SetGeneralLocalization({
	name = "Vesperon"
})

------------------
--  Sartharion  --
------------------
L = DBM:GetModLocalization("Sartharion")

L:SetGeneralLocalization({
	name = "Sartharion"
})

L:SetWarningLocalization({
	WarningTenebron			= "Tenebron kommt",
	WarningShadron			= "Shadron kommt",
	WarningVesperon			= "Vesperon kommt",
	WarningFireWall			= "Feuerwand",
	WarningVesperonPortal	= "Vesperons Portal",
	WarningTenebronPortal	= "Tenebrons Portal",
	WarningShadronPortal	= "Shadrons Portal"
})

L:SetTimerLocalization({
	TimerTenebron	= "Tenebron kommt",
	TimerShadron	= "Shadron kommt",
	TimerVesperon	= "Vesperon kommt"
})

L:SetOptionLocalization({
	AnnounceFails			= "Verkünde Spieler im SZ-Chat, die bei Feuerwand und Schattenspalt scheitern (benötigt aktivierte Mitteilungen und Leiter-/Assistentenstatus)",
	TimerTenebron			= "Zeige Zeit bis Tenebron in den Kampf eingreift",
	TimerShadron			= "Zeige Zeit bis Shadron in den Kampf eingreift",
	TimerVesperon			= "Zeige Zeit bis Vesperon in den Kampf eingreift",
	WarningFireWall			= "Spezialwarnung für Feuerwand",
	WarningTenebron			= "Verkünde das Eingreifen von Tenebron in den Kampf",
	WarningShadron			= "Verkünde das Eingreifen von Shadron in den Kampf",
	WarningVesperon			= "Verkünde das Eingreifen von Vesperon in den Kampf",
	WarningTenebronPortal	= "Spezialwarnung für Tenebrons Portal",
	WarningShadronPortal	= "Spezialwarnung für Shadrons Portal",
	WarningVesperonPortal	= "Spezialwarnung für Vesperons Portal"
})

L:SetMiscLocalization({
	Wall			= "Die Lava um %s brodelt!",
	Portal			= "%s beginnt, ein Portal des Zwielichts zu öffnen!",
	NameTenebron	= "Tenebron",
	NameShadron		= "Shadron",
	NameVesperon	= "Vesperon",
	FireWallOn		= "Feuerwand: %s",
	VoidZoneOn		= "Schattenspalt: %s",
	VoidZones		= "Fehler bei Schattenspalt (dieser Versuch): %s",
	FireWalls		= "Fehler bei Feuerwand (dieser Versuch): %s"
})

---------------
--  Malygos  --
---------------
L = DBM:GetModLocalization("Malygos")

L:SetGeneralLocalization({
	name = "Malygos"
})

L:SetMiscLocalization({
	YellPull	= "Meine Geduld ist am Ende. Ich werde mich eurer entledigen!",
	EmoteSpark	= "Ein Energiefunke bildet sich aus einem nahegelegenen Graben!",
	YellPhase2	= "Ich hatte gehofft, eure Leben schnell zu beenden, doch ihr zeigt euch... hartnäckiger als erwartet.",
	YellBreath	= "Solange ich atme, werdet ihr nicht obsiegen!",
	YellPhase3	= "Eure Wohltäter sind eingetroffen, doch sie kommen zu spät! Die hier gespeicherten Energien reichen aus, die Welt zehnmal zu zerstören. Was, denkt ihr, werden sie mit euch machen?"
})

-----------------------
--  Flame Leviathan  --
-----------------------
L = DBM:GetModLocalization("FlameLeviathan")

L:SetGeneralLocalization{
	name = "Flammenleviathan"
}

L:SetMiscLocalization{
	YellPull	= "Feindeinheiten erkannt. Bedrohungsbewertung aktiv. Hauptziel erfasst. Neubewertung in T minus 30 Sekunden.",
	Emote		= "%%s verfolgt (%S+)%."
}

L:SetWarningLocalization{
	PursueWarn				= "Verfolgt >%s<",
	warnNextPursueSoon		= "Zielwechsel in 5 Sekunden",
	SpecialPursueWarnYou	= "Du wirst verfolgt - Lauf weg!",
	warnWardofLife			= "Zauberschutz des Lebens erscheint"
}

L:SetOptionLocalization{
	SpecialPursueWarnYou	= "Spezialwarnung, wenn du $spell:62374 wirst",
	PursueWarn				= "Verkünde Ziele von $spell:62374",
	warnNextPursueSoon		= "Zeige Vorwarnung für nächstes $spell:62374",
	warnWardofLife			= "Spezialwarnung, wenn Zauberschutz des Lebens erscheint"
}

--------------------------------
--  Ignis the Furnace Master  --
--------------------------------
L = DBM:GetModLocalization("Ignis")

L:SetGeneralLocalization{
	name = "Ignis, Meister des Eisenwerks"
}

------------------
--  Razorscale  --
------------------
L = DBM:GetModLocalization("Razorscale")

L:SetGeneralLocalization{
	name = "Klingenschuppe"
}

L:SetWarningLocalization{
	warnTurretsReadySoon		= "Letzes Geschütz bereit in 20 Sekunden",
	warnTurretsReady			= "Letzes Geschütz bereit"
}

L:SetTimerLocalization{
	timerTurret1	= "Geschütz 1",
	timerTurret2	= "Geschütz 2",
	timerTurret3	= "Geschütz 3",
	timerTurret4	= "Geschütz 4",
	timerGrounded	= "Bodenphase"
}

L:SetOptionLocalization{
	warnTurretsReadySoon		= "Zeige Vorwarnung für Fertigstellung des letzten Harpunengeschützes",
	warnTurretsReady			= "Zeige Warnung bei Fertigstellung des letzten Harpunengeschützes",
	timerTurret1				= "Zeige Zeit bis erstes Harpunengeschütz einsatzbereit ist",
	timerTurret2				= "Zeige Zeit bis zweites Harpunengeschütz einsatzbereit ist",
	timerTurret3				= "Zeige Zeit bis drittes Harpunengeschütz einsatzbereit ist (25 Spieler)",
	timerTurret4				= "Zeige Zeit bis viertes Harpunengeschütz einsatzbereit ist (25 Spieler)",
	timerGrounded			    = "Dauer der Bodenphase anzeigen"
}

L:SetMiscLocalization{
	YellAir				= "Gebt uns einen Moment, damit wir uns auf den Bau der Geschütze vorbereiten können.",
	YellAir2			= "Feuer einstellen! Lasst uns diese Geschütze reparieren!",
	YellGround			= "Beeilt Euch! Sie wird nicht lange am Boden bleiben!",
	EmotePhase2			= "ist dauerhaft an den Boden gebunden!"
}

----------------------------
--  XT-002 Deconstructor  --
----------------------------
L = DBM:GetModLocalization("XT002")

L:SetGeneralLocalization{
	name = "XT-002 Dekonstruktor"
}

--------------------
--  Iron Council  --
--------------------
L = DBM:GetModLocalization("IronCouncil")

L:SetGeneralLocalization{
	name = "Die Versammlung des Eisens"
}

L:SetOptionLocalization{
	AlwaysWarnOnOverload		= "Warne immer bei $spell:63481 (sonst nur wenn Sturmrufer Brundir im Ziel)"
}

L:SetMiscLocalization{
	Steelbreaker		= "Stahlbrecher",
	RunemasterMolgeim	= "Runenmeister Molgeim",
	StormcallerBrundir 	= "Sturmrufer Brundir"
}

----------------------------
--  Algalon the Observer  --
----------------------------
L = DBM:GetModLocalization("Algalon")

L:SetGeneralLocalization{
	name = "Algalon der Beobachter"
}

L:SetTimerLocalization{
	NextCollapsingStar		= "Nächste Kollabierende Sterne",
	TimerCombatStart		= "Kampfbeginn"
}

L:SetWarningLocalization{
	WarnPhase2Soon			= "Phase 2 bald",
	warnStarLow				= "Kollabierender Stern stirbt bald"
}

L:SetOptionLocalization{
	WarningPhasePunch		= "Verkünde Ziele von $spell:64412",
	NextCollapsingStar		= "Zeige Zeit bis nächste Kollabierende Sterne erscheinen",
	TimerCombatStart		= "Zeige Zeit bis Kampfbeginn",
	WarnPhase2Soon			= "Zeige Vorwarnung für Phase 2 (bei ~23%)",
	warnStarLow				= "Spezialwarnung, wenn ein Kollabierender Stern bald stirbt (bei ~25%)"
}

L:SetMiscLocalization{
	HealthInfo				= "Heilen für Sterne",
	YellPull				= "Euer Handeln ist unlogisch. Alle Möglichkeiten dieser Begegnung wurden berechnet. Das Pantheon wird die Nachricht des Beobachters erhalten, ungeachtet des Ausgangs.",
	YellKill				= "Ich sah Welten umhüllt von den Flammen der Schöpfer, sah ohne einen Hauch von Trauer ihre Bewohner vergehen. Ganze Planetensysteme geboren und vernichtet, während Eure sterblichen Herzen nur einmal schlagen. Doch immer war mein Herz kalt... ohne Mitgefühl. Ich - habe - nichts - gefühlt. Millionen, Milliarden Leben verschwendet. Trugen sie alle dieselbe Beharrlichkeit in sich, wie Ihr? Liebten sie alle das Leben so sehr, wie Ihr es tut?",
	Emote_CollapsingStar	= "%s beginnt damit, kollabierende Sterne zu beschwören!",
	Phase2					= "Erblicket die Instrumente der Schöpfung!",
	FirstPull				= "Seht Eure Welt durch meine Augen: Ein Universum so gewaltig - grenzenlos - unbegreiflich selbst für die Klügsten unter Euch."
}

----------------
--  Kologarn  --
----------------
L = DBM:GetModLocalization("Kologarn")

L:SetGeneralLocalization{
	name = "Kologarn"
}

L:SetTimerLocalization{
	timerLeftArm		= "Nachwachsen linker Arm",
	timerRightArm		= "Nachwachsen rechter Arm",
	achievementDisarmed	= "Zeit für Arm-ab-Erfolg"
}

L:SetOptionLocalization{
	timerLeftArm			= "Zeige Zeit bis der linke Arm nachwächst",
	timerRightArm			= "Zeige Zeit bis der rechte Arm nachwächst",
	achievementDisarmed		= "Zeige Timer für Erfolg 'Arm dran, weil Arm ab'"
}

L:SetMiscLocalization{
	Yell_Trigger_arm_left	= "Das ist nur ein Kratzer!",
	Yell_Trigger_arm_right	= "Ist nur 'ne Fleischwunde!",
	Health_Body				= "Kologarn",
	Health_Right_Arm		= "Rechter Arm",
	Health_Left_Arm			= "Linker Arm",
	FocusedEyebeam			= "%s fokussiert seinen Blick auf Euch!"
}

---------------
--  Auriaya  --
---------------
L = DBM:GetModLocalization("Auriaya")

L:SetGeneralLocalization{
	name = "Auriaya"
}

L:SetMiscLocalization{
	Defender = "Wilder Verteidiger (%d)",
	YellPull = "In manche Dinge mischt man sich besser nicht ein!"
}

L:SetTimerLocalization{
	timerDefender	= "Wilder Verteidiger wird aktiviert"
}

L:SetWarningLocalization{
	WarnCatDied		= "Wilder Verteidiger tot (%d Leben übrig)",
	WarnCatDiedOne	= "Wilder Verteidiger tot (1 Leben übrig)"
}

L:SetOptionLocalization{
	WarnCatDied		= "Zeige Warnung, wenn der Wilde Verteidiger stirbt",
	WarnCatDiedOne	= "Zeige Warnung, wenn der Wilde Verteidiger nur noch 1 Leben übrig hat",
	timerDefender	= "Zeige Zeit bis zur Aktivierung des Wilden Verteidigers"
}

-------------
--  Hodir  --
-------------
L = DBM:GetModLocalization("Hodir")

L:SetGeneralLocalization{
	name = "Hodir"
}

L:SetMiscLocalization{
	Pull		= "Für Euer Eindringen werdet Ihr bezahlen!",
	YellKill	= "Ich... bin von ihm befreit... endlich."
}

--------------
--  Thorim  --
--------------
L = DBM:GetModLocalization("Thorim")

L:SetGeneralLocalization{
	name = "Thorim"
}

L:SetTimerLocalization{
	TimerHardmode	= "Hard Mode"
}

L:SetOptionLocalization{
	TimerHardmode	= "Zeige Timer für Hard Mode",
	AnnounceFails	= "Verkünde Spieler im Schlachtzugchat, die bei $spell:62466 scheitern (benötigt aktivierte Mitteilungen und Leiter-/Assistentenstatus)"
}

L:SetMiscLocalization{
	YellPhase1	= " Eindringlinge! Ihr Sterblichen, die Ihr es wagt, Euch in mein Vergnügen einzumischen, werdet... Wartet... Ihr...",
	YellPhase2	= "Ihr unverschämtes Geschmeiß! Ihr wagt es, mich in meinem Refugium herauszufordern? Ich werde Euch eigenhändig zerschmettern!",
	YellKill	= "Senkt Eure Waffen! Ich ergebe mich!",
	ChargeOn	= "Blitzladung: %s",
	Charge		= "Fehler bei Blitzladung (dieser Versuch): %s"
}

-------------
--  Freya  --
-------------
L = DBM:GetModLocalization("Freya")

L:SetGeneralLocalization{
	name = "Freya"
}

L:SetMiscLocalization{
	SpawnYell          = "Helft mir, Kinder!",
	WaterSpirit        = "Uralter Wassergeist",
	Snaplasher         = "Knallpeitscher",
	StormLasher        = "Sturmpeitscher",
	YellKill           = "Seine Macht über mich beginnt zu schwinden. Endlich kann ich wieder klar sehen. Ich danke Euch, Helden."
}

L:SetWarningLocalization{
	WarnSimulKill	= "Erster Elementar tot - Wiederbelebung in ~12 Sekunden"
}

L:SetTimerLocalization{
	TimerSimulKill	= "Wiederbelebung"
}

L:SetOptionLocalization{
	WarnSimulKill	= "Verkünde Tod des ersten Elementars",
	TimerSimulKill	= "Zeige Zeit bis zur Wiederbelebung der Elementare"
}

----------------------
--  Freya's Elders  --
----------------------
L = DBM:GetModLocalization("Freya_Elders")

L:SetGeneralLocalization{
	name = "Freyas Älteste"
}

---------------
--  Mimiron  --
---------------
L = DBM:GetModLocalization("Mimiron")

L:SetGeneralLocalization{
	name = "Mimiron"
}

L:SetWarningLocalization{
	MagneticCore		= ">%s< hat den Magnetischen Kern",
	WarnBombSpawn		= "Bombenbot erschienen"
}

L:SetTimerLocalization{
	TimerHardmode	= "Hard Mode - Selbstzerstörung",
	TimeToPhase2	= "Phase 2",
	TimeToPhase3	= "Phase 3",
	TimeToPhase4	= "Phase 4"
}

L:SetOptionLocalization{
	TimeToPhase2			= "Zeige Zeit bis Phase 2",
	TimeToPhase3			= "Zeige Zeit bis Phase 3",
	TimeToPhase4			= "Zeige Zeit bis Phase 4",
	MagneticCore			= "Verkünde Spieler, die Magnetische Kerne plündern",
	WarnBombSpawn			= "Zeige Warnung für Bombenbot",
	TimerHardmode			= "Zeige Timer für Hard Mode"
}

L:SetMiscLocalization{
	MobPhase1		= "Leviathan Mk II",
	MobPhase2		= "VX-001",
	MobPhase3		= "Luftkommandoeinheit",
	YellPull		= "Wir haben nicht viel Zeit, Freunde! Ihr werdet mir dabei helfen, meine neueste und großartigste Kreation zu testen. Bevor Ihr nun Eure Meinung ändert, denkt daran, dass Ihr mir etwas schuldig seid, nach dem Unfug, den Ihr mit dem XT-002 angestellt habt.",
	YellHardPull	= "Warum habt Ihr das denn jetzt gemacht? Habt Ihr das Schild nicht gesehen, auf dem steht \"DIESEN KNOPF NICHT DRÜCKEN!\"? Wie sollen wir die Tests abschließen, solange der Selbstzerstörungsmechanismus aktiv ist?",
	YellPhase2		= "WUNDERBAR! Das sind Ergebnisse nach meinem Geschmack! Integrität der Hülle bei 98,9 Prozent! So gut wie keine Dellen! Und weiter geht's.",
	YellPhase3		= "Danke Euch, Freunde! Eure Anstrengungen haben fantastische Daten geliefert! So, wo habe ich noch gleich... Ah, hier ist…",
	YellPhase4		= "Vorversuchsphase abgeschlossen. Jetzt kommt der eigentliche Test!"
}

---------------------
--  General Vezax  --
---------------------
L = DBM:GetModLocalization("GeneralVezax")

L:SetGeneralLocalization{
	name = "General Vezax"
}

L:SetTimerLocalization{
	hardmodeSpawn = "Saronitanimus erscheint"
}

L:SetOptionLocalization{
	hardmodeSpawn					= "Zeige Zeit bis zum Erscheinen des Saronitanimus (Hard Mode)"
}

L:SetMiscLocalization{
	EmoteSaroniteVapors	= "Eine Wolke Saronitdämpfe bildet sich in der Nähe!"
}

------------------
--  Yogg-Saron  --
------------------
L = DBM:GetModLocalization("YoggSaron")

L:SetGeneralLocalization{
	name = "Yogg-Saron"
}

L:SetWarningLocalization{
	WarningGuardianSpawned 			= "Wächter %d erschienen",
	WarningCrusherTentacleSpawned	= "Schmettertentakel erschienen",
	WarningSanity 					= "%d Geistige Gesundheit übrig",
	SpecWarnSanity 					= "%d Geistige Gesundheit übrig",
	SpecWarnMadnessOutNow			= "Wahnsinn hervorrufen - LAUF RAUS!",
	WarnBrainPortalSoon				= "Gehirnportale in 3 Sek",
	specWarnBrainPortalSoon			= "Gehirnportale bald"
}

L:SetTimerLocalization{
	NextPortal	= "Gehirnportale"
}

L:SetOptionLocalization{
	WarningGuardianSpawned			= "Zeige Warnung, wenn ein Wächter des Yogg-Saron erscheint",
	WarningCrusherTentacleSpawned	= "Zeige Warnung, wenn ein Schmettertentakel erscheint",
	WarningSanity					= "Zeige Warnung, wenn deine $spell:63050 niedrig ist",
	SpecWarnSanity					= "Spezialwarnung, wenn deine $spell:63050 sehr niedrig ist",
	WarnBrainPortalSoon				= "Zeige Vorwarnung für Gehirnportale",
	SpecWarnMadnessOutNow			= "Spezialwarnung kurz bevor $spell:64059 zu Ende gewirkt wird",
	specWarnBrainPortalSoon			= "Spezialwarnung für nächste Gehirnportale",
	NextPortal						= "Zeige Zeit bis nächste Gehirnportale"
}

L:SetMiscLocalization{
	YellPull 			= "Bald ist die Zeit gekommen, dem Untier den Kopf abzuschlagen! Konzentriert Euren Zorn und Euren Hass auf seine Diener!",
	YellPhase2	 		= "Ich bin der strahlende Traum.",
	Sara 				= "Sara"
}

--------------
--  Onyxia  --
--------------
L = DBM:GetModLocalization("Onyxia")

L:SetGeneralLocalization{
	name = "Onyxia"
}

L:SetWarningLocalization{
	WarnWhelpsSoon		= "Welpen erscheinen bald"
}

L:SetTimerLocalization{
	TimerWhelps	= "Welpen erscheinen"
}

L:SetOptionLocalization{
	TimerWhelps				= "Zeige Zeit bis Welpen erscheinen",
	WarnWhelpsSoon			= "Zeige Vorwarnung für Erscheinen der Welpen",
	SoundWTF3				= "Spiele witzige Sounds eines legendären Classic-Onyxia-Schlachtzuges"
}

L:SetMiscLocalization{
	YellPull = "Was für ein Zufall. Normalerweise muss ich meinen Unterschlupf verlassen, um etwas zu essen.",
	YellP2 = "Diese sinnlose Anstrengung langweilt mich. Ich werde Euch alle von oben verbrennen!",
	YellP3 = "Mir scheint, dass Ihr noch eine Lektion braucht, sterbliche Wesen!"
}

------------------------
--  Northrend Beasts  --
------------------------
L = DBM:GetModLocalization("NorthrendBeasts")

L:SetGeneralLocalization{
	name = "Bestien von Nordend"
}

L:SetWarningLocalization{
	WarningSnobold		= "Schneeboldvasall erschienen auf >%s<"
}

L:SetTimerLocalization{
	TimerNextBoss		= "Nächster Boss",
	TimerEmerge			= "Auftauchen",
	TimerSubmerge		= "Abtauchen"
}

L:SetOptionLocalization{
	WarningSnobold		= "Zeige Warnung, wenn ein Schneeboldvasall erscheint",
	ClearIconsOnIceHowl	= "Entferne alle Zeichen vor dem Trampeln",
	TimerNextBoss		= "Zeige Zeit bis zum Erscheinen des nächsten Bosses",
	TimerEmerge			= "Zeige Zeit bis Auftauchen",
	TimerSubmerge		= "Zeige Zeit bis Abtauchen",
	IcehowlArrow		= "Zeige DBM-Pfeil, wenn Eisheuler jemand in deiner Nähe niedertrampeln will"
}

L:SetMiscLocalization{
	Charge		= "^%%s sieht (%S+) zornig an und lässt einen gewaltigen Schrei ertönen!",
	CombatStart	= "Er kommt aus den tiefsten, dunkelsten Höhlen der Sturmgipfel - Gormok der Pfähler! Voran, Helden!",
	Phase2		= "Stählt Euch, Helden, denn die Zwillingsschrecken Ätzschlund und Schreckensmaul erscheinen in der Arena!",
	Phase3		= "Mit der Ankündigung unseres nächsten Kämpfers gefriert die Luft selbst: Eisheuler! Tötet oder werdet getötet, Champions!",
	Gormok		= "Gormok der Pfähler",
	Acidmaw		= "Ätzschlund",
	Dreadscale	= "Schreckensmaul",
	Icehowl		= "Eisheuler"
}

---------------------
--  Lord Jaraxxus  --
---------------------
L = DBM:GetModLocalization("Jaraxxus")

L:SetGeneralLocalization{
	name = "Lord Jaraxxus"
}

L:SetOptionLocalization{
	IncinerateShieldFrame		= "Zeige Lebensanzeige mit einem Balken für Fleisch einäschern"
}

L:SetMiscLocalization{
	IncinerateTarget	= "Fleisch einäschern: %s",
	FirstPull	= "Großhexenmeister Wilfred Zischknall wird Eure nächste Herausforderung beschwören. Harrt seiner Ankunft."
}

-------------------------
--  Faction Champions  --
-------------------------
L = DBM:GetModLocalization("Champions")

L:SetGeneralLocalization{
	name = "Fraktionschampions"
}

L:SetMiscLocalization{
	AllianceVictory    = "EHRE DER ALLIANZ!",
	HordeVictory       = "Das ist nur ein Vorgeschmack auf die Zukunft. FÜR DIE HORDE!"
}

---------------------
--  Val'kyr Twins  --
---------------------
L = DBM:GetModLocalization("ValkTwins")

L:SetGeneralLocalization{
	name = "Zwillingsval'kyr"
}

L:SetTimerLocalization{
	TimerSpecialSpell	= "Nächste Spezialfähigkeit"
}

L:SetWarningLocalization{
	WarnSpecialSpellSoon		= "Spezialfähigkeit bald",
	SpecWarnSpecial				= "Farbe wechseln",
	SpecWarnSwitchTarget		= "Ziel wechseln",
	SpecWarnKickNow				= "Jetzt unterbrechen",
	WarningTouchDebuff			= "Berührung auf >%s<",
	WarningPoweroftheTwins2		= "Macht der Zwillinge - Mehr Heilung auf >%s<"
}

L:SetMiscLocalization{
	Fjola		= "Fjola Lichtbann",
	Eydis		= "Eydis Nachtbann"
}

L:SetOptionLocalization{
	TimerSpecialSpell			= "Zeige Zeit bis nächste Spezialfähigkeit",
	WarnSpecialSpellSoon		= "Zeige Vorwarnung für nächste Spezialfähigkeit",
	SpecWarnSpecial				= "Spezialwarnung, wenn du die Farbe wechseln musst",
	SpecWarnSwitchTarget		= "Spezialwarnung, wenn der andere Zwilling zaubert",
	SpecWarnKickNow				= "Spezialwarnung zum Unterbrechen",
	SpecialWarnOnDebuff			= "Spezialwarnung bei Berührung (um Farbe zu wechseln)",
	SetIconOnDebuffTarget		= "Setze Zeichen auf Ziele von Berührung des Lichts/der Nacht (heroisch)",
	WarningTouchDebuff			= "Verkünde Ziele von Berührung des Lichts/der Nacht",
	WarningPoweroftheTwins2		= "Verkünde Ziele von Macht der Zwillinge"
}

-----------------
--  Anub'arak  --
-----------------
L = DBM:GetModLocalization("Anub'arak_Coliseum")

L:SetGeneralLocalization{
	name 					= "Anub'arak"
}

L:SetTimerLocalization{
	TimerEmerge				= "Auftauchen",
	TimerSubmerge			= "Abtauchen",
	timerAdds				= "Neue Adds"
}

L:SetWarningLocalization{
	WarnEmerge				= "Auftauchen",
	WarnEmergeSoon			= "Auftauchen in 10 Sekunden",
	WarnSubmerge			= "Abtauchen",
	WarnSubmergeSoon		= "Abtauchen in 10 Sekunden",
	specWarnSubmergeSoon	= "Abtauchen in 10 Sekunden!",
	warnAdds				= "Neue Adds"
}

L:SetMiscLocalization{
	Emerge				= "entsteigt dem Boden!",
	Burrow				= "gräbt sich in den Boden!",
	PcoldIconSet		= "DKälte-Zeichen {rt%d} auf %s gesetzt",
	PcoldIconRemoved	= "DKälte-Zeichen von %s entfernt"
}

L:SetOptionLocalization{
	WarnEmerge				= "Zeige Warnung für Auftauchen",
	WarnEmergeSoon			= "Zeige Vorwarnung für Auftauchen",
	WarnSubmerge			= "Zeige Warnung für Abtauchen",
	WarnSubmergeSoon		= "Zeige Vorwarnung für Abtauchen",
	specWarnSubmergeSoon	= "Spezialwarnung für baldiges Abtauchen",
	warnAdds				= "Verkünde neue Adds",
	timerAdds				= "Zeige Zeit bis neue Adds erscheinen",
	TimerEmerge				= "Zeige Zeit bis Auftauchen",
	TimerSubmerge			= "Zeige Zeit bis Abtauchen",
	AnnouncePColdIcons		= "Verkünde Zeichen für Ziele von $spell:66013 im Schlachtzugchat (nur als Leiter)",
	AnnouncePColdIconsRemoved	= "Verkünde auch das Entfernen von Zeichen für $spell:66013 (benötigt obige Einstellung)"
}

----------------------
--  Lord Marrowgar  --
----------------------
L = DBM:GetModLocalization("LordMarrowgar")

L:SetGeneralLocalization{
	name = "Lord Mark'gar"
}

-------------------------
--  Lady Deathwhisper  --
-------------------------
L = DBM:GetModLocalization("Deathwhisper")

L:SetGeneralLocalization{
	name = "Lady Todeswisper"
}

L:SetTimerLocalization{
	TimerAdds	= "Neue Adds"
}

L:SetWarningLocalization{
	WarnReanimating				= "Add-Wiederbelebung",
	WarnAddsSoon				= "Neue Adds bald"
}

L:SetOptionLocalization{
	WarnAddsSoon				= "Zeige Vorwarnung für erscheinende Adds",
	WarnReanimating				= "Zeige Warnung, wenn ein Add wiederbelebt wird",
	TimerAdds					= "Zeige Zeit bis neue Adds erscheinen"
}

L:SetMiscLocalization{
	YellReanimatedFanatic	= "Erhebt Euch und frohlocket ob Eurer reinen Form!",
	Fanatic1				= "Fanatischer Kultist",
	Fanatic2				= "Deformierter Fanatiker",
	Fanatic3				= "Wiederbelebter Fanatiker"
}

----------------------
--  Gunship Battle  --
----------------------
L = DBM:GetModLocalization("GunshipBattle")

L:SetGeneralLocalization{
	name = "Kanonenschiffsschlacht" -- "Kanonenschiffsschlacht von Eiskrone"
}

L:SetWarningLocalization{
	WarnAddsSoon	= "Neue Adds bald"
}

L:SetOptionLocalization{
	WarnAddsSoon		= "Zeige Vorwarnung für erscheinende Adds",
	TimerAdds			= "Zeige Zeit bis neue Adds erscheinen"
}

L:SetTimerLocalization{
	TimerAdds			= "Neue Adds"
}

L:SetMiscLocalization{
	PullAlliance	= "Alle Maschinen auf Volldampf! Unser Schicksal erwartet uns!",
	PullHorde		= "Erhebt Euch, Söhne und Töchter der Horde! Wir ziehen gegen einen verhassten Feind in die Schlacht! LOK'TAR OGAR!",
	AddsAlliance	= "Häscher, Unteroffiziere, Angriff!",
	AddsHorde		= "Soldaten! Zum Angriff!",
	MageAlliance	= "Der Rumpf ist beschädigt! Holt einen Kampfmagier, der die Kanonen ausschaltet!", --needs to be verified (video-captured alliance translation)
	MageHorde		= "Die Außenhaut ist beschädigt! Holt einen Zauberer, der die Kanonen ausschaltet!",
	Hammer 			= "Orgrims Hammer",
	Skybreaker		= "Die Himmelsbrecher"
}

-----------------------------
--  Deathbringer Saurfang  --
-----------------------------
L = DBM:GetModLocalization("Deathbringer")

L:SetGeneralLocalization{
	name = "Todesbringer Saurfang"
}

L:SetOptionLocalization{
	RangeFrame				= "Zeige Abstandsfenster (12m)",
	RunePowerFrame			= "Zeige Lebensanzeige und einen Balken für $spell:72371"
}

L:SetMiscLocalization{
	PullAlliance		= "Mit jedem Krieger der Horde, den Ihr getötet habt, mit jedem dieser Allianzhunde, der fiel, wuchsen die Armeen des Lichkönigs. Selbst in diesem Moment erwecken die Val'kyr Eure Gefallenen als Diener der Geißel.",
	PullHorde			= "Kor'kron, Aufbruch! Champions, gebt Acht. Die Geißel ist..."
}

-----------------
--  Festergut  --
-----------------
L = DBM:GetModLocalization("Festergut")

L:SetGeneralLocalization{
	name = "Fauldarm"
}

L:SetOptionLocalization{
	RangeFrame			= "Zeige Abstandsfenster (8m)",
	AnnounceSporeIcons	= "Verkünde Zeichen für Ziele von $spell:69279 im Schlachtzugchat (nur als Leiter)",
	AchievementCheck	= "Verkünde Fehlschlag des Erfolgs 'Grippeimpfungs-Engpass' an Schlachtzug (nur als Leiter/Assistent)"
}

L:SetMiscLocalization{
	SporeSet			= "Gassporenzeichen {rt%d} auf %s gesetzt",
	AchievementFailed	= ">> ERFOLG FEHLGESCHLAGEN: %s hat %d Stapel von Geimpft <<"
}

---------------
--  Rotface  --
---------------
L = DBM:GetModLocalization("Rotface")

L:SetGeneralLocalization{
	name = "Modermiene"
}

L:SetWarningLocalization{
	WarnOozeSpawn				= "Kleiner Schlamm erscheint",
	SpecWarnLittleOoze			= "Kleiner Schlamm greift dich an - Lauf weg!"
}

L:SetOptionLocalization{
	WarnOozeSpawn				= "Zeige Warnung für Erscheinen eines Kleinen Schlamm",
	SpecWarnLittleOoze			= "Spezialwarnung, wenn du von einem Kleinen Schlamm angegriffen wirst",
	RangeFrame					= "Zeige Abstandsfenster (8m)"
}

L:SetMiscLocalization{
	YellSlimePipes1	= "Gute Nachricht, Freunde! Die Giftschleim-Rohre sind repariert!",
	YellSlimePipes2	= "Gute Nachricht, Freunde! Der Schleim fließt wieder!"
}

---------------------------
--  Professor Putricide  --
---------------------------
L = DBM:GetModLocalization("Putricide")

L:SetGeneralLocalization{
	name = "Professor Seuchenmord"
}

L:SetOptionLocalization{
	MalleableGooIcon			= "Setze Zeichen auf erstes Ziel von $spell:72295"
}

----------------------------
--  Blood Prince Council  --
----------------------------
L = DBM:GetModLocalization("BPCouncil")

L:SetGeneralLocalization{
	name = "Rat des Blutes"
}

L:SetWarningLocalization{
	WarnTargetSwitch		= "Ziel wechseln auf: %s",
	WarnTargetSwitchSoon	= "Zielwechsel bald"
}

L:SetTimerLocalization{
	TimerTargetSwitch		= "Zielwechsel"
}

L:SetOptionLocalization{
	WarnTargetSwitch		= "Zeige Warnung für Zielwechsel",
	WarnTargetSwitchSoon	= "Zeige Vorwarnung für Zielwechsel",
	TimerTargetSwitch		= "Zeige Zeit bis Zielwechsel",
	ActivePrinceIcon		= "Setze Zeichen auf den machterfüllten Prinzen (Totenkopf)",
	RangeFrame				= "Zeige Abstandsfenster (12m)"
}

L:SetMiscLocalization{
	Keleseth			= "Prinz Keleseth",
	Taldaram			= "Prinz Taldaram",
	Valanar				= "Prinz Valanar",
	EmpoweredFlames		= "Machtvolle Flammen rasen auf (%S+) zu!"
}

-----------------------------
--  Blood-Queen Lana'thel  --
-----------------------------
L = DBM:GetModLocalization("Lanathel")

L:SetGeneralLocalization{
	name = "Blutkönigin Lana'thel"
}

L:SetOptionLocalization{
	RangeFrame				= "Zeige Abstandsfenster (8m)"
}

L:SetMiscLocalization{
	SwarmingShadows			= "Schatten sammeln sich und schwärmen um (%S+)!",
	YellFrenzy				= "Ich habe Durst!"
}

-----------------------------
--  Valithria Dreamwalker  --
-----------------------------
L = DBM:GetModLocalization("Valithria")

L:SetGeneralLocalization{
	name = "Valithria Traumwandler"
}

L:SetWarningLocalization{
	WarnPortalOpen	= "Portale offen"
}

L:SetTimerLocalization{
	TimerPortalsOpen		= "Portale offen",
	TimerPortalsClose		= "Portale geschlossen",
	TimerBlazingSkeleton	= "Nächstes Loderndes Skelett",
	TimerAbom				= "Nächste Monstrosität"
}

L:SetOptionLocalization{
	SetIconOnBlazingSkeleton	= "Setze Zeichen auf Loderndes Skelett (Totenkopf)",
	WarnPortalOpen				= "Zeige Warnung, wenn Alptraumportale geöffnet sind",
	TimerPortalsOpen			= "Zeige Zeit bis Alptraumportale geöffnet sind",
	TimerPortalsClose			= "Zeige Zeit bis Alptraumportale geschlossen sind",
	TimerBlazingSkeleton		= "Zeige Zeit bis nächstes Loderndes Skelett erscheint",
	TimerAbom					= "Zeige Zeit bis nächste Gefräßige Monstrosität erscheint (experimentell)"
}

L:SetMiscLocalization{
	YellPortals		= "Ich habe ein Portal in den Traum geöffnet. Darin liegt Eure Erlösung, Helden..."
}

------------------
--  Sindragosa  --
------------------
L = DBM:GetModLocalization("Sindragosa")

L:SetGeneralLocalization{
	name = "Sindragosa"
}

L:SetWarningLocalization{
	WarnAirphase			= "Luftphase",
	WarnGroundphaseSoon		= "Sindragosa landet bald"
}

L:SetTimerLocalization{
	TimerNextAirphase		= "Nächste Luftphase",
	TimerNextGroundphase	= "Nächste Bodenphase",
	AchievementMystic		= "Ablaufzeit für Mystischer Puffer"
}

L:SetOptionLocalization{
	WarnAirphase			= "Verkünde Luftphase",
	WarnGroundphaseSoon		= "Zeige Vorwarnung für Bodenphase",
	TimerNextAirphase		= "Zeige Zeit bis nächste Luftphase",
	TimerNextGroundphase	= "Zeige Zeit bis nächste Bodenphase",
	AnnounceFrostBeaconIcons= "Verkünde Zeichen für Ziele von $spell:70126 im SZ-Chat (nur als Leiter)",
	ClearIconsOnAirphase	= "Entferne alle Zeichen vor der Luftphase",
	AchievementCheck		= "Verkünde Warnungen für den Erfolg 'Das Buffet ist eröffnet' an Schlachtzug (nur als Leiter/Assistent)",
	RangeFrame				= "Zeige dynamisches Abstandsfenster (10m/20m) basierend auf zuletzt genutzten Bossfähigkeiten und Spieler-Debuffs"
}

L:SetMiscLocalization{
	YellAirphase		= "Euer Vormarsch endet hier! Keiner wird überleben!",
	YellPhase2			= "Fühlt die grenzenlose Macht meines Meisters, und verzweifelt!",
	YellAirphaseDem		= "Rikk zilthuras rikk zila Aman adare tiriosh ",--Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	YellPhase2Dem		= "Zar kiel xi romathIs zilthuras revos ruk toralar ",--Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	BeaconIconSet		= "Frostleuchtfeuer-Zeichen {rt%d} auf %s gesetzt",
	AchievementWarning	= "Warnung: %s hat 5 Stapel von Mystischer Puffer",
	AchievementFailed	= ">> ERFOLG FEHLGESCHLAGEN: %s hat %d Stapel von Mystischer Puffer <<"
}

---------------------
--  The Lich King  --
---------------------
L = DBM:GetModLocalization("LichKing")

L:SetGeneralLocalization{
	name = "Der Lichkönig"
}

L:SetWarningLocalization{
	ValkyrWarning			= ">%s< wurde gegriffen!",
	SpecWarnYouAreValkd		= "Du wurdest gegriffen",
	WarnNecroticPlagueJump	= "Nekrotische Seuche auf >%s< gesprungen",
	SpecWarnValkyrLow		= "Schattenwächterin unter 55%%"
}

L:SetTimerLocalization{
	TimerRoleplay		= "Rollenspiel",
	PhaseTransition		= "Phasenübergang",
	TimerNecroticPlagueCleanse = "Nekrotische Seuche reinigen"
}

L:SetOptionLocalization{
	TimerRoleplay			= "Dauer des Rollenspiels (bei 10%) anzeigen",
	WarnNecroticPlagueJump	= "Verkünde Sprungziele von $spell:70337",
	TimerNecroticPlagueCleanse	= "Zeige Timer zum Reinigen von $spell:70337 vor dem ersten Tick",
	PhaseTransition			= "Dauer der Phasenübergänge anzeigen",
	ValkyrWarning			= "Verkünde Griffziele der Schattenwächterinnen der Val'kyr",
	SpecWarnYouAreValkd		= "Spezialwarnung, wenn du von einer Schattenwächterin der Val'kyr gegriffen wurdest",--npc36609
	AnnounceValkGrabs		= "Verkünde Griffziele der Schattenwächterinnen der Val'kyr im SZ-Chat (benötigt aktivierte Mitteilungen und Leiter-/Assistentenstatus)",
	SpecWarnValkyrLow		= "Spezialwarnung, wenn eine Schattenwächterin der Val'kyr unter 55% Lebenspunkte ist",
	AnnouncePlagueStack		= "Verkünde $spell:70337 Stapel an den Schlachtzug (ab 10 Stapel, danach alle 5 Stapel) (nur als Leiter/Assistent)"
}

L:SetMiscLocalization{
	LKPull					= "Der vielgerühmte Streiter des Lichts ist endlich hier? Soll ich Frostgram niederlegen und mich Eurer Gnade ausliefern, Fordring?",
	LKRoleplay				= "Ist es wirklich Rechtschaffenheit, die Euch treibt? Ich bin mir nicht sicher…",
	ValkGrabbedIcon			= "Schattenwächterin der Val'kyr {rt%d} hat %s gegriffen",
	ValkGrabbed				= "Schattenwächterin der Val'kyr hat %s gegriffen",
	PlagueStackWarning		= "Warnung: %s hat %d Stapel von Nekrotischer Seuche",
	AchievementCompleted	= ">> ERFOLG FERTIG: %s hat %d Stapel von Nekrotischer Seuche <<"
}

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("ICCTrash")

L:SetGeneralLocalization{
	name = "Trash der Eiskronenzitadelle"
}

L:SetWarningLocalization{
	SpecWarnTrapL		= "Falle aktiviert! - Todesgeweihter Wächter freigesetzt",
	SpecWarnTrapP		= "Falle aktiviert! - Rachsüchtige Fleischernter kommen",
	SpecWarnGosaEvent	= "Sindragosa-Spießrutenlauf gestartet!"
}

L:SetOptionLocalization{
	SpecWarnTrapL		= "Spezialwarnung für Fallenaktivierung (Todesgeweihter Wächter)",
	SpecWarnTrapP		= "Spezialwarnung für Fallenaktivierung (Rachsüchtige Fleischernter)",
	SpecWarnGosaEvent	= "Spezialwarnung für Sindragosa-Spießrutenlauf"
}

L:SetMiscLocalization{
	WarderTrap1			= "Wer... ist da?",
	WarderTrap2			= "Ich erwache...",
	WarderTrap3			= "Das Sanktum des Meisters wurde entweiht!",
	FleshreaperTrap1	= "Schnell, überfallen wir sie von hinten!",
	FleshreaperTrap2	= "Ihr könnt uns nicht entkommen.",
	FleshreaperTrap3	= "Die Lebenden? Hier?!",
	SindragosaEvent		= "Ihr dürft Euch der Frostkönigin nicht nähern! Schnell, haltet sie auf!"
}

------------------------
--  The Ruby Sanctum  --
------------------------
--  Baltharus the Warborn  --
-----------------------------
L = DBM:GetModLocalization("Baltharus")

L:SetGeneralLocalization({
	name = "Baltharus der Kriegsjünger"
})

L:SetWarningLocalization({
	WarningSplitSoon	= "Aufspaltung bald"
})

L:SetOptionLocalization({
	WarningSplitSoon	= "Zeige Vorwarnung für Aufspaltung"
})

-------------------------
--  Saviana Ragefire  --
-------------------------
L = DBM:GetModLocalization("Saviana")

L:SetGeneralLocalization({
	name = "Saviana Flammenschlund"
})

--------------------------
--  General Zarithrian  --
--------------------------
L = DBM:GetModLocalization("Zarithrian")

L:SetGeneralLocalization({
	name = "General Zarithrian"
})

L:SetWarningLocalization({
	WarnAdds	= "Neue Adds",
	warnCleaveArmor	= "%s auf >%s< (%s)"
})

L:SetTimerLocalization({
	TimerAdds	= "Neue Adds"
})

L:SetOptionLocalization({
	WarnAdds		= "Verkünde neue Adds",
	TimerAdds		= "Zeige Zeit bis neue Adds erscheinen"
})

L:SetMiscLocalization({
	SummonMinions	= "Äschert sie ein, Lakaien!"
})

-------------------------------------
--  Halion the Twilight Destroyer  --
-------------------------------------
L = DBM:GetModLocalization("Halion")

L:SetGeneralLocalization({
	name = "Halion der Zwielichtzerstörer"
})

L:SetWarningLocalization({
	TwilightCutterCast	= "Wirkt Zwielichtschnitter: 5 sec"
})

L:SetOptionLocalization({
	TwilightCutterCast		= "Zeige Warnung, wenn $spell:74769 gewirkt wird",
	AnnounceAlternatePhase	= "Zeige auch Warnungen/Timer für Phasen, in denen du dich nicht befindest"
})

L:SetMiscLocalization({
	Halion					= "Halion",
	MeteorCast				= "Die Himmel brennen!",
	Phase2					= "Ihr werdet im Reich des Zwielichts nur Leid finden! Tretet ein, wenn ihr es wagt!",
	Phase3					= "Ich bin das Licht und die Dunkelheit! Zittert, Sterbliche, vor dem Herold Todesschwinges!",
	twilightcutter			= "Die kreisenden Sphären pulsieren vor dunkler Energie!",
	Kill					= "Genießt euren Sieg, Sterbliche, denn es war euer letzter. Bei der Rückkehr des Meisters wird diese Welt brennen!"
})
