local L

---------------
--  Kalecgos --
---------------
L = DBM:GetModLocalization("Kal")

L:SetGeneralLocalization{
	name = "Kalecgos"
}

L:SetWarningLocalization{
	WarnPortal			= "Portal #%d : >%s< (Group %d)",
	SpecWarnWildMagic	= "Wild Magic - %s!"
}

L:SetOptionLocalization{
	WarnPortal			= "Show warning for $spell:46021 target",
	SpecWarnWildMagic	= "Show special warning for Wild Magic",
	ShowFrame			= "Show Spectral Realm frame" ,
	FrameClassColor		= "Use class colors in Spectral Realm frame",
	FrameUpwards		= "Expand Spectral Realm frame upwards",
	FrameLocked			= "Set Spectral Realm frame not movable",
	RangeFrame			= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT:format(10, 46021)
}

L:SetMiscLocalization{
	Demon				= "Sathrovarr the Corruptor",
	Heal				= "Healing + 100%",
	Haste				= "Spell Haste + 100%",
	Hit					= "Melee Hit - 50%",
	Crit				= "Crit Damage + 100%",
	Aggro				= "AGGRO + 100%",
	Mana				= "Cost Reduce 50%",
	FrameTitle			= "Spectral Realm",
	FrameLock			= "Frame Lock",
	FrameClassColor		= "Use Class Colors",
	FrameOrientation	= "Expand upwards",
	FrameHide			= "Hide Frame",
	FrameClose			= "Close"
}

----------------
--  Brutallus --
----------------
L = DBM:GetModLocalization("Brutallus")

L:SetGeneralLocalization{
	name = "Brutallus"
}

L:SetMiscLocalization{
	Pull			= "Ah, more lambs to the slaughter!"
}

--------------
--  Felmyst --
--------------
L = DBM:GetModLocalization("Felmyst")

L:SetGeneralLocalization{
	name = "Felmyst"
}

L:SetWarningLocalization{
	WarnPhase		= "%s Phase"
}

L:SetTimerLocalization{
	TimerPhase		= "Next %s Phase"
}

L:SetOptionLocalization{
	WarnPhase		= "Show warning for next phase",
	TimerPhase		= "Show time for next phase",
	VaporIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(45392),
	EncapsIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(45665)
}

L:SetMiscLocalization{
	Air				= "Air",
	Ground			= "Ground",
	AirPhase		= "I am stronger than ever before!",
	Breath			= "%s takes a deep breath."
}

-----------------------
--  The Eredar Twins --
-----------------------
L = DBM:GetModLocalization("Twins")

L:SetGeneralLocalization{
	name = "Eredar Twins"
}

L:SetMiscLocalization{
	Nova			= "directs Shadow Nova at (.+)",
	Conflag			= "directs Conflagration at (.+)",
	Sacrolash		= "Lady Sacrolash",
	Alythess		= "Grand Warlock Alythess"
}

------------
--  M'uru --
------------
L = DBM:GetModLocalization("Muru")

L:SetGeneralLocalization{
	name = "M'uru"
}

L:SetWarningLocalization{
	WarnHuman		= "Humanoids (%d)",
	WarnVoid		= "Void Sentinel (%d)",
	WarnFiend		= "Dark Fiend spawned"
}

L:SetTimerLocalization{
	TimerHuman		= "Next Humanoids (%s)",
	TimerVoid		= "Next Void (%s)",
	TimerPhase		= "Entropius"
}

L:SetOptionLocalization{
	WarnHuman		= "Show warning for Humanoids",
	WarnVoid		= "Show warning for Void Sentinels",
	WarnFiend		= "Show warning for Fiends in phase 2",
	TimerHuman		= "Show timer for Humanoids",
	TimerVoid		= "Show timer for Void Sentinels",
	TimerPhase		= "Show time for Phase 2 transition"
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
	WarnDarkOrb		= "Dark Orbs Spawned",
	WarnBlueOrb		= "Dragon Orb activated",
	SpecWarnDarkOrb	= "Dark Orbs Spawned!",
	SpecWarnBlueOrb	= "Dragon Orbs Activated!"
}

L:SetTimerLocalization{
	TimerBlueOrb	= "Dragon Orbs activate"
}

L:SetOptionLocalization{
	WarnDarkOrb		= "Show warning for Dark Orbs",
	WarnBlueOrb		= "Show warning for Dragon Orbs",
	SpecWarnDarkOrb	= "Show special warning for Dark Orbs",
	SpecWarnBlueOrb	= "Show special warning for Dragon Orbs",
	TimerBlueOrb	= "Show timer form Dragon Orbs activate",
	RangeFrame		= DBM_CORE_L.AUTO_RANGE_OPTION_TEXT:format(10, 45641),
	BloomIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(45641)
}

L:SetMiscLocalization{
	YellPull		= "The expendable have perished. So be it! Now I shall succeed where Sargeras could not! I will bleed this wretched world and secure my place as the true master of the Burning Legion! The end has come! Let the unravelling of this world commence!",
	OrbYell1		= "I will channel my powers into the orbs! Be ready!",
	OrbYell2		= "I have empowered another orb! Use it quickly!",
	OrbYell3		= "Another orb is ready! Make haste!",
	OrbYell4		= "I have channeled all I can! The power is in your hands!"

}

-----------------
--  Najentus  --
-----------------
L = DBM:GetModLocalization("Najentus")

L:SetGeneralLocalization{
	name = "High Warlord Naj'entus"
}

L:SetMiscLocalization{
	HealthInfo	= "Health Info"
}

----------------
-- Supremus --
----------------
L = DBM:GetModLocalization("Supremus")

L:SetGeneralLocalization{
	name = "Supremus"
}

L:SetWarningLocalization{
	WarnPhase		= "%s Phase"
}

L:SetTimerLocalization{
	TimerPhase		= "Next %s phase"
}

L:SetOptionLocalization{
	WarnPhase		= "Show warning for next phase",
	TimerPhase		= "Show time for next phase",
	KiteIcon		= "Set icon on Kite target"
}

L:SetMiscLocalization{
	PhaseTank		= "punches the ground in anger!",
	PhaseKite		= "The ground begins to crack open!",
	ChangeTarget	= "acquires a new target",
	Kite			= "Kite",
	Tank			= "Tank"
}

-------------------------
--  Shape of Akama  --
-------------------------
L = DBM:GetModLocalization("Akama")

L:SetGeneralLocalization{
	name = "Shade of Akama"
}

L:SetWarningLocalization({
	warnAshtongueDefender	= "Ashtongue Defender",
	warnAshtongueSorcerer	= "Ashtongue Sorcerer"
})

L:SetTimerLocalization({
	timerAshtongueDefender	= "Ashtongue Defender: %s",
	timerAshtongueSorcerer	= "Ashtongue Sorcerer: %s"
})

L:SetOptionLocalization({
	warnAshtongueDefender	= "Show warning for Ashtongue Defender",
	warnAshtongueSorcerer	= "Show warning for Ashtongue Sorcerer",
	timerAshtongueDefender	= "Show timer for Ashtongue Defender",
	timerAshtongueSorcerer	= "Show timer for Ashtongue Sorcerer"
})

-------------------------
--  Teron Gorefiend  --
-------------------------
L = DBM:GetModLocalization("TeronGorefiend")

L:SetGeneralLocalization{
	name = "Teron Gorefiend"
}

L:SetTimerLocalization{
	TimerVengefulSpirit		= "Ghost : %s"
}

L:SetOptionLocalization{
	TimerVengefulSpirit		= "Show timer for Ghost durations"
}

----------------------------
--  Gurtogg Bloodboil  --
----------------------------
L = DBM:GetModLocalization("Bloodboil")

L:SetGeneralLocalization{
	name = "Gurtogg Bloodboil"
}

--------------------------
--  Essence Of Souls  --
--------------------------
L = DBM:GetModLocalization("Souls")

L:SetGeneralLocalization{
	name = "Essence of Souls"
}

L:SetWarningLocalization{
	WarnMana		= "Zero Mana in 30 sec"
}

L:SetTimerLocalization{
	TimerMana		= "Mana 0"
}

L:SetOptionLocalization{
	WarnMana		= "Show warning from zero mana in Phase 2",
	TimerMana		= "Show timer for zero mana in Phase 2"
}

L:SetMiscLocalization{
	Suffering		= "Essence of Suffering",
	Desire			= "Essence of Desire",
	Anger			= "Essence of Anger",
	Phase1End		= "I don't want to go back!",
	Phase2End		= "I won't be far!"
}

-----------------------
--  Mother Shahraz --
-----------------------
L = DBM:GetModLocalization("Shahraz")

L:SetGeneralLocalization{
	name = "Mother Shahraz"
}

L:SetTimerLocalization{
	timerAura	= "%s"
}

L:SetOptionLocalization{
	timerAura	= "Show timer for Prismatic Aura",
	FAHelper	= "Set mod behavior for Fatal Attraction. Raid Leaders preference is used if they're using DBM",
	North		= "Star is left/west, circle is right/east, diamond is up/north",--Default
	South		= "Star is left/west, circle is right/east, diamond is down/south",
	None		= "Arrows will not be shown, Infoframe will show numbers instead of directions"
}

----------------------
--  Illidari Council  --
----------------------
L = DBM:GetModLocalization("Council")

L:SetGeneralLocalization{
	name = "Illidari Council"
}

L:SetWarningLocalization{
	Immune			= "Malande - %s immune for 15 sec"
}

L:SetOptionLocalization{
	Immune			= "Show warning when Manalde becomes spell or melee immune"
}

L:SetMiscLocalization{
	Gathios			= "Gathios the Shatterer",
	Malande			= "Lady Malande",
	Zerevor			= "High Nethermancer Zerevor",
	Veras			= "Veras Darkshadow",
	Melee			= "Melee",
	Spell			= "Spell"
}

-------------------------
--  Illidan Stormrage --
-------------------------
L = DBM:GetModLocalization("Illidan")

L:SetGeneralLocalization{
	name = "Illidan Stormrage"
}

L:SetWarningLocalization{
	WarnHuman		= "Human Phase",
	WarnDemon		= "Demon Phase"
}

L:SetTimerLocalization{
	TimerNextHuman		= "Next Human Phase",
	TimerNextDemon		= "Next Demon Phase"
}

L:SetOptionLocalization{
	WarnHuman		= "Show warning for Human Phase",
	WarnDemon		= "Show warning for Demon Phase",
	TimerNextHuman	= "Show time for Next Human Phase",
	TimerNextDemon	= "Show time for Demon Human Phase",
	RangeFrame		= "Show range frame (10 yards) in Phase 3 and 4"
}

L:SetMiscLocalization{
	Pull			= "Akama. Your duplicity is hardly surprising. I should have slaughtered you and your malformed brethren long ago.",
	Eyebeam			= "Stare into the eyes of the Betrayer!",
	Demon			= "Behold the power... of the demon within!",
	Phase4			= "Is this it, mortals? Is this all the fury you can muster?"
}

------------------------
--  Rage Winterchill  --
------------------------
L = DBM:GetModLocalization("Rage")

L:SetGeneralLocalization{
	name = "Rage Winterchill"
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
	name 		= "Wave Features"
}
L:SetWarningLocalization{
	WarnWave	= "%s",
}
L:SetTimerLocalization{
	TimerWave	= "Next wave"
}
L:SetOptionLocalization{
	WarnWave		= "Warn when a new wave is incoming",
	DetailedWave	= "Detailed warning when a new wave is incoming (which mobs)",
	TimerWave		= "Show a timer for next wave"
}
L:SetMiscLocalization{
	HyjalZoneName	= "Hyjal Summit",
	Thrall			= "Thrall",
	Jaina			= "Lady Jaina Proudmoore",
	GeneralBoss		= "Boss incoming",
	RageWinterchill	= "Rage Winterchill incoming",
	Anetheron		= "Anetheron incoming",
	Kazrogal		= "Kazrogal incoming",
	Azgalor			= "Azgalor incoming",
	WarnWave_0		= "Wave %s/8",
	WarnWave_1		= "Wave %s/8 - %s %s",
	WarnWave_2		= "Wave %s/8 - %s %s and %s %s",
	WarnWave_3		= "Wave %s/8 - %s %s, %s %s and %s %s",
	WarnWave_4		= "Wave %s/8 - %s %s, %s %s, %s %s and %s %s",
	WarnWave_5		= "Wave %s/8 - %s %s, %s %s, %s %s, %s %s and %s %s",
	RageGossip		= "My companions and I are with you, Lady Proudmoore.",
	AnetheronGossip	= "We are ready for whatever Archimonde might send our way, Lady Proudmoore.",
	KazrogalGossip	= "I am with you, Thrall.",
	AzgalorGossip	= "We have nothing to fear.",
	Ghoul			= "Ghouls",
	Abomination		= "Abominations",
	Necromancer		= "Necromancers",
	Banshee			= "Banshees",
	Fiend			= "Crypt Fiends",
	Gargoyle		= "Gargoyles",
	Wyrm			= "Frost Wyrm",
	Stalker			= "Fel Stalkers",
	Infernal		= "Infernals"
}

-----------
--  Alar --
-----------
L = DBM:GetModLocalization("Alar")

L:SetGeneralLocalization{
	name = "Al'ar"
}

L:SetTimerLocalization{
	NextPlatform	= "Max Platform length"
}

L:SetOptionLocalization{
	NextPlatform	= "Show timer for when how long Al'ar may stay at platform (May leave sooner but almost never any later)"
}

------------------
--  Void Reaver --
------------------
L = DBM:GetModLocalization("VoidReaver")

L:SetGeneralLocalization{
	name = "Void Reaver"
}

--------------------------------
--  High Astromancer Solarian --
--------------------------------
L = DBM:GetModLocalization("Solarian")

L:SetGeneralLocalization{
	name = "High Astromancer Solarian"
}

L:SetWarningLocalization{
	WarnSplit		= "Split",
	WarnSplitSoon	= "Split in 5 seconds",
	WarnAgent		= "Agents spawned",
	WarnPriest		= "Priests and Solarian spawned"

}

L:SetTimerLocalization{
	TimerSplit		= "Next Split",
	TimerAgent		= "Agents incoming",
	TimerPriest		= "Priests & Solarian incoming"
}

L:SetOptionLocalization{
	WarnSplit		= "Show warning for Split",
	WarnSplitSoon	= "Show pre-warning for Split",
	WarnAgent		= "Show warning for Agents spawn",
	WarnPriest		= "Show warning for Priests and Solarian spawn",
	TimerSplit		= "Show timer for Split",
	TimerAgent		= "Show timer for Agents spawn",
	TimerPriest		= "Show timer for Priests and Solarian spawn"
}

L:SetMiscLocalization{
	YellSplit1		= "I will crush your delusions of grandeur!",
	YellSplit2		= "You are hopelessly outmatched!",
	YellPhase2		= "I become"
}

---------------------------
--  Kael'thas Sunstrider --
---------------------------
L = DBM:GetModLocalization("KaelThas")

L:SetGeneralLocalization{
	name = "Kael'thas Sunstrider"
}

L:SetWarningLocalization{
	WarnGaze		= "Gaze on >%s<",
	WarnMobDead		= "%s down",
	WarnEgg			= "Phoenix Egg spawned",
	SpecWarnGaze	= "Gaze on YOU - Run away!",
	SpecWarnEgg		= "Phoenix Egg spawned - Change Target!"
}

L:SetTimerLocalization{
	TimerPhase		= "Next Phase",
	TimerPhase1mob	= "%s",
	TimerNextGaze	= "New Gaze target",
	TimerRebirth	= "Phoenix Rebirth"
}

L:SetOptionLocalization{
	WarnGaze		= "Show warning for Thaladred's Gaze target",
	WarnMobDead		= "Show warning for Phase 2 mob down",
	WarnEgg			= "Show warning when Phoenix Egg spawn",
	SpecWarnGaze	= "Show special warning when Gaze on you",
	SpecWarnEgg		= "Show special warning when Phoenix Egg spawn",
	TimerPhase		= "Show time for next phase",
	TimerPhase1mob	= "Show time for Phase 1 mob active",
	TimerNextGaze	= "Show timer for Thaladred's Gaze target changes",
	TimerRebirth	= "Show timer for Phoenix Egg rebirth remaining",
	GazeIcon		= "Set icon on Thaladred's Gaze target"
}

L:SetMiscLocalization{
	YellPhase2	= "As you see, I have many weapons in my arsenal....",
	YellPhase3	= "Perhaps I underestimated you. It would be unfair to make you fight all four advisors at once, but... fair treatment was never shown to my people. I'm just returning the favor.",
	YellPhase4	= "Alas, sometimes one must take matters into one's own hands. Balamore shanal!",
	YellPhase5	= "I have not come this far to be stopped! The future I have planned will not be jeopardized! Now you will taste true power!!",
	YellSang	= "You have persevered against some of my best advisors... but none can withstand the might of the Blood Hammer. Behold, Lord Sanguinar!",
	YellCaper	= "Capernian will see to it that your stay here is a short one.",
	YellTelo	= "Well done, you have proven worthy to test your skills against my master engineer, Telonicus.",
	EmoteGaze	= "sets eyes on ([^%s]+)!",
	Thaladred	= "Thaladred the Darkener",
	Sanguinar	= "Lord Sanguinar",
	Capernian	= "Grand Astromancer Capernian",
	Telonicus	= "Master Engineer Telonicus",
	Bow			= "Netherstrand Longbow",
	Axe			= "Devastation",
	Mace		= "Cosmic Infuser",
	Dagger		= "Infinity Blades",
	Sword		= "Warp Slicer",
	Shield		= "Phaseshift Bulwark",
	Staff		= "Staff of Disintegration",
	Egg			= "Phoenix Egg"
}

---------------------------
--  Hydross the Unstable --
---------------------------
L = DBM:GetModLocalization("Hydross")

L:SetGeneralLocalization{
	name = "Hydross the Unstable"
}

L:SetWarningLocalization{
	WarnMark 		= "%s : %s",
	WarnPhase		= "%s Phase",
	SpecWarnMark	= "%s : %s"
}

L:SetTimerLocalization{
	TimerMark	= "Next %s : %s"
}

L:SetOptionLocalization{
	WarnMark		= "Show warning for Marks",
	WarnPhase		= "Show warning for next phase",
	SpecWarnMark	= "Show warning when Marks debuff damage over 100%",
	TimerMark		= "Show timer for next Marks"
}

L:SetMiscLocalization{
	Frost	= "Frost",
	Nature	= "Nature"
}

-----------------------
--  The Lurker Below --
-----------------------
L = DBM:GetModLocalization("LurkerBelow")

L:SetGeneralLocalization{
	name = "The Lurker Below"
}

L:SetWarningLocalization{
	WarnSubmerge		= "Submerged",
	WarnEmerge			= "Emerged"
}

L:SetTimerLocalization{
	TimerSubmerge		= "Sumberge CD",
	TimerEmerge			= "Emerge CD"
}

L:SetOptionLocalization{
	WarnSubmerge		= "Show warning when submerge",
	WarnEmerge			= "Show warning when emerge",
	TimerSubmerge		= "Show time for submerge",
	TimerEmerge			= "Show time for emerge"
}

--------------------------
--  Leotheras the Blind --
--------------------------
L = DBM:GetModLocalization("Leotheras")

L:SetGeneralLocalization{
	name = "Leotheras the Blind"
}

L:SetWarningLocalization{
	WarnPhase		= "%s Phase"
}

L:SetTimerLocalization{
	TimerPhase	= "Next %s Phase"
}

L:SetOptionLocalization{
	WarnPhase		= "Show warning for next phase",
	TimerPhase		= "Show time for next phase"
}

L:SetMiscLocalization{
	Human		= "Human",
	Demon		= "Demon",
	YellDemon	= "Be gone, trifling elf%.%s*I am in control now!",
	YellPhase1  = "Finally my banishment ends!",
	YellPhase2	= "No... no! What have you done? I am the master! Do you hear me? I am... aaggh! Can't... contain him."
}

-----------------------------
--  Fathom-Lord Karathress --
-----------------------------
L = DBM:GetModLocalization("Fathomlord")

L:SetGeneralLocalization{
	name = "Fathom-Lord Karathress"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
}

L:SetMiscLocalization{
	Caribdis	= "Fathom-Guard Caribdis",
	Tidalvess	= "Fathom-Guard Tidalvess",
	Sharkkis	= "Fathom-Guard Sharkkis"
}

--------------------------
--  Morogrim Tidewalker --
--------------------------
L = DBM:GetModLocalization("Tidewalker")

L:SetGeneralLocalization{
	name = "Morogrim Tidewalker"
}

L:SetWarningLocalization{
	SpecWarnMurlocs	= "Murlocs Coming!"
}

L:SetTimerLocalization{
	TimerMurlocs	= "Murlocs"
}

L:SetOptionLocalization{
	SpecWarnMurlocs	= "Show special warning when Murlocs spawning",
	TimerMurlocs	= "Show timer for Murlocs spawning",
	GraveIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(38049)
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
	WarnElemental		= "Tainted Elemental Soon (%s)",
	WarnStrider			= "Strider Soon (%s)",
	WarnNaga			= "Naga Soon (%s)",
	WarnShield			= "Shield %d/4 down",
	WarnLoot			= "Tainted Core on >%s<",
	SpecWarnElemental	= "Tainted Elemental - Switch!"
}

L:SetTimerLocalization{
	TimerElementalActive	= "Elemental Active",
	TimerElemental			= "Elemental CD (%d)",
	TimerStrider			= "Next Strider (%d)",
	TimerNaga				= "Next Naga (%d)"
}

L:SetOptionLocalization{
	WarnElemental		= "Show pre-warning for next Tainted Elemental",
	WarnStrider			= "Show pre-warning for next Strider",
	WarnNaga			= "Show pre-warning for next Naga",
	WarnShield			= "Show warning for Phase 2 shield down",
	WarnLoot			= "Show warning for Tainted Core loot",
	TimerElementalActive	= "Show timer for how long Tainted Elemental is active",
	TimerElemental		= "Show timer for Tainted Elemental cooldown",
	TimerStrider		= "Show timer for next Strider",
	TimerNaga			= "Show timer for next Naga",
	SpecWarnElemental	= "Show special warning when Tainted Elemental coming",
	ChargeIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(38280),
	AutoChangeLootToFFA	= "Switch loot mode to Free for All in Phase 2"
}

L:SetMiscLocalization{
	DBM_VASHJ_YELL_PHASE2	= "The time is now! Leave none standing!",
	DBM_VASHJ_YELL_PHASE3	= "You may want to take cover.",
	LootMsg					= "([^%s]+).*Hitem:(%d+)"
}

--Maulgar
L = DBM:GetModLocalization("Maulgar")

L:SetGeneralLocalization{
	name = "High King Maulgar"
}


--Gruul the Dragonkiller
L = DBM:GetModLocalization("Gruul")

L:SetGeneralLocalization{
	name = "Gruul the Dragonkiller"
}

L:SetWarningLocalization{
	WarnGrowth	= "%s (%d)"
}

L:SetOptionLocalization{
	WarnGrowth		= "Show warning for $spell:36300",
	RangeDistance	= "Range frame distance for |cff71d5ff|Hspell:33654|hShatter|h|r",
	Smaller			= "Smaller distance (11)",
	Safe			= "Safer distance (18)"
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
	timerP2	= "Show timer for start of phase 2"
}

L:SetMiscLocalization{
	DBM_MAG_EMOTE_PULL		= "%s's bonds begin to weaken!",
	DBM_MAG_YELL_PHASE2		= "I... am... unleashed!",
	DBM_MAG_YELL_PHASE3		= "I will not be taken so easily! Let the walls of this prison tremble... and fall!"
}

--Attumen
L = DBM:GetModLocalization("Attumen")

L:SetGeneralLocalization{
	name = "Attumen the Huntsman"
}

L:SetMiscLocalization{
	DBM_ATH_YELL_1		= "Come Midnight, let's disperse this petty rabble!"
}


--Moroes
L = DBM:GetModLocalization("Moroes")

L:SetGeneralLocalization{
	name = "Moroes"
}

L:SetWarningLocalization{
	DBM_MOROES_VANISH_FADED	= "Vanish faded"
}

L:SetOptionLocalization{
	DBM_MOROES_VANISH_FADED	= "Show vanish fade warning"
}


-- Maiden of Virtue
L = DBM:GetModLocalization("Maiden")

L:SetGeneralLocalization{
	name = "Maiden of Virtue"
}

-- Romulo and Julianne
L = DBM:GetModLocalization("RomuloAndJulianne")

L:SetGeneralLocalization{
	name = "Romulo and Julianne"
}

L:SetMiscLocalization{
	Event				= "Tonight... we explore a tale of forbidden love!",
	RJ_Pull				= "What devil art thou, that dost torment me thus?",
	DBM_RJ_PHASE2_YELL	= "Come, gentle night; and give me back my Romulo!",
	Romulo				= "Romulo",
	Julianne			= "Julianne"
}


-- Big Bad Wolf
L = DBM:GetModLocalization("BigBadWolf")

L:SetGeneralLocalization{
	name = "The Big Bad Wolf"
}

L:SetWarningLocalization{
}

L:SetMiscLocalization{
	DBM_BBW_YELL_1			= "The better to own you with!"
}


-- Wizard of Oz
L = DBM:GetModLocalization("Oz")

L:SetGeneralLocalization{
	name = "Wizard of Oz"
}

L:SetWarningLocalization{
	DBM_OZ_WARN_TITO		= "Tito",
	DBM_OZ_WARN_ROAR		= "Roar",
	DBM_OZ_WARN_STRAWMAN	= "Strawman",
	DBM_OZ_WARN_TINHEAD		= "Tinhead",
	DBM_OZ_WARN_CRONE		= "The Crone"
}

L:SetTimerLocalization{
	DBM_OZ_WARN_TITO		= "Tito",
	DBM_OZ_WARN_ROAR		= "Roar",
	DBM_OZ_WARN_STRAWMAN	= "Strawman",
	DBM_OZ_WARN_TINHEAD		= "Tinhead"
}

L:SetOptionLocalization{
	AnnounceBosses			= "Show warnings for boss spawns",
	ShowBossTimers			= "Show timers for boss spawns"
}

L:SetMiscLocalization{
	DBM_OZ_YELL_DOROTHEE	= "Oh Tito, we simply must find a way home! The old wizard could be our only hope! Strawman, Roar, Tinhead, will you - wait... oh golly, look we have visitors!",
	DBM_OZ_YELL_ROAR		= "I'm not afraid a' you! Do you wanna' fight? Huh, do ya'? C'mon! I'll fight ya' with both paws behind my back!",
	DBM_OZ_YELL_STRAWMAN	= "Now what should I do with you? I simply can't make up my mind.",
	DBM_OZ_YELL_TINHEAD		= "I could really use a heart. Say, can I have yours?",
	DBM_OZ_YELL_CRONE		= "Woe to each and every one of you, my pretties!"
}


-- Curator
L = DBM:GetModLocalization("Curator")

L:SetGeneralLocalization{
	name = "The Curator"
}

L:SetWarningLocalization{
	warnAdd		= "Add spawned"
}

L:SetOptionLocalization{
	warnAdd		= "Show warning when add spawned"
}


-- Terestian Illhoof
L = DBM:GetModLocalization("TerestianIllhoof")

L:SetGeneralLocalization{
	name = "Terestian Illhoof"
}

L:SetMiscLocalization{
	Kilrek					= "Kil'rek",
	DChains					= "Demon Chains"
}


-- Shade of Aran
L = DBM:GetModLocalization("Aran")

L:SetGeneralLocalization{
	name = "Shade of Aran"
}

L:SetWarningLocalization{
	DBM_ARAN_DO_NOT_MOVE	= "Flame Wreath - Do not move!"
}

L:SetTimerLocalization{
	timerSpecial			= "Special ability CD"
}

L:SetOptionLocalization{
	timerSpecial			= "Show timer for special ability cooldown",
	DBM_ARAN_DO_NOT_MOVE	= "Show special warning for $spell:30004"
}

--Netherspite
L = DBM:GetModLocalization("Netherspite")

L:SetGeneralLocalization{
	name = "Netherspite"
}

L:SetWarningLocalization{
	warningPortal			= "Portal Phase",
	warningBanish			= "Banish Phase"
}

L:SetTimerLocalization{
	timerPortalPhase	= "Portal Phase Ends",
	timerBanishPhase	= "Banish Phase Ends"
}

L:SetOptionLocalization{
	warningPortal			= "Show warning for Portal phase",
	warningBanish			= "Show warning for Banish phase",
	timerPortalPhase		= "Show timer for Portal Phase duration",
	timerBanishPhase		= "Show timer for Banish Phase duration"
}

L:SetMiscLocalization{
	DBM_NS_EMOTE_PHASE_2	= "%s goes into a nether-fed rage!",
	DBM_NS_EMOTE_PHASE_1	= "%s cries out in withdrawal, opening gates to the nether."
}

--Chess
L = DBM:GetModLocalization("Chess")

L:SetGeneralLocalization{
	name = "Chess Event"
}

L:SetTimerLocalization{
	timerCheat	= "Cheat CD"
}

L:SetOptionLocalization{
	timerCheat	= "Show timer for cheat cooldown"
}

L:SetMiscLocalization{
	EchoCheats	= "Echo of Medivh cheats!"
}

--Prince Malchezaar
L = DBM:GetModLocalization("Prince")

L:SetGeneralLocalization{
	name = "Prince Malchezaar"
}

L:SetMiscLocalization{
	DBM_PRINCE_YELL_P2		= "Simple fools! Time is the fire in which you'll burn!",
	DBM_PRINCE_YELL_P3		= "How can you hope to stand against such overwhelming power?",
	DBM_PRINCE_YELL_INF1	= "All realities, all dimensions are open to me!",
	DBM_PRINCE_YELL_INF2	= "You face not Malchezaar alone, but the legions I command!"
}


-- Nightbane
L = DBM:GetModLocalization("NightbaneRaid")

L:SetGeneralLocalization{
	name = "Nightbane (Raid)"
}

L:SetWarningLocalization{
	DBM_NB_AIR_WARN			= "Air Phase"
}

L:SetTimerLocalization{
	timerAirPhase			= "Air Phase"
}

L:SetOptionLocalization{
	DBM_NB_AIR_WARN			= "Show warning for Air Phase",
	timerAirPhase			= "Show timer for Air Phase duration"
}

L:SetMiscLocalization{
	DBM_NB_EMOTE_PULL		= "An ancient being awakens in the distance...",
	DBM_NB_YELL_AIR			= "Miserable vermin. I shall exterminate you from the air!",
	DBM_NB_YELL_GROUND		= "Enough! I shall land and crush you myself!",
	DBM_NB_YELL_GROUND2		= "Insects! Let me show you my strength up close!"
}


-- Named Beasts
L = DBM:GetModLocalization("Shadikith")

L:SetGeneralLocalization{
	name = "Shadikith the Glider"
}

L = DBM:GetModLocalization("Hyakiss")

L:SetGeneralLocalization{
	name = "Hyakiss the Lurker"
}

L = DBM:GetModLocalization("Rokad")

L:SetGeneralLocalization{
	name = "Rokad the Ravager"
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
	WarnBear		= "Bear Form",
	WarnBearSoon	= "Bear Form in 5 sec",
	WarnNormal		= "Normal Form",
	WarnNormalSoon	= "Normal Form in 5 sec"
}

L:SetTimerLocalization{
	TimerBear		= "Bear Form",
	TimerNormal		= "Normal Form"
}

L:SetOptionLocalization{
	WarnBear		= "Show warning for Bear form",
	WarnBearSoon	= "Show pre-warning for Bear form",
	WarnNormal		= "Show warning for Normal form",
	WarnNormalSoon	= "Show pre-warning for Normal form",
	TimerBear		= "Show timer for Bear form",
	TimerNormal		= "Show timer for Normal form"
}

L:SetMiscLocalization{
	YellBear 	= "You call on da beast, you gonna get more dan you bargain for!",
	YellNormal	= "Make way for Nalorakk!"
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
	YellBomb	= "I burn ya now!",
	YellAdds	= "Where ma hatcha? Get to work on dem eggs!"
}

--------------
--  Halazzi --
--------------
L = DBM:GetModLocalization("Halazzi")

L:SetGeneralLocalization{
	name = "Halazzi"
}

L:SetWarningLocalization{
	WarnSpirit	= "Spirit Phase",
	WarnNormal	= "Normal Phase"
}

L:SetOptionLocalization{
	WarnSpirit	= "Show warning for Spirit phase",
	WarnNormal	= "Show warning for Normal phase"
}

L:SetMiscLocalization{
	YellSpirit	= "I fight wit' untamed spirit....",
	YellNormal	= "Spirit, come back to me!"
}

--------------------------
--  Hex Lord Malacrass --
--------------------------
L = DBM:GetModLocalization("Malacrass")

L:SetGeneralLocalization{
	name = "Hex Lord Malacrass"
}

L:SetMiscLocalization{
	YellPull	= "Da shadow gonna fall on you...."
}

--------------
--  Zul'jin --
--------------
L = DBM:GetModLocalization("ZulJin")

L:SetGeneralLocalization{
	name = "Zul'jin"
}

L:SetMiscLocalization{
	YellPhase2	= "Got me some new tricks... like me brudda bear....",
	YellPhase3	= "Dere be no hidin' from da eagle!",
	YellPhase4	= "Let me introduce you to me new bruddas: fang and claw!",
	YellPhase5	= "Ya don' have to look to da sky to see da dragonhawk!"
}
