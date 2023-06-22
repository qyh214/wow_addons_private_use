local L

----------------------------------
--  Archavon the Stone Watcher  --
----------------------------------
L = DBM:GetModLocalization("Archavon")

L:SetGeneralLocalization({
	name = "Archavon the Stone Watcher"
})

L:SetWarningLocalization({
	WarningGrab	= "Archavon grabbed >%s<"
})

L:SetTimerLocalization({
	ArchavonEnrage	= "Archavon berserk"
})

L:SetMiscLocalization({
	TankSwitch	= "%%s lunges for (%S+)!"
})

L:SetOptionLocalization({
	WarningGrab		= "Announce grab targets",
	ArchavonEnrage	= "Show timer for $spell:26662"
})

--------------------------------
--  Emalon the Storm Watcher  --
--------------------------------
L = DBM:GetModLocalization("Emalon")

L:SetGeneralLocalization{
	name = "Emalon the Storm Watcher"
}

L:SetTimerLocalization{
	timerMobOvercharge	= "Overcharge explosion",
	EmalonEnrage		= "Emalon berserk"
}

L:SetOptionLocalization{
	timerMobOvercharge	= "Show timer for Overcharged mob (stacking debuff)",
	EmalonEnrage		= "Show timer for $spell:26662"
}

---------------------------------
--  Koralon the Flame Watcher  --
---------------------------------
L = DBM:GetModLocalization("Koralon")

L:SetGeneralLocalization{
	name = "Koralon the Flame Watcher"
}

L:SetTimerLocalization{
	KoralonEnrage	= "Koralon berserk"
}

L:SetOptionLocalization{
	KoralonEnrage		= "Show timer for $spell:26662"
}

L:SetMiscLocalization{
	Meteor	= "%s casts Meteor Fists!"
}

-------------------------------
--  Toravon the Ice Watcher  --
-------------------------------
L = DBM:GetModLocalization("Toravon")

L:SetGeneralLocalization{
	name = "Toravon the Ice Watcher"
}

L:SetTimerLocalization{
	ToravonEnrage	= "Toravon berserk"
}

L:SetMiscLocalization{
	ToravonEnrage	= "Show timer for enrage"
}

-------------------
--  Anub'Rekhan  --
-------------------
L = DBM:GetModLocalization("Anub'Rekhan")

L:SetGeneralLocalization({
	name = "Anub'Rekhan"
})

L:SetOptionLocalization({
	ArachnophobiaTimer	= "Show timer for Arachnophobia (achievement)"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "Arachnophobia",
	Pull1				= "Yes, run! It makes the blood pump faster!",
	Pull2				= "Just a little taste..."
})

----------------------------
--  Grand Widow Faerlina  --
----------------------------
L = DBM:GetModLocalization("Faerlina")

L:SetGeneralLocalization({
	name = "Grand Widow Faerlina"
})

L:SetWarningLocalization({
	WarningEmbraceExpire	= "Widow's Embrace ends in 5 seconds",
	WarningEmbraceExpired	= "Widow's Embrace faded"
})

L:SetOptionLocalization({
	WarningEmbraceExpire	= "Show pre-warning for Widow's Embrace fade",
	WarningEmbraceExpired	= "Show warning for Widow's Embrace fade"
})

L:SetMiscLocalization({
	Pull					= "Kneel before me, worm!"--Not actually pull trigger, but often said on pull
})

---------------
--  Maexxna  --
---------------
L = DBM:GetModLocalization("Maexxna")

L:SetGeneralLocalization({
	name = "Maexxna"
})

L:SetWarningLocalization({
	WarningSpidersSoon	= "Maexxna Spiderlings in 5 seconds",
	WarningSpidersNow	= "Maexxna Spiderlings spawned"
})

L:SetTimerLocalization({
	TimerSpider	= "Next Maexxna Spiderlings"
})

L:SetOptionLocalization({
	WarningSpidersSoon	= "Show pre-warning for Maexxna Spiderlings",
	WarningSpidersNow	= "Show warning for Maexxna Spiderlings",
	TimerSpider			= "Show timer for next Maexxna Spiderlings"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "Arachnophobia"
})

------------------------------
--  Noth the Plaguebringer  --
------------------------------
L = DBM:GetModLocalization("Noth")

L:SetGeneralLocalization({
	name = "Noth the Plaguebringer"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "Teleported",
	WarningTeleportSoon	= "Teleport in 10 seconds"
})

L:SetTimerLocalization({
	TimerTeleport		= "Teleport",
	TimerTeleportBack	= "Teleport back"
})

L:SetOptionLocalization({
	WarningTeleportNow	= "Show warning for Teleport",
	WarningTeleportSoon	= "Show pre-warning for Teleport",
	TimerTeleport		= "Show timer for Teleport",
	TimerTeleportBack	= "Show timer for Teleport back"
})

L:SetMiscLocalization({
	Pull				= "Die, trespasser!",
	Adds				= "summons forth Skeletal Warriors!",
	AddsTwo				= "raises more skeletons!"
})

--------------------------
--  Heigan the Unclean  --
--------------------------
L = DBM:GetModLocalization("Heigan")

L:SetGeneralLocalization({
	name = "Heigan the Unclean"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "Teleported",
	WarningTeleportSoon	= "Teleport in %d seconds"
})

L:SetTimerLocalization({
	TimerTeleport	= "Teleport"
})

L:SetOptionLocalization({
	WarningTeleportNow	= "Show warning for Teleport",
	WarningTeleportSoon	= "Show pre-warning for Teleport",
	TimerTeleport		= "Show timer for Teleport"
})

L:SetMiscLocalization({
	Pull				= "You are mine now."
})

---------------
--  Loatheb  --
---------------
L = DBM:GetModLocalization("Loatheb")

L:SetGeneralLocalization({
	name = "Loatheb"
})

L:SetWarningLocalization({
	WarningHealSoon	= "Healing possible in 3 seconds",
	WarningHealNow	= "Heal now"
})

L:SetOptionLocalization({
	WarningHealSoon		= "Show pre-warning for 3-second healing window",
	WarningHealNow		= "Show warning for 3-second healing window"
})

-----------------
--  Patchwerk  --
-----------------
L = DBM:GetModLocalization("Patchwerk")

L:SetGeneralLocalization({
	name = "Patchwerk"
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	yell1			= "Patchwerk want to play!",
	yell2			= "Kel'thuzad make Patchwerk his avatar of war!"
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
	Yell	= "Stalagg crush you!",
	Emote	= "%s overloads!",
	Emote2	= "Tesla Coil overloads!",
	Boss1	= "Feugen",
	Boss2	= "Stalagg",
	Charge1 = "negative",
	Charge2 = "positive"
})

L:SetOptionLocalization({
	WarningChargeChanged	= "Show special warning when your polarity changed",
	WarningChargeNotChanged	= "Show special warning when your polarity did not change",
	AirowEnabled			= "Show arrows during Polarity Shift",
	TwoCamp					= "Show arrows (normal \"2 camp\" run through strategy)",
	ArrowsRightLeft			= "Show left/right arrows for the \"4 camp\" strategy (show left arrow if polarity changed, right if not)",
	ArrowsInverse			= "Inverse \"4 camp\" strategy (show right arrow if polarity changed, left if not)"
})

L:SetWarningLocalization({
	WarningChargeChanged	= "Polarity changed to %s",
	WarningChargeNotChanged	= "Polarity did not change"
})

----------------------------
--  Instructor Razuvious  --
----------------------------
L = DBM:GetModLocalization("Razuvious")

L:SetGeneralLocalization({
	name = "Instructor Razuvious"
})

L:SetMiscLocalization({
	Yell1 = "Show them no mercy!",
	Yell2 = "The time for practice is over! Show me what you have learned!",
	Yell3 = "Do as I taught you!",
	Yell4 = "Sweep the leg... Do you have a problem with that?"
})

L:SetOptionLocalization({
	WarningShieldWallSoon	= "Show pre-warning for Bone Barrier ending"
})

L:SetWarningLocalization({
	WarningShieldWallSoon	= "Bone Barrier ends in 5 seconds"
})

----------------------------
--  Gothik the Harvester  --
----------------------------
L = DBM:GetModLocalization("Gothik")

L:SetGeneralLocalization({
	name = "Gothik the Harvester"
})

L:SetOptionLocalization({
	TimerWave			= "Show timer for next wave",
	TimerPhase2			= "Show timer for Phase 2",
	WarningWaveSoon		= "Show pre-warning for wave",
	WarningWaveSpawned	= "Show warning for wave spawned",
	WarningRiderDown	= "Show warning when an Unrelenting Rider dies",
	WarningKnightDown	= "Show warning when an Unrelenting Death Knight dies"
})

L:SetTimerLocalization({
	TimerWave	= "Wave %d",
	TimerPhase2	= "Phase 2"
})

L:SetWarningLocalization({
	WarningWaveSoon		= "Wave %d: %s in 3 sec",
	WarningWaveSpawned	= "Wave %d: %s spawned",
	WarningRiderDown	= "Rider down",
	WarningKnightDown	= "Knight down",
	WarningPhase2		= "Phase 2"
})

L:SetMiscLocalization({
	yell			= "Foolishly you have sought your own demise.",
	WarningWave1	= "%d %s",
	WarningWave2	= "%d %s and %d %s",
	WarningWave3	= "%d %s, %d %s and %d %s",
	Trainee			= "Trainees",
	Knight			= "Knights",
	Rider			= "Riders"
})

---------------------
--  Four Horsemen  --
---------------------
L = DBM:GetModLocalization("Horsemen")

L:SetGeneralLocalization({
	name = "Four Horsemen"
})

L:SetOptionLocalization({
	WarningMarkSoon				= "Show pre-warning for Mark",
	WarningMarkNow				= "Show warning for Mark",
	SpecialWarningMarkOnPlayer	= "Show special warning when you are affected by more than 4 marks",
	timerMark					= "Show timer for next horseman's Mark (with count)"
})

L:SetTimerLocalization({
	timerMark	= "Mark %d",
})


L:SetWarningLocalization({
	WarningMarkSoon				= "Mark %d in 3 seconds",
	WarningMarkNow				= "Mark %d",
	SpecialWarningMarkOnPlayer	= "%s: %s"
})

L:SetMiscLocalization({
	Korthazz	= "Thane Korth'azz",
	Rivendare	= "Baron Rivendare",
	Blaumeux	= "Lady Blaumeux",
	Zeliek		= "Sir Zeliek"
})

-----------------
--  Sapphiron  --
-----------------
L = DBM:GetModLocalization("Sapphiron")

L:SetGeneralLocalization({
	name = "Sapphiron"
})

L:SetOptionLocalization({
	WarningAirPhaseSoon	= "Show pre-warning for air phase",
	WarningAirPhaseNow	= "Announce air phase",
	WarningLanded		= "Announce ground phase",
	TimerAir			= "Show timer for air phase",
	TimerLanding		= "Show timer for landing"
})

L:SetMiscLocalization({
	EmoteBreath			= "%s takes a deep breath."
})

L:SetWarningLocalization({
	WarningAirPhaseSoon	= "Air phase in 10 seconds",
	WarningAirPhaseNow	= "Air phase",
	WarningLanded		= "Sapphiron landed"
})

L:SetTimerLocalization({
	TimerAir		= "Air phase",
	TimerLanding	= "Landing"
})

------------------
--  Kel'Thuzad  --
------------------

L = DBM:GetModLocalization("Kel'Thuzad")

L:SetGeneralLocalization({
	name = "Kel'Thuzad"
})

L:SetOptionLocalization({
	TimerPhase2			= "Show timer for Phase 2",
	specwarnP2Soon		= "Show special warning 10 seconds before Kel'Thuzad engages",
	warnAddsSoon		= "Show pre-warning for Guardians of Icecrown"
})

L:SetMiscLocalization({
	Yell = "Minions, servants, soldiers of the cold dark! Obey the call of Kel'Thuzad!"
})

L:SetWarningLocalization({
	specwarnP2Soon	= "Kel'Thuzad engages in 10 Seconds",
	warnAddsSoon	= "Guardians of Icecrown incoming soon"
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
	WarningTenebron			= "Tenebron incoming",
	WarningShadron			= "Shadron incoming",
	WarningVesperon			= "Vesperon incoming",
	WarningFireWall			= "Fire Wall",
	WarningVesperonPortal	= "Vesperon's portal",
	WarningTenebronPortal	= "Tenebron's portal",
	WarningShadronPortal	= "Shadron's portal"
})

L:SetTimerLocalization({
	TimerTenebron	= "Tenebron arrives",
	TimerShadron	= "Shadron arrives",
	TimerVesperon	= "Vesperon arrives"
})

L:SetOptionLocalization({
	AnnounceFails			= "Post player fails for Fire Wall and Shadow Fissure to raid chat<br/>(requires announce to be enabled and leader/promoted status)",
	TimerTenebron			= "Show timer for Tenebron's arrival",
	TimerShadron			= "Show timer for Shadron's arrival",
	TimerVesperon			= "Show timer for Vesperon's arrival",
	WarningFireWall			= "Show special warning for Fire Wall",
	WarningTenebron			= "Announce Tenebron incoming",
	WarningShadron			= "Announce Shadron incoming",
	WarningVesperon			= "Announce Vesperon incoming",
	WarningTenebronPortal	= "Show special warning for Tenebron's portal",
	WarningShadronPortal	= "Show special warning for Shadron's portal",
	WarningVesperonPortal	= "Show special warning for Vesperon's portal"
})

L:SetMiscLocalization({
	Wall			= "The lava surrounding %s churns!",
	Portal			= "%s begins to open a Twilight Portal!",
	NameTenebron	= "Tenebron",
	NameShadron		= "Shadron",
	NameVesperon	= "Vesperon",
	FireWallOn		= "Fire Wall: %s",
	VoidZoneOn		= "Shadow Fissure: %s",
	VoidZones		= "Shadow Fissure fails (this try): %s",
	FireWalls		= "Fire Wall fails (this try): %s"
})

---------------
--  Malygos  --
---------------
L = DBM:GetModLocalization("Malygos")

L:SetGeneralLocalization({
	name = "Malygos"
})

L:SetMiscLocalization({
	YellPull	= "My patience has reached its limit. I will be rid of you!",
	EmoteSpark	= "A Power Spark forms from a nearby rift!",
	YellPhase2	= "I had hoped to end your lives quickly",
	YellBreath	= "You will not succeed while I draw breath!",
	YellPhase3	= "Now your benefactors make their"
})

-----------------------
--  Flame Leviathan  --
-----------------------
L = DBM:GetModLocalization("FlameLeviathan")

L:SetGeneralLocalization{
	name = "Flame Leviathan"
}

L:SetMiscLocalization{
	YellPull	= "Hostile entities detected. Threat assessment protocol active. Primary target engaged. Time minus 30 seconds to re-evaluation.",
	Emote		= "%%s pursues (%S+)%."
}

L:SetWarningLocalization{
	PursueWarn				= "Pursuing >%s<",
	warnNextPursueSoon		= "Target change in 5 seconds",
	SpecialPursueWarnYou	= "You are being pursued - Run away",
	warnWardofLife			= "Ward of Life spawned"
}

L:SetOptionLocalization{
	SpecialPursueWarnYou	= "Show special warning when you are being $spell:62374",
	PursueWarn				= "Announce $spell:62374 targets",
	warnNextPursueSoon		= "Show pre-warning for next $spell:62374",
	warnWardofLife			= "Show special warning for Ward of Life spawn"
}

--------------------------------
--  Ignis the Furnace Master  --
--------------------------------
L = DBM:GetModLocalization("Ignis")

L:SetGeneralLocalization{
	name = "Ignis the Furnace Master"
}

L:SetOptionLocalization{
	SlagPotIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(63477)
}

------------------
--  Razorscale  --
------------------
L = DBM:GetModLocalization("Razorscale")

L:SetGeneralLocalization{
	name = "Razorscale"
}

L:SetWarningLocalization{
	warnTurretsReadySoon		= "Last turret ready in 20 seconds",
	warnTurretsReady			= "Last turret ready"
}

L:SetTimerLocalization{
	timerTurret1	= "Turret 1",
	timerTurret2	= "Turret 2",
	timerTurret3	= "Turret 3",
	timerTurret4	= "Turret 4",
	timerGrounded	= "On the ground"
}

L:SetOptionLocalization{
	warnTurretsReadySoon		= "Show pre-warning for turrets",
	warnTurretsReady			= "Show warning for turrets",
	timerTurret1				= "Show timer for turret 1",
	timerTurret2				= "Show timer for turret 2",
	timerTurret3				= "Show timer for turret 3 (25 player Classic or Retail)",
	timerTurret4				= "Show timer for turret 4 (25 player Classic or Retail)",
	timerGrounded			    = "Show timer for ground phase duration"
}

L:SetMiscLocalization{
	YellAir				= "Give us a moment to prepare to build the turrets.",
	YellAir2			= "Fires out! Let's rebuild those turrets!",
	YellGround			= "Move quickly! She won't remain grounded for long!",
	EmotePhase2			= "grounded permanently"
}

----------------------------
--  XT-002 Deconstructor  --
----------------------------
L = DBM:GetModLocalization("XT002")

L:SetGeneralLocalization{
	name = "XT-002 Deconstructor"
}

--------------------
--  Iron Council  --
--------------------
L = DBM:GetModLocalization("IronCouncil")

L:SetGeneralLocalization{
	name = "Iron Council"
}

L:SetOptionLocalization{
	AlwaysWarnOnOverload		= "Always warn on $spell:63481 (otherwise, only when targeted)"
}

L:SetMiscLocalization{
	Steelbreaker		= "Steelbreaker",
	RunemasterMolgeim	= "Runemaster Molgeim",
	StormcallerBrundir 	= "Stormcaller Brundir"
}

----------------------------
--  Algalon the Observer  --
----------------------------
L = DBM:GetModLocalization("Algalon")

L:SetGeneralLocalization{
	name = "Algalon the Observer"
}

L:SetTimerLocalization{
	NextCollapsingStar		= "Next Collapsing Star",
	TimerCombatStart		= "Combat starts"
}

L:SetWarningLocalization{
	WarnPhase2Soon			= "Stage 2 soon",
	warnStarLow				= "Collapsing Star is low"
}

L:SetOptionLocalization{
	WarningPhasePunch		= "Announce Phase Punch targets",
	NextCollapsingStar		= "Show timer for next Collapsing Star",
	TimerCombatStart		= "Show timer for start of combat",
	WarnPhase2Soon			= "Show pre-warning for Stage 2 (at ~23%)",
	warnStarLow				= "Show special warning when Collapsing Star is low (at ~25%)"
}

L:SetMiscLocalization{
	HealthInfo				= "Heal for star",
	YellPull				= "Your actions are illogical. All possible results for this encounter have been calculated. The Pantheon will receive the Observer's message regardless of outcome.",
	YellKill				= "I have seen worlds bathed in the Makers' flames, their denizens fading without as much as a whimper. Entire planetary systems born and razed in the time that it takes your mortal hearts to beat once. Yet all throughout, my own heart devoid of emotion... of empathy. I. Have. Felt. Nothing. A million-million lives wasted. Had they all held within them your tenacity? Had they all loved life as you do?",
	Emote_CollapsingStar	= "%s begins to Summon Collapsing Stars!",
	Phase2					= "Behold the tools of creation",
	FirstPull				= "See your world through my eyes: A universe so vast as to be immeasurable - incomprehensible even to your greatest minds."
}

----------------
--  Kologarn  --
----------------
L = DBM:GetModLocalization("Kologarn")

L:SetGeneralLocalization{
	name = "Kologarn"
}

L:SetTimerLocalization{
	timerLeftArm		= "Left Arm respawn",
	timerRightArm		= "Right Arm respawn",
	achievementDisarmed	= "Timer for Disarm"
}

L:SetOptionLocalization{
	timerLeftArm			= "Show timer for Left Arm respawn",
	timerRightArm			= "Show timer for Right Arm respawn",
	achievementDisarmed		= "Show timer for Disarm achievement"
}

L:SetMiscLocalization{
	Yell_Trigger_arm_left	= "Just a scratch!",
	Yell_Trigger_arm_right	= "Only a flesh wound!",
	Health_Body				= "Kologarn Body",
	Health_Right_Arm		= "Right Arm",
	Health_Left_Arm			= "Left Arm",
	FocusedEyebeam			= "his eyes on you"
}

---------------
--  Auriaya  --
---------------
L = DBM:GetModLocalization("Auriaya")

L:SetGeneralLocalization{
	name = "Auriaya"
}

L:SetMiscLocalization{
	Defender = "Feral Defender (%d)",
	YellPull = "Some things are better left alone!"
}

L:SetTimerLocalization{
	timerDefender	= "Feral Defender activates"
}

L:SetWarningLocalization{
	WarnCatDied		= "Feral Defender down (%d lives remaining)",
	WarnCatDiedOne	= "Feral Defender down (1 life remaining)"
}

L:SetOptionLocalization{
	WarnCatDied		= "Show warning when Feral Defender dies",
	WarnCatDiedOne	= "Show warning when Feral Defender has 1 life remaining",
	timerDefender	= "Show timer for when Feral Defender is activated"
}

-------------
--  Hodir  --
-------------
L = DBM:GetModLocalization("Hodir")

L:SetGeneralLocalization{
	name = "Hodir"
}

L:SetTimerLocalization{
	TimerHardmode	= "Shatter Cache"
}

L:SetOptionLocalization{
	TimerHardmode	= "Show timer for hard mode"
}

L:SetMiscLocalization{
	Pull		= "You will suffer for this trespass!",
	YellKill	= "I... I am released from his grasp... at last."
}

--------------
--  Thorim  --
--------------
L = DBM:GetModLocalization("Thorim")

L:SetGeneralLocalization{
	name = "Thorim"
}

L:SetTimerLocalization{
	TimerHardmode	= "Hard mode"
}

L:SetOptionLocalization{
	TimerHardmode	= "Show timer for hard mode",
	AnnounceFails	= "Post player fails for $spell:62017 to raid chat<br/>(requires announce to be enabled and leader/promoted status)"
}

L:SetMiscLocalization{
	YellPhase1	= "Interlopers! You mortals who dare to interfere with my sport will pay.... Wait--you...",
	YellPhase2	= "Impertinent whelps, you dare challenge me atop my pedestal? I will crush you myself!",
	YellKill	= "Stay your arms! I yield!",
	ChargeOn	= "Lightning Charge: %s",
	Charge		= "Lightning Charge fails (this try): %s"
}

-------------
--  Freya  --
-------------
L = DBM:GetModLocalization("Freya")

L:SetGeneralLocalization{
	name = "Freya"
}

L:SetMiscLocalization{
	SpawnYell          = "Children, assist me!",
	WaterSpirit        = "Ancient Water Spirit",
	Snaplasher         = "Snaplasher",
	StormLasher        = "Storm Lasher",
	YellKill           = "His hold on me dissipates. I can see clearly once more. Thank you, heroes."
}

L:SetWarningLocalization{
	WarnSimulKill	= "First add down - Resurrection in ~12 seconds"
}

L:SetTimerLocalization{
	TimerSimulKill	= "Resurrection"
}

L:SetOptionLocalization{
	WarnSimulKill	= "Announce first mob down",
	TimerSimulKill	= "Show timer for mob resurrection"
}

----------------------
--  Freya's Elders  --
----------------------
L = DBM:GetModLocalization("Freya_Elders")

L:SetGeneralLocalization{
	name = "Freya's Elders"
}

---------------
--  Mimiron  --
---------------
L = DBM:GetModLocalization("Mimiron")

L:SetGeneralLocalization{
	name = "Mimiron"
}

L:SetWarningLocalization{
	MagneticCore		= ">%s< has Magnetic Core",
	WarnBombSpawn		= "Bomb Bot spawned"
}

L:SetTimerLocalization{
	TimerHardmode	= "Hard mode - Self-destruct",
	TimeToPhase2	= "Stage 2",
	TimeToPhase3	= "Stage 3",
	TimeToPhase4	= "Stage 4"
}

L:SetOptionLocalization{
	TimeToPhase2			= "Show timer for Stage 2",
	TimeToPhase3			= "Show timer for Stage 3",
	TimeToPhase4			= "Show timer for Stage 4",
	MagneticCore			= "Announce Magnetic Core looters",
	WarnBombSpawn			= "Show warning for Bomb Bots",
	TimerHardmode			= "Show timer for hard mode"
}

L:SetMiscLocalization{
	MobPhase1		= "Leviathan Mk II",
	MobPhase2		= "VX-001",
	MobPhase3		= "Aerial Command Unit",
	YellPull		= "We haven't much time, friends! You're going to help me test out my latest and greatest creation. Now, before you change your minds, remember that you kind of owe it to me after the mess you made with the XT-002.",
	YellHardPull	= "Self-destruct sequence initiated.",
	YellPhase2		= "WONDERFUL! Positively marvelous results! Hull integrity at 98.9 percent! Barely a dent! Moving right along.",
	YellPhase3		= "Thank you, friends! Your efforts have yielded some fantastic data! Now, where did I put-- oh, there it is.",
	YellPhase4		= "Preliminary testing phase complete. Now comes the true test!"
}

---------------------
--  General Vezax  --
---------------------
L = DBM:GetModLocalization("GeneralVezax")

L:SetGeneralLocalization{
	name = "General Vezax"
}

L:SetWarningLocalization{
	specWarnAnimus 	= "Saronite Animus - switch targets"
}

L:SetTimerLocalization{
	hardmodeSpawn	= "Saronite Animus spawn"
}

L:SetOptionLocalization{
	specWarnAnimus 	= "Show special announce to switch targets for Saronite Animus",
	hardmodeSpawn	= "Show timer for Saronite Animus spawn (hard mode)"
}

L:SetMiscLocalization{
	EmoteSaroniteVapors	= "A cloud of saronite vapors coalesces nearby!"
}

------------------
--  Yogg-Saron  --
------------------
L = DBM:GetModLocalization("YoggSaron")

L:SetGeneralLocalization{
	name = "Yogg-Saron"
}

L:SetWarningLocalization{
	WarningGuardianSpawned 			= "Guardian %d spawned",
	WarningCrusherTentacleSpawned	= "Crusher Tentacle spawned",
	WarningSanity 					= "%d Sanity remaining",
	SpecWarnSanity 					= "%d Sanity remaining",
	SpecWarnMadnessOutNow			= "Induce Madness ending - Move out",
	WarnBrainPortalSoon				= "Brain Portal in 10 seconds",
	specWarnBrainPortalSoon			= "Brain Portal soon"
}

L:SetTimerLocalization{
	NextPortal	= "Brain Portal"
}

L:SetOptionLocalization{
	WarningGuardianSpawned			= "Show warning for Guardian spawns",
	WarningCrusherTentacleSpawned	= "Show warning for Crusher Tentacle spawns",
	WarningSanity					= "Show warning when $spell:63050 is low",
	SpecWarnSanity					= "Show special warning when $spell:63050 is very low",
	WarnBrainPortalSoon				= "Show pre-warning for Brain Portal",
	SpecWarnMadnessOutNow			= "Show special warning shortly before $spell:64059 ends",
	specWarnBrainPortalSoon			= "Show special warning for next Brain Portal",
	NextPortal						= "Show timer for next Brain Portal"
}

L:SetMiscLocalization{
	YellPull 			= "The time to strike at the head of the beast will soon be upon us! Focus your anger and hatred on his minions!",
	YellPhase2	 		= "I am the lucid dream.",
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
	WarnWhelpsSoon		= "Onyxian Whelps soon"
}

L:SetTimerLocalization{
	TimerWhelps	= "Onyxian Whelps"
}

L:SetOptionLocalization{
	TimerWhelps				= "Show timer for Onyxian Whelps",
	WarnWhelpsSoon			= "Show pre-warning for Onyxian Whelps",
	SoundWTF3				= "Play some funny sounds from a legendary classic Onyxia raid"
}

L:SetMiscLocalization{
	YellPull = "How fortuitous. Usually, I must leave my lair in order to feed.",
	YellP2 = "This meaningless exertion bores me. I'll incinerate you all from above!",
	YellP3 = "It seems you'll need another lesson, mortals!"
}

------------------------
--  Northrend Beasts  --
------------------------
L = DBM:GetModLocalization("NorthrendBeasts")

L:SetGeneralLocalization{
	name = "Northrend Beasts"
}

L:SetWarningLocalization{
	WarningSnobold		= "Snobold Vassal spawned on >%s<"
}

L:SetTimerLocalization{
	TimerNextBoss		= "Next boss",
	TimerEmerge			= "Emerge",
	TimerSubmerge		= "Submerge"
}

L:SetOptionLocalization{
	WarningSnobold		= "Show warning for Snobold Vassal spawns",
	ClearIconsOnIceHowl	= "Clear all icons before charge",
	TimerNextBoss		= "Show timer for next boss spawn",
	TimerEmerge			= "Show timer for emerge",
	TimerSubmerge		= "Show timer for submerge",
	IcehowlArrow		= "Show DBM arrow when Icehowl is about to charge near you"
}

L:SetMiscLocalization{
	Charge		= "^%%s glares at (%S+) and lets out",
	CombatStart	= "Hailing from the deepest, darkest caverns of the Storm Peaks, Gormok the Impaler! Battle on, heroes!",
	Phase2		= "Steel yourselves, heroes, for the twin terrors, Acidmaw and Dreadscale, enter the arena!",
	Phase3		= "The air itself freezes with the introduction of our next combatant, Icehowl! Kill or be killed, champions!",
	Gormok		= "Gormok the Impaler",
	Acidmaw		= "Acidmaw",
	Dreadscale	= "Dreadscale",
	Icehowl		= "Icehowl"
}

---------------------
--  Lord Jaraxxus  --
---------------------
L = DBM:GetModLocalization("Jaraxxus")

L:SetGeneralLocalization{
	name = "Lord Jaraxxus"
}

L:SetOptionLocalization{
	IncinerateShieldFrame		= "Show boss health with a health bar for Incinerate Flesh"
}

L:SetMiscLocalization{
	IncinerateTarget	= "Incinerate Flesh: %s",
	FirstPull	= "Grand Warlock Wilfred Fizzlebang will summon forth your next challenge. Stand by for his entry."
}

-------------------------
--  Faction Champions  --
-------------------------
L = DBM:GetModLocalization("Champions")

L:SetGeneralLocalization{
	name = "Faction Champions"
}

L:SetMiscLocalization{
	AllianceVictory    = "GLORY TO THE ALLIANCE!",
	HordeVictory       = "That was just a taste of what the future brings. FOR THE HORDE!"
}

---------------------
--  Val'kyr Twins  --
---------------------
L = DBM:GetModLocalization("ValkTwins")

L:SetGeneralLocalization{
	name = "Val'kyr Twins"
}

L:SetTimerLocalization{
	TimerSpecialSpell	= "Next special ability"
}

L:SetWarningLocalization{
	WarnSpecialSpellSoon		= "Special ability soon",
	SpecWarnSpecial				= "Change color",
	SpecWarnSwitchTarget		= "Switch target",
	SpecWarnKickNow				= "Interrupt now",
	WarningTouchDebuff			= "Debuff on >%s<",
	WarningPoweroftheTwins2		= "Power of the Twins - More healing on >%s<"
}

L:SetMiscLocalization{
	Fjola		= "Fjola Lightbane",
	Eydis		= "Eydis Darkbane"
}

L:SetOptionLocalization{
	TimerSpecialSpell			= "Show timer for next special ability",
	WarnSpecialSpellSoon		= "Show pre-warning for next special ability",
	SpecWarnSpecial				= "Show special warning when you have to change color",
	SpecWarnSwitchTarget		= "Show special warning to twitch targets if other Twin is casting heal",
	SpecWarnKickNow				= "Show special warning when you are able to interrupt heal",
	SpecialWarnOnDebuff			= "Show change color special warning when touch debuffed (to switch debuff)",
	SetIconOnDebuffTarget		= "Set icons on Touch of Light/Darkness debuff targets (heroic)",
	WarningTouchDebuff			= "Announce Touch of Light/Darkness debuff targets",
	WarningPoweroftheTwins2		= "Announce Power of the Twins targets"
}

-----------------
--  Anub'arak  --
-----------------
L = DBM:GetModLocalization("Anub'arak_Coliseum")

L:SetGeneralLocalization{
	name 					= "Anub'arak"
}

L:SetTimerLocalization{
	TimerEmerge				= "Emerge",
	TimerSubmerge			= "Submerge",
	timerAdds				= "New adds"
}

L:SetWarningLocalization{
	WarnEmerge				= "Anub'arak emerges",
	WarnEmergeSoon			= "Emerge in 10 seconds",
	WarnSubmerge			= "Anub'arak submerges",
	WarnSubmergeSoon		= "Submerge in 10 seconds",
	specWarnSubmergeSoon	= "Submerge in 10 seconds!",
	warnAdds				= "New adds"
}

L:SetMiscLocalization{
	Emerge				= "emerges from the ground!",
	Burrow				= "burrows into the ground!",
	PcoldIconSet		= "PCold icon {rt%d} set on %s",
	PcoldIconRemoved	= "PCold icon removed from %s"
}

L:SetOptionLocalization{
	WarnEmerge				= "Show warning for emerge",
	WarnEmergeSoon			= "Show pre-warning for emerge",
	WarnSubmerge			= "Show warning for submerge",
	WarnSubmergeSoon		= "Show pre-warning for submerge",
	specWarnSubmergeSoon	= "Show special warning for submerge soon",
	warnAdds				= "Announce new adds",
	timerAdds				= "Show timer for new adds",
	TimerEmerge				= "Show timer for emerge",
	TimerSubmerge			= "Show timer for submerge",
	AnnouncePColdIcons		= "Announce icons for $spell:66013 targets to raid chat (requires raid leader)",
	AnnouncePColdIconsRemoved	= "Announce when icons are removed for $spell:66013 (requires raid leader)"
}

----------------------
--  Lord Marrowgar  --
----------------------
L = DBM:GetModLocalization("LordMarrowgar")

L:SetGeneralLocalization{
	name = "Lord Marrowgar"
}

-------------------------
--  Lady Deathwhisper  --
-------------------------
L = DBM:GetModLocalization("Deathwhisper")

L:SetGeneralLocalization{
	name = "Lady Deathwhisper"
}

L:SetTimerLocalization{
	TimerAdds	= "New Adds"
}

L:SetWarningLocalization{
	WarnReanimating				= "Add reviving",			-- Reanimating an adherent or fanatic
	WarnAddsSoon				= "New adds soon"
}

L:SetOptionLocalization{
	WarnAddsSoon				= "Show pre-warning for adds spawning",
	WarnReanimating				= "Show warning when an add is being revived",	-- Reanimated Adherent/Fanatic spawning
	TimerAdds					= "Show timer for new adds"
}

L:SetMiscLocalization{
	YellReanimatedFanatic	= "Arise, and exult in your pure form!"
}

----------------------
--  Gunship Battle  --
----------------------
L = DBM:GetModLocalization("GunshipBattle")

L:SetGeneralLocalization{
	name = "Gunship Battle"
}

L:SetWarningLocalization{
	WarnAddsSoon	= "New adds soon"
}

L:SetOptionLocalization{
	WarnAddsSoon		= "Show pre-warning for adds spawning",
	TimerAdds			= "Show timer for new adds"
}

L:SetTimerLocalization{
	TimerAdds			= "New adds"
}

L:SetMiscLocalization{
	PullAlliance	= "Fire up the engines! We got a meetin' with destiny, lads!",
	PullHorde		= "Rise up, sons and daughters of the Horde! Today we battle a hated enemy of the Horde! LOK'TAR OGAR!",
	AddsAlliance	= "Reavers, Sergeants, attack",
	AddsHorde		= "Marines, Sergeants, attack",
	MageAlliance	= "We're taking hull damage, get a battle-mage out here to shut down those cannons!",
	MageHorde		= "We're taking hull damage, get a sorcerer out here to shut down those cannons!",
	Hammer 			= "Orgrim's Hammer",
	Skybreaker		= "Skybreaker"
}

-----------------------------
--  Deathbringer Saurfang  --
-----------------------------
L = DBM:GetModLocalization("Deathbringer")

L:SetGeneralLocalization{
	name = "Deathbringer Saurfang"
}

L:SetOptionLocalization{
	RunePowerFrame			= "Show Boss Health + $spell:72371 bar"
}

L:SetMiscLocalization{
	PullAlliance		= "For every Horde soldier that you killed -- for every Alliance dog that fell, the Lich King's armies grew. Even now the val'kyr work to raise your fallen as Scourge.",
	PullHorde			= "Kor'kron, move out! Champions, watch your backs. The Scourge have been..."
}

-----------------
--  Festergut  --
-----------------
L = DBM:GetModLocalization("Festergut")

L:SetGeneralLocalization{
	name = "Festergut"
}

L:SetOptionLocalization{
	AnnounceSporeIcons	= "Announce icons for $spell:69279 targets to raid chat<br/>(requires raid leader)",
	AchievementCheck	= "Announce 'Flu Shot Shortage' achievement failure to raid<br/>(requires promoted status)"
}

L:SetMiscLocalization{
	SporeSet			= "Gas Spore icon {rt%d} set on %s",
	AchievementFailed	= ">> ACHIEVEMENT FAILED: %s has %d stacks of Inoculated <<"
}

---------------
--  Rotface  --
---------------
L = DBM:GetModLocalization("Rotface")

L:SetGeneralLocalization{
	name = "Rotface"
}

L:SetWarningLocalization{
	WarnOozeSpawn				= "Little Ooze spawning",
	SpecWarnLittleOoze			= "Little Ooze attacking you - Run Away"--creatureid 36897
}

L:SetOptionLocalization{
	WarnOozeSpawn				= "Show warning for Little Ooze spawning",
	SpecWarnLittleOoze			= "Show special warning when you are attacked by Little Ooze"--creatureid 36897
}

L:SetMiscLocalization{
	YellSlimePipes1	= "Good news, everyone! I've fixed the poison slime pipes!",	-- Professor Putricide
	YellSlimePipes2	= "Great news, everyone! The slime is flowing again!"	-- Professor Putricide
}

---------------------------
--  Professor Putricide  --
---------------------------
L = DBM:GetModLocalization("Putricide")

L:SetGeneralLocalization{
	name = "Professor Putricide"
}

----------------------------
--  Blood Prince Council  --
----------------------------
L = DBM:GetModLocalization("BPCouncil")

L:SetGeneralLocalization{
	name = "Blood Prince Council"
}

L:SetWarningLocalization{
	WarnTargetSwitch		= "Switch target to: %s",
	WarnTargetSwitchSoon	= "Target switch soon"
}

L:SetTimerLocalization{
	TimerTargetSwitch		= "Target switch"
}

L:SetOptionLocalization{
	WarnTargetSwitch		= "Show warning to switch targets",-- Warn when another Prince needs to be damaged
	WarnTargetSwitchSoon	= "Show pre-warning to switch targets",-- Every ~47 secs, you have to dps a different Prince
	TimerTargetSwitch		= "Show timer for target switch cooldown",
	ActivePrinceIcon		= "Set icon on the empowered Prince (skull)"
}

L:SetMiscLocalization{
	Keleseth			= "Prince Keleseth",
	Taldaram			= "Prince Taldaram",
	Valanar				= "Prince Valanar",
	EmpoweredFlames		= "Empowered Flames speed toward (%S+)!"
}

-----------------------------
--  Blood-Queen Lana'thel  --
-----------------------------
L = DBM:GetModLocalization("Lanathel")

L:SetGeneralLocalization{
	name = "Blood-Queen Lana'thel"
}

L:SetMiscLocalization{
	SwarmingShadows			= "Shadows amass and swarm around (%S+)!",
	YellFrenzy				= "I'm hungry!"
}

-----------------------------
--  Valithria Dreamwalker  --
-----------------------------
L = DBM:GetModLocalization("Valithria")

L:SetGeneralLocalization{
	name = "Valithria Dreamwalker"
}

L:SetWarningLocalization{
	WarnPortalOpen	= "Portals open"
}

L:SetTimerLocalization{
	TimerPortalsOpen		= "Portals open",
	TimerPortalsClose		= "Portals close",
	TimerBlazingSkeleton	= "Next Blazing Skeleton",
	TimerAbom				= "Next Abomination"
}

L:SetOptionLocalization{
	SetIconOnBlazingSkeleton	= "Set icon on Blazing Skeleton (skull)",
	WarnPortalOpen				= "Show warning when Nightmare Portals are opened up",
	TimerPortalsOpen			= "Show timer when Nightmare Portals are opened up",
	TimerPortalsClose			= "Show timer when Nightmare Portals are closed",
	TimerBlazingSkeleton		= "Show timer for next Blazing Skeleton spawn",
	TimerAbom					= "Show timer for next Gluttonous Abomination spawn (Experimental)"
}

L:SetMiscLocalization{
	YellPortals		= "I have opened a portal into the Dream. Your salvation lies within, heroes..."
}

------------------
--  Sindragosa  --
------------------
L = DBM:GetModLocalization("Sindragosa")

L:SetGeneralLocalization{
	name = "Sindragosa"
}

L:SetWarningLocalization{
	WarnAirphase			= "Air phase",
	WarnGroundphaseSoon		= "Sindragosa landing soon"
}

L:SetTimerLocalization{
	TimerNextAirphase		= "Next air phase",
	TimerNextGroundphase	= "Next ground phase",
	AchievementMystic		= "Time to clear Mystic stacks"
}

L:SetOptionLocalization{
	WarnAirphase			= "Announce air phase",
	WarnGroundphaseSoon		= "Show pre-warning for ground phase",
	TimerNextAirphase		= "Show timer for next air phase",
	TimerNextGroundphase	= "Show timer for next ground phase",
	AnnounceFrostBeaconIcons= "Announce icons for $spell:70126 targets to raid chat<br/>(requires raid leader)",
	ClearIconsOnAirphase	= "Clear all icons before air phase",
	AchievementCheck		= "Announce 'All You Can Eat' achievement warnings to raid<br/>(requires promoted status)"
}

L:SetMiscLocalization{
	YellAirphase		= "Your incursion ends here! None shall survive!",
	YellPhase2			= "Now, feel my master's limitless power and despair!",
	YellAirphaseDem		= "Rikk zilthuras rikk zila Aman adare tiriosh ",--Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	YellPhase2Dem		= "Zar kiel xi romathIs zilthuras revos ruk toralar ",--Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	BeaconIconSet		= "Frost Beacon icon {rt%d} set on %s",
	AchievementWarning	= "Warning: %s has 5 stacks of Mystic Buffet",
	AchievementFailed	= ">> ACHIEVEMENT FAILED: %s has %d stacks of Mystic Buffet <<"
}

---------------------
--  The Lich King  --
---------------------
L = DBM:GetModLocalization("LichKing")

L:SetGeneralLocalization{
	name = "The Lich King"
}

L:SetWarningLocalization{
	ValkyrWarning			= ">%s< has been grabbed!",
	SpecWarnYouAreValkd		= "You have been grabbed",
	WarnNecroticPlagueJump	= "Necrotic Plague jumped to >%s<",
	SpecWarnValkyrLow		= "Valkyr below 55%"
}

L:SetTimerLocalization{
	TimerRoleplay		= "Roleplay",
	PhaseTransition		= "Phase transition",
	TimerNecroticPlagueCleanse = "Cleanse Necrotic Plague"
}

L:SetOptionLocalization{
	TimerRoleplay			= "Show timer for roleplay event",
	WarnNecroticPlagueJump	= "Announce $spell:70337 jump targets",
	TimerNecroticPlagueCleanse	= "Show timer to cleanse Necrotic Plague before<br/>the first tick",
	PhaseTransition			= "Show time for phase transitions",
	ValkyrWarning			= "Announce Val'kyr Shadowguards grab targets",
	SpecWarnYouAreValkd		= "Show special warning when you have been grabbed by a Val'kyr Shadowguard",--npc36609
	AnnounceValkGrabs		= "Announce Val'kyr Shadowguard grab targets in raid chat<br/>(requires announce to be enabled and promoted status)",
	SpecWarnValkyrLow		= "Show special warning when Valkyr is below 55% HP",
	AnnouncePlagueStack		= "Announce $spell:70337 stacks to raid (10 stacks, every 5 after 10)<br/>(requires promoted status)"
}

L:SetMiscLocalization{
	LKPull					= "So the Light's vaunted justice has finally arrived? Shall I lay down Frostmourne and throw myself at your mercy, Fordring?",
	LKRoleplay				= "Is it truly righteousness that drives you? I wonder...",
	ValkGrabbedIcon			= "Valkyr Shadowguard {rt%d} grabbed %s",
	ValkGrabbed				= "Valkyr Shadowguard grabbed %s",
	PlagueStackWarning		= "Warning: %s has %d stacks of Necrotic Plague",
	AchievementCompleted	= ">> ACHIEVEMENT COMPLETE: %s has %d stacks of Necrotic Plague <<"
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
	TimerAdds		= "Show timer for new adds",
	warnCleaveArmor	= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(74367)
})

L:SetMiscLocalization({
	SummonMinions	= "Turn them to ash, minions!"
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
	TwilightCutterCast		= "Show warning when $spell:74769 is being cast",
	AnnounceAlternatePhase	= "Show warnings/timers for phase you aren't in as well"
})

L:SetMiscLocalization({
	Halion					= "Halion",
	MeteorCast				= "The heavens burn!",
	Phase2					= "You will find only suffering within the realm of twilight! Enter if you dare!",
	Phase3					= "I am the light and the darkness! Cower, mortals, before the herald of Deathwing!",
	twilightcutter			= "The orbiting spheres pulse with dark energy!",
	Kill					= "Relish this victory, mortals, for it will be your last. This world will burn with the master's return!"
})
