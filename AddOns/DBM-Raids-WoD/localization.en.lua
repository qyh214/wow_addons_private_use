local L

---------------
-- Kargath Bladefist --
---------------
L = DBM:GetModLocalization(1128)

L:SetTimerLocalization({
	timerSweeperCD	= "Next Arena Sweeper"
})

L:SetOptionLocalization({
	timerSweeperCD	= DBM_CORE_L.AUTO_TIMER_OPTIONS.next:format(177776)
})

---------------------------
-- Tectus, the Living Mountain --
---------------------------
L = DBM:GetModLocalization(1195)

L:SetMiscLocalization({
	pillarSpawn	= "RISE, MOUNTAINS!"
})

------------------
-- Brackenspore, Walker of the Deep --
------------------
L = DBM:GetModLocalization(1196)

L:SetOptionLocalization({
	InterruptCounter	= "Reset Decay counter after",
	Two					= "After two casts",
	Three				= "After three casts",
	Four				= "After four casts"
})

--------------
-- Twin Ogron --
--------------
L = DBM:GetModLocalization(1148)

L:SetOptionLocalization({
	PhemosSpecial		= "Play countdown sound for Phemos' cooldowns",
	PolSpecial			= "Play countdown sound for Pol's cooldowns",
	PhemosSpecialVoice	= "Play spoken alerts for Phemos' abilities using selected voice pack",
	PolSpecialVoice		= "Play spoken alerts for Pol's abilities using selected voice pack"
})

--------------------
--Koragh --
--------------------
L = DBM:GetModLocalization(1153)

L:SetWarningLocalization({
	specWarnExpelMagicFelFades	= "Fel fading in 5s - move to start"
})

L:SetOptionLocalization({
	specWarnExpelMagicFelFades	= "Show special warning to move to start position for $spell:172895 expiring"
})

L:SetMiscLocalization({
	supressionTarget1	= "I will crush you!",
	supressionTarget2	= "Silence!",
	supressionTarget3	= "Quiet!",
	supressionTarget4	= "I will tear you in half!"
})

--------------------------
-- Imperator Mar'gok --
--------------------------
L = DBM:GetModLocalization(1197)

L:SetTimerLocalization({
	timerNightTwistedCD	= "Next Night-Twisted Adds"
})

L:SetOptionLocalization({
	GazeYellType		= "Set yell type for Gaze of the Abyss",
	Countdown			= "Countdown until expires",
	Stacks				= "Stacks as they are applied",
	timerNightTwistedCD	= "Show timer for Next Night-Twisted Faithful",
	--Auto generated, don't copy to non english files, not needed.
	warnBranded			= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.stack:format(156225),
	warnResonance		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(156467),
	warnMarkOfChaos		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(158605),
	warnForceNova		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(157349),
	warnAberration		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.spell:format(156471)
	--Auto generated, don't copy to non english files, not needed.
})

L:SetMiscLocalization({
	BrandedYell		= "Branded (%d) %dy",
	GazeYell		= "Gaze fading in %d",
	GazeYell2		= "Gaze (%d) on %s",
	PlayerDebuffs	= "Closest to Glimpse"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("HighmaulTrash")

L:SetGeneralLocalization({
	name	= "Highmaul Trash"
})

---------------
-- Gruul --
---------------
L = DBM:GetModLocalization(1161)

L:SetOptionLocalization({
	MythicSoakBehavior	= "Set Mythic difficulty group soak preference for special warnings",
	ThreeGroup			= "3 Group 1 stack each strat",
	TwoGroup			= "2 Group 2 stacks each strat"
})

---------------------------
-- Oregorger, The Devourer --
---------------------------
L = DBM:GetModLocalization(1202)

L:SetOptionLocalization({
	InterruptBehavior	= "Set behavior for interrupt warnings",
	Smart				= "Interrupt warnings are based on bosses spine stacks",
	Fixed				= "Interrupts use a 5 or 3 sequence no matter what (even if boss doesn't)"
})

---------------------------
-- The Blast Furnace --
---------------------------
L = DBM:GetModLocalization(1154)

L:SetWarningLocalization({
	warnRegulators			= "Heat Regulator remaining: %d",
	warnBlastFrequency		= "Blast frequency increased: Approx Every %d sec",
	specWarnTwoVolatileFire	= "Double Volatile Fire on you!"
})

L:SetOptionLocalization({
	warnRegulators			= "Announce how many Heat Regulator remain",
	warnBlastFrequency		= "Announce when $spell:155209 frequency increased",
	specWarnTwoVolatileFire	= "Show special warning when you have double $spell:176121",
	InfoFrame				= "Show info frame for $spell:155192 and $spell:155196",
	VFYellType2				= "Set yell type for Volatile Fire (Mythic difficulty only)",
	Countdown				= "Countdown until expires",
	Apply					= "Only applied"
})

L:SetMiscLocalization({
	heatRegulator	= "Heat Regulator",
	Regulator		= "Regulator %d",--Can't use above, too long for infoframe
	bombNeeded		= "%d Bomb(s)"
})

--------------------------
-- Operator Thogar --
--------------------------
L = DBM:GetModLocalization(1147)

L:SetWarningLocalization({
	specWarnSplitSoon	= "Raid split in 10"
})

L:SetOptionLocalization({
	specWarnSplitSoon	= "Show special warning 10 seconds before raid split",
	InfoFrameSpeed		= "Set when InfoFrame shows next train information",
	Immediately			= "As soon as doors open for current train",
	Delayed				= "After current train has come out",
	HudMapUseIcons		= "Use raid Icons for HudMap instead of green circle",
	TrainVoiceAnnounce	= "Set when spoken alerts will play for trains",
	LanesOnly			= "Only announce incoming lanes",
	MovementsOnly		= "Only announce lane movements (Mythic Only)",
	LanesandMovements	= "Announce incoming lanes & movements (Mythic Only)"
})

L:SetMiscLocalization({
	Train			= "Train",
	lane			= "Lane",
	oneTrain		= "1 Random Lane: Train",
	oneRandom		= "Appear on 1 random lane",
	threeTrains		= "3 Random Lanes: Train",
	threeRandom		= "Appear on 3 random lanes",
	helperMessage	= "This encounter can be improved with 3rd party mod 'Thogar Assist' or one of many available DBM Voice packs (they audibly call out trains), available on Curse."
})

--------------------------
-- The Iron Maidens --
--------------------------
L = DBM:GetModLocalization(1203)

L:SetWarningLocalization({
	specWarnReturnBase	= "Return to dock!"
})

L:SetOptionLocalization({
	specWarnReturnBase	= "Show special warning when boat player can safely return to dock",
	filterBladeDash3	= "Do not show special warning for $spell:155794 when affected by $spell:170395",
	filterBloodRitual3	= "Do not show special warning for $spell:158078 when affected by $spell:170405"
})

L:SetMiscLocalization({
	shipMessage		= "prepares to man the Dreadnaught's Main Cannon!",
	EarlyBladeDash	= "Too slow!"
})

--------------------------
-- Blackhand --
--------------------------
L = DBM:GetModLocalization(959)

L:SetWarningLocalization({
	specWarnMFDPosition		= "Marked Position: %s",
	specWarnSlagPosition	= "Bomb Position: %s"
})

L:SetOptionLocalization({
	PositionsAllPhases	= "Give positions for $spell:156096 yells during all phases (Instead of just phase 3. This is mostly for testing and assurances, this option is not actually needed)",
	InfoFrame			= "Show info frame for $spell:155992 and $spell:156530"
})

L:SetMiscLocalization({
	customMFDSay	= "Marked %s on %s",
	customSlagSay	= "Bomb %s on %s"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("BlackrockFoundryTrash")

L:SetGeneralLocalization({
	name	= "Blackrock Foundry Trash"
})

---------------
-- Hellfire Assault --
---------------
L = DBM:GetModLocalization(1426)

L:SetTimerLocalization({
	timerSiegeVehicleCD	= "Next Vehicle %s",
})

L:SetOptionLocalization({
	timerSiegeVehicleCD	= "Show timer for when new siege vehicles spawn"
})

L:SetMiscLocalization({
	AddsSpawn1	= "Comin' in hot!",--Blizzard seems to have disabled these
	AddsSpawn2	= "Fire in the hole!",--Blizzard seems to have disabled these
	BossLeaving	= "I'll be back..."
})

---------------------------
-- Hellfire High Council --
---------------------------
L = DBM:GetModLocalization(1432)

L:SetWarningLocalization({
	reapDelayed	= "Reap after Visage ends"
})

L:SetOptionLocalization({
	reapDelayed	= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.soon:format(184476)
})

--------------
-- Kilrogg Deadeye --
--------------
L = DBM:GetModLocalization(1396)

L:SetMiscLocalization({
	BloodthirstersSoon	= "Come brothers! Seize your destiny!"
})

--------------------
--Gorefiend --
--------------------
L = DBM:GetModLocalization(1372)

L:SetTimerLocalization({
	SoDDPS2		= "Next Shadows (%s)",
	SoDTank2	= "Next Shadows (%s)",
	SoDHealer2	= "Next Shadows (%s)"
})

L:SetOptionLocalization({
	SoDDPS2			= "Show timer for next $spell:179864 affecting Damagers",
	SoDTank2		= "Show timer for next $spell:179864 affecting Tanks",
	SoDHealer2		= "Show timer for next $spell:179864 affecting Healers",
	ShowOnlyPlayer	= "Only show HudMap for $spell:179909 if you are a participant"
})

--------------------------
-- Shadow-Lord Iskar --
--------------------------
L = DBM:GetModLocalization(1433)

L:SetWarningLocalization({
	specWarnThrowAnzu	=	"Throw Eye of Anzu to %s!"
})

L:SetOptionLocalization({
	specWarnThrowAnzu	=	"Show special warning when you need to throw $spell:179202"
})

--------------------------
-- Fel Lord Zakuun --
--------------------------
L = DBM:GetModLocalization(1391)

L:SetOptionLocalization({
	SeedsBehavior	= "Set seeds yell behavior for raid (Requires raid leader)",
	Iconed			= "Star, Circle, Diamond, Triangle, Moon. Usuable for any strat using flare positions",--Default
	Numbered		= "1, 2, 3, 4, 5. Usable for any strat using numbered positions.",
	DirectionLine	= "Left, Middle Left, Middle, Middle Right, Right. Typical for straight line strat",
	FreeForAll		= "Free for all. Assign no positions, just use basic yell"
})

L:SetMiscLocalization({
	DBMConfigMsg	= "Seed configuration set to %s to match raid leaders configuration.",
	BWConfigMsg		= "Raid leader is using Bigwigs, DBM automatically configured to use Numbered."
})

--------------------------
-- Xhul'horac --
--------------------------
L = DBM:GetModLocalization(1447)

L:SetOptionLocalization({
	ChainsBehavior	= "Set Fel Chains warning behavior",
	Cast			= "Only give original target on cast start. Timer syncs to cast start.",
	Applied			= "Only give targets affected on cast end. Timer syncs to cast end.",
	Both			= "Give original target on cast start and targets affected on cast end."
})

--------------------------
-- Socrethar the Eternal --
--------------------------
L = DBM:GetModLocalization(1427)

L:SetOptionLocalization({
	InterruptBehavior	= "Set interrupt behavior for raid (Requires raid leader)",
	Count3Resume		= "3 person rotation that resumes where left off when barrier drops",--Default
	Count3Reset			= "3 person rotation that resets to 1 when barrier drops",
	Count4Resume		= "4 person rotation that resumes where left off when barrier drops",
	Count4Reset			= "4 person rotation that resets to 1 when barrier drops"
})

--------------------------
-- Mannoroth --
--------------------------
L = DBM:GetModLocalization(1395)

L:SetOptionLocalization({
	CustomAssignWrath	= "Set $spell:186348 icons based on player roles (Must be enabled by raid leader. May conflict with BW or out of date DBM versions)"
})

L:SetMiscLocalization({
	felSpire	= "begins to empower the Fel Spire!"
})

--------------------------
-- Archimonde --
--------------------------
L = DBM:GetModLocalization(1438)

L:SetWarningLocalization({
	specWarnBreakShackle	= "Shackled Torment: Break %s!"
})

L:SetOptionLocalization({
	specWarnBreakShackle	= "Show special warning when affected by $spell:184964. This warning auto assigns break order to minimize similtanious damage.",
	ExtendWroughtHud3		= "Extend the HUD lines beyond the $spell:185014 target (May diminish line accuracy)",
	AlternateHudLine		= "Use alternate line texture for HUD lines between $spell:185014 targets",
	NamesWroughtHud			= "Show player names HUD for $spell:185014 targets",
	FilterOtherPhase		= "Filter out warnings for events not in same phase as you",
	MarkBehavior			= "Set Mark of Legion yell behavior for raid (Requires raid leader)",
	Numbered				= "Star, Circle, Diamond, Triangle. Usable for any strat using flare positions.",--Default
	LocSmallFront			= "Melee L/R(Star,Circle), Ranged L/R(Diamond,Triangle). Short debuffs in melee.",
	LocSmallBack			= "Melee L/R(Star,Circle), Ranged L/R(Diamond,Triangle). Short debuffs at ranged.",
	NoAssignment			= "Disable all position yells/messages, icons, and HUD for entire raid.",
	overrideMarkOfLegion	= "Do not allow raid leader to override Mark of Legion behavior (Recommended only for experts that are confident their own settings do not conflict with raid leaders intent)"
})

L:SetMiscLocalization({
	phase2point5	= "Look upon the endless forces of the Burning Legion and know the folly of your resistance.",--3 seconds faster than CLEU, used as primary, slower CLEU secondary
	First			= "First",
	Second			= "Second",
	Third			= "Third"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("HellfireCitadelTrash")

L:SetGeneralLocalization({
	name	=	"Hellfire Citadel Trash"
})
