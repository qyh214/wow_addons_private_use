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
	TimerFirstSpecial		= "First special"
})

L:SetOptionLocalization({
	TimerFirstSpecial		= "Show next timer for the first special after $spell:105738<br/>(First special is random. Either $spell:105067 or $spell:104936)"
})

-------------------------------
--  Dark Iron Golem Council  --
-------------------------------
L = DBM:GetModLocalization(169)

L:SetWarningLocalization({
	SpecWarnActivated			= "Change Target to %s!",
	specWarnGenerator			= "Power Generator - Move %s!"
})

L:SetTimerLocalization({
	timerShadowConductorCast	= "Shadow Conductor",
	timerArcaneLockout			= "Annihilator Lockout",
	timerArcaneBlowbackCast		= "Arcane Blowback",
	timerNefAblity				= "Ability Buff CD"
})

L:SetOptionLocalization({
	timerShadowConductorCast	= "Show timer for $spell:92048 cast",
	timerArcaneLockout			= "Show timer for $spell:79710 spell lockout",
	timerArcaneBlowbackCast		= "Show timer for $spell:91879 cast",
	timerNefAblity				= "Show timer for heroic ability buff cooldown",
	SpecWarnActivated			= "Show special warning when new boss activated",
	specWarnGenerator			= "Show special warning when a boss gains $spell:79629",
	AcquiringTargetIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79501),
	ConductorIcon				= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79888),
	ShadowConductorIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92053),
	SetIconOnActivated			= "Set icon on last activated boss"
})

L:SetMiscLocalization({
	YellTargetLock				= "Encasing Shadows! Away from me!"
})

--------------
--  Magmaw  --
--------------
L = DBM:GetModLocalization(170)

L:SetWarningLocalization({
	SpecWarnInferno	= "Blazing Bone Construct Soon (~4s)"
})

L:SetOptionLocalization({
	SpecWarnInferno	= "Show pre-special warning for $spell:92154 (~4s)",
	RangeFrame		= "Show range frame in Phase 2 (5)"
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
	InfoFrame				= "Show info frame for $journal:3072",
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
	RangeFrame		= "Show range frame (6)",
	SetIconOnSlime	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82935),
	InfoFrame		= "Show info frame for health (<10k hp)"
})

L:SetMiscLocalization({
	HealthInfo	= "Health Info"
})

----------------
--  Maloriak  --
----------------
L = DBM:GetModLocalization(173)

L:SetWarningLocalization({
	WarnPhase			= "%s phase"
})

L:SetTimerLocalization({
	TimerPhase			= "Next phase"
})

L:SetOptionLocalization({
	WarnPhase			= "Show warning which phase is incoming",
	TimerPhase			= "Show timer for next phase",
	RangeFrame			= "Show range frame (6) during blue phase",
	SetTextures			= "Automatically disable projected textures in dark phase<br/>(returns it to enabled upon leaving phase)",
	FlashFreezeIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(77699),
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
	OnyTailSwipe			= "Tail Lash (Onyxia)",
	NefTailSwipe			= "Tail Lash (Nefarian)",
	OnyBreath				= "Breath (Onyxia)",
	NefBreath				= "Breath (Nefarian)",
	specWarnShadowblazeSoon	= "%s",
	warnShadowblazeSoon		= "%s"
})

L:SetTimerLocalization({
	timerNefLanding			= "Nefarian lands",
	OnySwipeTimer			= "Tail Lash CD (Ony)",
	NefSwipeTimer			= "Tail Lash CD (Nef)",
	OnyBreathTimer			= "Breath CD (Ony)",
	NefBreathTimer			= "Breath CD (Nef)"
})

L:SetOptionLocalization({
	OnyTailSwipe			= "Show warning for Onyxia's $spell:77827",
	NefTailSwipe			= "Show warning for Nefarian's $spell:77827",
	OnyBreath				= "Show warning for Onyxia's $spell:77826",
	NefBreath				= "Show warning for Nefarian's $spell:77826",
	specWarnCinderMove		= "Show special warning to move away when you are affected by<br/> $spell:79339 (5s before explosion)",
	warnShadowblazeSoon		= "Show pre-warning countdown for $spell:81031 (5s before)<br/>(Only after timer has been synced to first yell to ensure accuracy)",
	specWarnShadowblazeSoon	= "Show pre-special warning for $spell:81031<br/>(5s prewarn at first, 1s prewarn after first yell sync to ensure accuracy)",
	timerNefLanding			= "Show timer for when Nefarian lands",
	OnySwipeTimer			= "Show timer for Onyxia's $spell:77827 cooldown",
	NefSwipeTimer			= "Show timer for Nefarian's $spell:77827 cooldown",
	OnyBreathTimer			= "Show timer for Onyxia's $spell:77826 cooldown",
	NefBreathTimer			= "Show timer for Nefarian's $spell:77826 cooldown",
	InfoFrame				= "Show info frame for $journal:3284",
	SetWater				= "Automatically disable water collision on pull<br/>(returns it to enabled upon leaving combat)",
	SetIconOnCinder			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79339),
	RangeFrame				= "Show range frame (10) for $spell:79339<br/>(Shows everyone if you have debuff, only players with debuff if not)"
})

L:SetMiscLocalization({
	NefAoe					= "The air crackles with electricity!",
	YellPhase2				= "Curse you, mortals! Such a callous disregard for one's possessions must be met with extreme force!",
	YellPhase3				= "I have tried to be an accommodating host, but you simply will not die! Time to throw all pretense aside and just... KILL YOU ALL!",
	YellShadowBlaze			= "Flesh turns to ash!",
	ShadowBlazeExact		= "Shadowblaze Spark in %ds",
	ShadowBlazeEstimate		= "Shadowblaze Spark soon (~5s)"
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
L = DBM:GetModLocalization(156)

L:SetOptionLocalization({
	ShowDrakeHealth		= "Show the health of released drakes<br/>(Requires Boss Health enabled)"
})

---------------------------
--  Valiona & Theralion  --
---------------------------
L = DBM:GetModLocalization(157)

L:SetOptionLocalization({
	TBwarnWhileBlackout		= "Show $spell:86369 warning when $spell:86788 active",
	TwilightBlastArrow		= "Show DBM arrow when $spell:86369 is near you",
	RangeFrame				= "Show range frame (10)",
	BlackoutShieldFrame		= "Show boss health with a health bar for $spell:86788",
	BlackoutIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(86788),
	EngulfingIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(86622)
})

L:SetMiscLocalization({
	Trigger1				= "Deep Breath",
	BlackoutTarget			= "Blackout: %s"
})

----------------------------------
--  Twilight Ascendant Council  --
----------------------------------
L = DBM:GetModLocalization(158)

L:SetWarningLocalization({
	specWarnBossLow			= "%s below 30%% - next phase soon!",
	SpecWarnGrounded		= "Get Grounded",
	SpecWarnSearingWinds	= "Get Searing Winds"
})

L:SetTimerLocalization({
	timerTransition			= "Phase Transition"
})

L:SetOptionLocalization({
	specWarnBossLow			= "Show special warning when Bosses are below 30% HP",
	SpecWarnGrounded		= "Show special warning when you are missing $spell:83581 debuff<br/>(~10sec before cast)",
	SpecWarnSearingWinds	= "Show special warning when you are missing $spell:83500 debuff<br/>(~10sec before cast)",
	timerTransition			= "Show Phase transition timer",
	RangeFrame				= "Show range frame automatically when needed",
	yellScrewed				= "Yell when you have $spell:83099 &amp; $spell:92307 at same time",
	InfoFrame				= "Show info frame for players without $spell:83581 or $spell:83500",
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
	blizzHatesMe	= "Beacon & Rod on me! Clear a path!",--Very bad situation.
	WrongDebuff		= "No %s"
})

----------------
--  Cho'gall  --
----------------
L = DBM:GetModLocalization(167)

L:SetOptionLocalization({
	CorruptingCrashArrow	= "Show DBM arrow when $spell:81685 is near you",
	InfoFrame				= "Show info frame for $journal:3165",
	RangeFrame				= "Show range frame (5) for $journal:3165",
	SetIconOnWorship		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(91317)
})

----------------
--  Sinestra  --
----------------
L = DBM:GetModLocalization(168)

L:SetWarningLocalization({
	WarnOrbSoon			= "Orbs in %d sec!",
	SpecWarnOrbs		= "Orbs coming! Watch Out!",
	warnWrackJump		= "%s jumped to >%s<",
	warnAggro			= "Players with Aggro (Orbs candidates): >%s< ",
	SpecWarnAggroOnYou	= "You have Aggro! Watch Orbs!"
})

L:SetTimerLocalization({
	TimerEggWeakening	= "Twilight Carapace dissipates",
	TimerEggWeaken		= "Twilight Capapace Regenerates",
	TimerOrbs			= "Shadow Orbs CD"
})

L:SetOptionLocalization({
	WarnOrbSoon			= "Show pre-warning for Orbs (Before 5s, Every 1s)<br/>(Expected warning. may not be accurate. Can be spammy.)",
	warnWrackJump		= "Announce $spell:89421 jump targets",
	warnAggro			= "Announce players who have Aggro when Orbs spawn (Can be target of Orbs)",
	SpecWarnAggroOnYou	= "Show special warning if you have Aggro when Orbs spawn<br/>(Can be target of Orbs)",
	SpecWarnOrbs		= "Show special warning when Orbs spawn (Expected warning)",
	TimerEggWeakening	= "Show timer for when $spell:87654 dissipates",
	TimerEggWeaken		= "Show timer for $spell:87654 regeneration",
	TimerOrbs			= "Show timer for next Orbs (Expected timer. may not be accurate)",
	SetIconOnOrbs		= "Set icons on players who have Aggro when Orbs spawn<br/>(Can be target of Orbs)",
	InfoFrame			= "Show info frame for players who have aggro"
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
	name =	"The Bastion of Twilight Trash"
})

------------------------
--  Conclave of Wind  --
------------------------
L = DBM:GetModLocalization(154)

L:SetWarningLocalization({
	warnSpecial			= "Hurricane/Zephyr/Sleet Storm Active",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial		= "Special Abilities Active!",
	warnSpecialSoon		= "Special Abilities in 10 seconds!"
})

L:SetTimerLocalization({
	timerSpecial		= "Special Abilities CD",
	timerSpecialActive	= "Special Abilities Active"
})

L:SetOptionLocalization({
	warnSpecial			= "Show warning when Hurricane/Zephyr/Sleet Storm are cast",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial		= "Show special warning when special abilities are cast",
	timerSpecial		= "Show timer for special abilities cooldown",
	timerSpecialActive	= "Show timer for special abilities duration",
	warnSpecialSoon		= "Show pre-warning 10 seconds before special abilities",
	OnlyWarnforMyTarget	= "Only show warnings/timers for current &amp; focus targets<br/>(Hides the rest. THIS INCLUDES PULL)"
})

L:SetMiscLocalization({
	gatherstrength	= "begins to gather strength"
})

---------------
--  Al'Akir  --
---------------
L = DBM:GetModLocalization(155)

L:SetTimerLocalization({
	TimerFeedback 	= "Feedback (%d)"
})

L:SetOptionLocalization({
	LightningRodIcon= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(89668),
	TimerFeedback	= "Show timer for $spell:87904 duration",
	RangeFrame		= "Show range frame (20) when affected by $spell:89668"
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
	WarnPhase			= "Phase %d",
	WarnNewInitiate		= "Blazing Talon Initiate (%s)"
})

L:SetTimerLocalization({
	TimerPhaseChange	= "Phase %d",
	TimerHatchEggs		= "Next Eggs",
	timerNextInitiate	= "Next Initiate (%s)"
})

L:SetOptionLocalization({
	WarnPhase			= "Show a warning for each phase change",
	WarnNewInitiate		= "Show a warning for new Blazing Talon Initiate",
	timerNextInitiate	= "Show a timer for next Blazing Talon Initiate",
	TimerPhaseChange	= "Show a timer till next phase",
	TimerHatchEggs		= "Show a timer till next eggs are hatched"
})

L:SetMiscLocalization({
	YellPull		= "I serve a new master now, mortals!",
	YellPhase2		= "These skies are MINE!",
	LavaWorms		= "Fiery Lava Worms erupt from the ground!",--Might use this one day if i feel it needs a warning for something. Or maybe pre warning for something else (like transition soon)
	East			= "East",
	West			= "West",
	Both			= "Both"
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
	timerStrike			= "Next %s",
	TimerBladeActive	= "%s",
	TimerBladeNext		= "Next blade"
})

L:SetOptionLocalization({
	ResetShardsinThrees	= "Restart $spell:99259 count in sets of 3s(25m)/2s(10m)",
	warnStrike			= "Show warnings for Decimation/Inferno Strike",
	timerStrike			= "Show timer for next Decimation/Inferno Strike",
	TimerBladeActive	= "Show a duration timer for the active Blade",
	TimerBladeNext		= "Show a next timer for Decimation/Inferno Blade"
})

--------------------------------
-- Majordomo Fandral Staghelm --
--------------------------------
L= DBM:GetModLocalization(197)

L:SetTimerLocalization({
	timerNextSpecial	= "Next %s (%d)"
})

L:SetOptionLocalization({
	timerNextSpecial			= "Show timer for next special ability",
	RangeFrameSeeds				= "Show range frame (12) for $spell:98450",
	RangeFrameCat				= "Show range frame (10) for $spell:98374"
})

--------------
-- Ragnaros --
--------------
L= DBM:GetModLocalization(198)

L:SetWarningLocalization({
	warnRageRagnarosSoon	= "%s on %s in 5 sec",--Spellname on targetname
	warnSplittingBlow		= "%s in %s",--Spellname in Location
	warnEngulfingFlame		= "%s in %s",--Spellname in Location
	warnEmpoweredSulf		= "%s in 5 sec"--The spell has a 5 second channel, but tooltip doesn't reflect it so cannot auto localize
})

L:SetTimerLocalization({
	timerRageRagnaros		= "%s on %s",--Spellname on targetname
	TimerPhaseSons			= "Transition ends"
})

L:SetOptionLocalization({
	warnRageRagnarosSoon		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.prewarn:format(101109),
	warnSplittingBlow			= "Show location warnings for $spell:98951",
	warnEngulfingFlame			= "Show location warnings for $spell:99171 on normal",
	warnEngulfingFlameHeroic	= "Show location warnings for $spell:99171 on heroic",
	warnSeedsLand				= "Show warning/timer for $spell:98520 landing instead of seed casts.",
	warnEmpoweredSulf			= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.cast:format(100604),
	timerRageRagnaros			= DBM_CORE_L.AUTO_TIMER_OPTIONS.cast:format(101109),
	TimerPhaseSons				= "Show a duration timer for the \"Sons of Flame phase\"",
	InfoHealthFrame				= "Show info frame for health (<100k hp)",
	MeteorFrame					= "Show info frame for $spell:99849 targets",
	AggroFrame					= "Show info frame for players who have no aggro during $journal:2647"
})

L:SetMiscLocalization({
	East				= "East",
	West				= "West",
	Middle				= "Middle",
	North				= "Melee",
	South				= "Back",
	HealthInfo			= "Under 100k HP",
	HasNoAggro			= "No Aggro",
	MeteorTargets		= "ZOMG Meteors!",--Keep rollin' rollin' rollin' rollin'.
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
	name = "Firelands Trash"
})

----------------
--  Volcanus  --
----------------
L = DBM:GetModLocalization("Volcanus")

L:SetGeneralLocalization({
	name = "Volcanus"
})

L:SetTimerLocalization({
	timerStaffTransition	= "Transition ends"
})

L:SetOptionLocalization({
	timerStaffTransition	= "Show a timer for the phase transition"
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
	name = "Thyrinar"
})

-------------
-- Morchok --
-------------
L= DBM:GetModLocalization(311)

L:SetWarningLocalization({
	KohcromWarning	= "%s: %s"--Bossname, spellname. At least with this we can get boss name from casts in this one, unlike a timer started off the previous bosses casts.
})

L:SetTimerLocalization({
	KohcromCD		= "Kohcrom mimicks %s",--Universal single local timer used for all of his mimick timers
})

L:SetOptionLocalization({
	KohcromWarning	= "Show warnings for $journal:4262 mimicking abilities.",
	KohcromCD		= "Show timers for $journal:4262's next ability mimick.",
	RangeFrame		= "Show range frame (5) for achievement."
})

L:SetMiscLocalization({
})

---------------------
-- Warlord Zon'ozz --
---------------------
L= DBM:GetModLocalization(324)

L:SetOptionLocalization({
	ShadowYell			= "Yell when you are affected by $spell:103434<br/>(Heroic difficulty only)",
	CustomRangeFrame	= "Range Frame options (Heroic only)",
	Never				= "Disabled",
	Normal				= "Normal Range Frame",
	DynamicPhase2		= "Phase2 Debuff Filtering",
	DynamicAlways		= "Always Debuff Filtering"
})

L:SetMiscLocalization({
	voidYell	= "Gul'kafh an'qov N'Zoth."--Start translating the yell he does for Void of the Unmaking cast, the latest logs from DS indicate blizz removed the event that detected casts. sigh.
})

-----------------------------
-- Yor'sahj the Unsleeping --
-----------------------------
L= DBM:GetModLocalization(325)

L:SetWarningLocalization({
	warnOozesHit	= "%s absorbed %s"
})

L:SetTimerLocalization({
	timerOozesActive	= "Oozes Attackable",
	timerOozesReach		= "Oozes Reach Boss"
})

L:SetOptionLocalization({
	warnOozesHit		= "Announce what oozes hit the boss",
	timerOozesActive	= "Show timer for when Oozes become attackable",
	timerOozesReach		= "Show timer for when Oozes reach Yor'sahj",
	RangeFrame			= "Show range frame (4) for $spell:104898<br/>(Normal+ difficulty)"
})

L:SetMiscLocalization({
	Black			= "|cFF424242black|r",
	Purple			= "|cFF9932CDpurple|r",
	Red				= "|cFFFF0404red|r",
	Green			= "|cFF088A08green|r",
	Blue			= "|cFF0080FFblue|r",
	Yellow			= "|cFFFFA901yellow|r"
})

-----------------------
-- Hagara the Binder --
-----------------------
L= DBM:GetModLocalization(317)

L:SetWarningLocalization({
	WarnPillars				= "%s: %d left",
	warnFrostTombCast		= "%s in 8 sec"
})

L:SetTimerLocalization({
	TimerSpecial			= "First Special"
})

L:SetOptionLocalization({
	WarnPillars				= "Announce how many $journal:3919 or $journal:4069 are left",
	TimerSpecial			= "Show timer for first special ability cast",
	RangeFrame				= "Show range frame: (3) for $spell:105269, (10) for $journal:4327",
	AnnounceFrostTombIcons	= "Announce icons for $spell:104451 targets to raid chat<br/>(requires raid leader)",
	warnFrostTombCast		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.cast:format(104448),
	SetIconOnFrostTomb		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(104451),
	SetIconOnFrostflake		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(109325),
	SpecialCount			= "Play countdown sound for $spell:105256 or $spell:105465",
	SetBubbles				= "Automatically disable chat bubbles when $spell:104451 available<br/>(restores them when combat ends)"
})

L:SetMiscLocalization({
	TombIconSet				= "Frost Beacon icon {rt%d} set on %s"
})

---------------
-- Ultraxion --
---------------
L= DBM:GetModLocalization(331)

L:SetWarningLocalization({
	specWarnHourofTwilightN		= "%s (%d) in 5s"--spellname Count
})

L:SetTimerLocalization({
	TimerCombatStart	= "Ultraxion Active"
})

L:SetOptionLocalization({
	TimerCombatStart	= "Show timer for Ultraxion RP",
	ResetHoTCounter		= "Restart Hour of Twilight counter",--$spell doesn't work in this function apparently so use typed spellname for now.
	Never				= "Never",
	ResetDynamic		= "Reset in sets of 3/2 (heroic/normal)",
	Reset3Always		= "Always Reset in sets of 3",
	SpecWarnHoTN		= "Special warn 5s before Hour of Twilight. If counter reset is Never, this follows 3set rule",
	One					= "1 (ie 1 4 7)",
	Two					= "2 (ie 2 5)",
	Three				= "3 (ie 3 6)"
})

L:SetMiscLocalization({
	Pull				= "I sense a great disturbance in the balance approaching. The chaos of it burns my mind!"
})

-------------------------
-- Warmaster Blackhorn --
-------------------------
L= DBM:GetModLocalization(332)

L:SetWarningLocalization({
	SpecWarnElites	= "Twilight Elites!"
})

L:SetTimerLocalization({
	TimerAdd			= "Next Elites"
})

L:SetOptionLocalization({
	TimerAdd			= "Show timer for next Twilight Elites spawn",
	SpecWarnElites		= "Show special warning for new Twilight Elites",
	SetTextures			= "Automatically disable projected textures in phase 1<br/>(returns it to enabled in phase 2)"
})

L:SetMiscLocalization({
	Pull				= "All ahead full. Everything depends on our speed! We can't let the Destroyer get away.",
	SapperEmote			= "A drake swoops down to drop a Twilight Sapper onto the deck!",
	GorionaRetreat		= "screeches in pain and retreats into the swirling clouds"
})

-------------------------
-- Spine of Deathwing  --
-------------------------
L= DBM:GetModLocalization(318)

L:SetWarningLocalization({
	warnSealArmor			= "%s",
	SpecWarnTendril			= "Get Secured!"
})

L:SetOptionLocalization({
	warnSealArmor			= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.cast:format(105847),
	SpecWarnTendril			= "Show special warning when you are missing $spell:105563 debuff",
	InfoFrame				= "Show info frame for players without $spell:105563",
	SetIconOnGrip			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(105490),
	ShowShieldInfo			= "Show absorb bar for $spell:105479<br/>(Ignores boss health frame option)"
})

L:SetMiscLocalization({
	Pull			= "The plates! He's coming apart! Tear up the plates and we've got a shot at bringing him down!",
	NoDebuff		= "No %s",
	PlasmaTarget	= "Searing Plasma: %s",
	DRoll			= "about to roll",
	DLevels			= "levels out"
})

---------------------------
-- Madness of Deathwing  --
---------------------------
L= DBM:GetModLocalization(333)

L:SetOptionLocalization({
	RangeFrame			= "Show dynamic range frame based on player debuff status for<br/>$spell:108649 on Heroic difficulty",
	SetIconOnParasite	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(108649)
})

L:SetMiscLocalization({
	Pull				= "You have done NOTHING. I will tear your world APART."
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("DSTrash")

L:SetGeneralLocalization({
	name =	"Dragonsoul Trash"
})

L:SetWarningLocalization({
	DrakesLeft			= "Twilight Assaulter remaining: %d"
})

L:SetTimerLocalization({
	timerRoleplay		= GUILD_INTEREST_RP,
	TimerDrakes			= "%s"--spellname from mod
})

L:SetOptionLocalization({
	DrakesLeft			= "Announce how many Twilight Assaulters remain",
	TimerDrakes			= "Show timer for when Twilight Assaulters $spell:109904"
})

L:SetMiscLocalization({
	firstRP				= "Praise the Titans, they have returned!",
	UltraxionTrash		= "It is good to see you again, Alexstrasza. I have been busy in my absence.",
	UltraxionTrashEnded = "Mere whelps, experiments, a means to a greater end. You will see what the research of my clutch has yielded."
})
