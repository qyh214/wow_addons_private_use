local RSA = RSA or LibStub("AceAddon-3.0"):GetAddon("RSA")
RSA.DefaultOptions = {}
local DefaultOptions = {
	profile = {
		Modules = {
			["*"] = false,
		},
		General = {
			["*"] = true,
			GlobalAnnouncements = {
				SmartSay = true,
				SmartYell = true,
				SmartEmote = true,
				SmartCustomChannel = true,
				Arena = true,
				Battlegrounds = false,
				InWarMode = false,
				InDungeon = true,
				InRaid = true,
				InLFG_Party = false,
				InLFG_Raid = false,
				InScenario = false,
				InWorld = false,
				OnlyInCombat = false,
				RemoveServerNames = true,
				AlwaysAllowWhispers = true,
			},
			Local = {
				["*"] = true,
			},
			GlobalCustomChannel = "MyCustomChannel",
			Replacements = {
				Target = {
					AlwaysUseName = false,
					Replacement = "You",
				},
				MissType = {
					UseGeneralReplacement = false,
					GeneralReplacement = "missed",
					Miss = "missed",
					Resist = "was resisted by",
					Absorb = "was absorbed by",
					Block = "was blocked by",
					Deflect = "was deflected by",
					Dodge = "was dodged by",
					Evade = "was evaded by",
					Parry = "was parried by",
					Immune = "immune",
					Reflect = "was reflected by",
				},
			},
		},
		Reminders = {
			DisableInPvP = true,
			EnableInSpec1 = true,
			EnableInSpec2 = false,
			CheckInterval = 10,
			RemindInterval = 15,
			RemindChannels = {
				["*"] = true,
			},
		},
		sink20OutputSink = "ChatFrame", -- Default for LibSink-2.0
	},
}

local function DeathKnight()
	local DeathKnight = {
		Reminders = {
			SpellName = "",
		},
		Spells = {
			Army = {
				Messages = {
					Cast = {"Casting [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			AMS = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			AMZ = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			DarkCommand = {
				Messages = {
					Cast = {"Taunted [TARGET]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			IceboundFortitude = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Strangulate = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Asphyxiate = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			MindFreeze = {
				Messages = {
					Interrupt = {"Mind Freezed [TARGET]'s [TARLINK]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			DeathGrip = {
				Messages = {
					Cast = {"Death Gripped [TARGET]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			VampiricBlood = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			RuneTap = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			DancingRuneWeapon = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			RaiseAlly = {
				Messages = {
					Cast = {"[LINK] cast on [TARGET]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
			},
			PillarOfFrost = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Purgatory = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Consumption = {
				Messages = {
					Start = {},
					Heal = {"[LINK] healed me for [AMOUNT]!"},
					Dummy = {""},
				},
				CustomChannel = {
					Channel = "",
				},
			},
		},
	}
	return DeathKnight
end
DefaultOptions.profile.DeathKnight = DeathKnight()

local function DemonHunter()
	local DemonHunter = {
		Reminders = {
			SpellName = "",
		},
		Spells = {
			SpectralSight = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Disrupt = {
				Messages = {
					Interrupt = {"Interrupted [TARGET]'s [TARLINK]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Blur = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Netherwalk = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			LastResort = {
				Messages = {
					Cast = {"[LINK] saved my life!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			MetamorphosisTank = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			MetamorphosisDD = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			FieryBrand = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			SigilOfChains = {
				Messages = {
					Cast = {"[LINK] placed!"},
					Start = {"[LINK] triggered!"},
					End = {"[LINK] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			SigilOfMisery = {
				Messages = {
					Cast = {"[LINK] placed!"},
					Start = {"[LINK] triggered!"},
					End = {"[LINK] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			SigilOfSilence = {
				Messages = {
					Cast = {"[LINK] placed!"},
					Start = {"[LINK] triggered!"},
					End = {"[LINK] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Torment = {
				Messages = {
					Cast = {"Taunted [TARGET]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			ChaosNova = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Darkness = {
				Messages = {
					Start = {"[LINK] activated!"},
					--End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Consume = { -- Consume Magic
				Messages = {
					Dispel = {"[LINK] on [TARGET] removed [AURALINK]!"},
					Resist = {"[TARGET] resisted [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			FelEruption = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Local = true,
			},
			Imprison = {
				Messages = {
					Cast = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
		},
	}
	return DemonHunter
end
DefaultOptions.profile.DemonHunter = DemonHunter()

local function Druid()
	local Druid = {
		Reminders = {
			SpellName = "",
		},
		Spells = {
			SurvivalInstincts = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Cyclone = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			IncapacitatingRoar = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			FrenziedRegeneration = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			UrsolsVortex = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Treants = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Ironbark = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			SkullBash = {
				Messages = {
					Interrupt = {"Interrupted [TARGET]'s [TARLINK]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Growl = {
				Messages = {
					Cast = {"Taunted [TARGET]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Revive = {
				Messages = {
					Start = {"Casting [LINK] on [TARGET]!"},
					End = {"Successfully resurrected [TARGET]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
				SmartGroup = true,
			},
			Rebirth = {
				Messages = {
					Start = {"Casting [LINK] on [TARGET]!"},
					End = {"Successfully resurrected [TARGET]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
				SmartGroup = true,
			},
			TreeOfLife = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Barkskin = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			MightyBash = {
				Messages = {
					Start = {"Stunned [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Tranquility = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			NaturesVigil = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Berserk = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			RemoveCorruption = {
				Messages = {
					Cast = {"Removed [TARGET]'s [AURALINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Roots = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			StampedingRoar = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			SolarBeam = {
				Messages = {
					Interrupt = {"Interrupted [TARGET]'s [TARLINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Revitalize = {
				Messages = {
					Start = {"Casting [LINK]!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Innervate = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Ironfur = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			DemoralizingRoar = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Soothe = {
				Messages = {
					Cast = {"Removed [TARGET]'s [AURALINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			MassEntanglement = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Hibernate = {
				Messages = {
					Cast = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
		}
	}
	return Druid
end
DefaultOptions.profile.Druid = Druid()

local function Hunter()
	local Hunter = {
		Reminders = {
			SpellName = "",
		},
		Spells = {
			Misdirection = {
				Messages = {
					Start = {"[LINK] started on [TARGET]!"},
					End = {"[LINK] on [TARGET] ended! Granted [AMOUNT] additional threat to [TARGET]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			ConcussiveShot = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Intimidation = {
				Messages = {
					Cast = {"Instructing pet to cast [LINK]."},
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			FreezingTrap = {
				Messages = {
					Placed = {"[LINK] placed!"},
					Start = {"[LINK] hit [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			SilencingShot = {
				Messages = {
					Interrupt = {"Interrupted [TARGET]'s [TARLINK]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Deterrence = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Camoflage = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			RoarOfSacrifice = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Muzzle = {
				Messages = {
					Interrupt = {"Interrupted [TARGET]'s [TARLINK]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			BindingShot = {
				Messages = {
					Placed = {"[LINK] placed!"},
					Start = {"[LINK] triggered!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Tranq = {
				Messages = {
					Cast = {"Removed [TARGET]'s [AURALINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			AncientHysteria = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			SpiritMend = {
				Messages = {
					Cast = {"[LINK] cast on [TARGET]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			BattleRess = {
				Messages = {
					Cast = {"[LINK] cast on [TARGET]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
				SmartGroup = true,
			},
		},
	}
	return Hunter
end
DefaultOptions.profile.Hunter = Hunter()

local function Mage()
	local Mage = {
		Reminders = {
			SpellName = "",
		},
		Spells = {
			TimeWarp = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Spellsteal = {
				Messages = {
					Cast = {"Stole [TARGET]'s [AURALINK]!"},
					Resist = {"[TARGET] resisted [LINK]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Polymorph = {
				Messages = {
					Cast = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Counterspell = {
				Messages = {
					Interrupt = {"Counterspelled [TARGET]'s [TARLINK]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Portals = {
				Messages = {
					Start = {"Casting [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Teleport = {
				Messages = {
					Start = {"Warning you are Teleporting, and leaving your friends behind!"},
				},
				Local = true,
			},
			RefreshmentTable = {
				Messages = {
					Start = {"Casting [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			RingOfFrost = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Cauterize = {
				Messages = {
					Start = {"[LINK] activated, please heal me!"},
					End = {"[LINK] faded, I'm no longer burning!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			IceBlock = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			SlowFall = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
			},
			RemoveCurse = { -- Remove Curse
				Messages = {
					Dispel = {"[LINK] on [TARGET] removed [AURALINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
		},
	}
	return Mage
end
DefaultOptions.profile.Mage = Mage()

local function Monk()
	local Monk = {
		Reminders = {
			SpellName = "",
		},
		Spells = {
			ZenMeditation = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Provoke = {
				Messages = {
					Cast = {"Taunted [TARGET]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
					StatueOfTheBlackOx = {"Taunted everything around [TARGET]"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			FortifyingBrew = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			SpearHandStrike = {
				Messages = {
					Interrupt = {"Interrupted [TARGET]'s [TARLINK]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Paralysis = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Guard = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			ElusiveBrew = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			PurifyingBrew = {
				Messages = {
					Cast = {"Used [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			DampenHarm = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			LifeCocoon = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			RingOfPeace = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			DiffuseMagic = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			TouchOfKarma = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Detox = {
				Messages = {
					Dispel = {"Removed [TARGET]'s [AURALINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Resuscitate = {
				Messages = {
					Start = {"Casting [LINK] on [TARGET]!"},
					End = {"Successfully resurrected [TARGET]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
				SmartGroup = true,
			},
			Revival = {
				Messages = {
					Cast = {"Casting [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			LegSweep = {
				Messages = {
					Cast = {"Casting [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Reawaken = {
				Messages = {
					Start = {"Casting [LINK]!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
		},
	}
	return Monk
end
DefaultOptions.profile.Monk = Monk()

local function Paladin()
	local Paladin = {
		Reminders = {
			SpellName = "",
		},
		Spells = {
			ArdentDefender = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
					Heal = {"[LINK] saved my life and healed me for [AMOUNT] hp!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			DevotionAura = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			DivineProtection = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Forbearance = {
				Messages = {
					Start = {},
					End = {"[LINK] on [TARGET] faded!"},
				},
				Local = true,
			},
			HandOfFreedom = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
			},
			HandOfProtection = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
			},
			HandOfSacrifice = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
			},
			BlessingOfSanctuary = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
			},
			ForgottenQueen = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
			},
			LayOnHands = {
				Messages = {
					Heal = {"[LINK] on [TARGET] for [AMOUNT]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			GoAK = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			HolyAvenger = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Repentance = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Rebuke = {
				Messages = {
					Interrupt = {"Interrupted [TARGET]'s [TARLINK]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			HandOfReckoning = {
				Messages = {
					Cast = {"Taunted [TARGET]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Beacon = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Local = true,
			},
			Redemption = {
				Messages = {
					Start = {"Casting [LINK] on [TARGET]!"},
					End = {"Successfully resurrected [TARGET]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
				SmartGroup = true,
			},
			AvengersShield = {
				Messages = {
					Interrupt = {"Interrupted [TARGET]'s [TARLINK]!"},
					Resist = {},
					Immune = {},
				},
				CustomChannel = {
					Channel = "",
				},
				Local = true,
			},
			HammerOfJustice = {
				Messages = {
					Start = {},
					End = {"[LINK] on [TARGET] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Cleanse = {
				Messages = {
					Dispel = {"Cleansed [TARGET]'s [AURALINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			DivineShield = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
					Disabled = "",
				},
				CustomChannel = {
					Channel = "",
				},
			},
			AvengingWrath = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			ShieldOfVengeance = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			FinalStand = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Absolution = {
				Messages = {
					Start = {"Casting [LINK]!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			AegisOfLight = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			EyeForAnEye = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
		},
	}
	return Paladin
end
DefaultOptions.profile.Paladin = Paladin()

local function Priest()
	local Priest = {
		Reminders = {
			SpellName = "",
		},
		Spells = {
			MassDispel = {
				Messages = {
					Start = {"Casting [LINK]!"},
					Cast = {"Casted [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			VampiricEmbrace = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			LeapOfFaith = {
				Messages = {
					Cast = {"Pulling [TARGET] to Me!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
			},
			DivineHymn = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Apotheosis = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Levitate = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			ShackleUndead = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Chastise = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			DispelMagic = {
				Messages = {
					Dispel = {"Dispelled [AURALINK] on [TARGET]!"},
					Resist = {"[TARGET] resisted [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Purify = {
				Messages = {
					Dispel = {"Removed [TARGET]'s [AURALINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			GuardianSpirit = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			PainSuppression = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			PowerWordBarrier = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Resurrection = {
				Messages = {
					Start = {"Casting [LINK] on [TARGET]!"},
					End = {"Successfully resurrected [TARGET]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
				SmartGroup = true,
			},
			Fade = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			PsychicScream = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			PsychicHorror = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			MindBomb = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			MindControl = {
				Messages = {
					Start = {"Casting [LINK] on [TARGET]!"},
					Cast = {"Mindcontrolling [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Silence = {
				Messages = {
					Cast = {"[LINK] cast on [TARGET]!"},
					Interrupt = {"Interrupted [TARGET]'s [TARLINK]!"},
					End = {"[LINK] on [TARGET] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			BodyAndSoul = {
				Messages = {
					Cast = {"[LINK] cast on [TARGET]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
			},
			Shadowfiend = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			SymbolOfHope = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			MassRess = {
				Messages = {
					Start = {"Casting [LINK]!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			DarkAngel = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Archangel = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			HolyWard = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			RayOfHope = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					Heal = {"[LINK] healed [TARGET] for [AMOUNT]!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Salvation = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
		},
	}
	return Priest
end
DefaultOptions.profile.Priest = Priest()

local function Rogue()
	local Rogue = {
		Reminders = {
			SpellName = "",
		},
		Spells = {
			Sap = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Blind = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Kick = {
				Messages = {
					Interrupt = {"Interrupted [TARGET]'s [TARLINK]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Tricks = {
				Messages = {
					Cast = {"[LINK] cast on [TARGET]!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
			},
			SmokeBomb = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Shroud = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			CloakOfShadows = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			BetweenTheEyes = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			KidneyShot = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			CheapShot = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Shiv = {
				Messages = {
					Dispel = {"[LINK] on [TARGET] removed [AURALINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
		},
	}
	return Rogue
end
DefaultOptions.profile.Rogue = Rogue()

local function Shaman()
	local Shaman = {
		Reminders = {
			SpellName = "",
		},
		Spells = {
			Hex = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] ended!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Heroism = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			WindShear = {
				Messages = {
					Interrupt = {"Interrupted [TARGET]'s [TARLINK]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Purge = {
				Messages = {
					Dispel = {"Purged [TARGET]'s [AURALINK]!"},
					Resist = {"[TARGET] resisted [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			CleanseSpirit = {
				Messages = {
					Dispel = {"Cleansed [TARGET]'s [AURALINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			HealingTide = {
				Messages = {
					Placed = {"[LINK] placed!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			EarthElemental = {
				Messages = {
					Start = {"[LINK] summoned!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			FireElemental = {
				Messages = {
					Start = {"[LINK] summoned!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			AncestralSpirit = {
				Messages = {
					Start = {"Casting [LINK] on [TARGET]!"},
					End = {"Successfully resurrected [TARGET]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
				SmartGroup = true,
			},
			SpiritLink = {
				Messages = {
					Placed = {"[LINK] placed!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			TremorTotem = {
				Messages = {
					Placed = {"[LINK] placed!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Thunderstorm = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			FeralSpirit = {
				Messages = {
					Cast = {"Casting [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Reincarnation = {
				Messages = {
					Cast = {"Resurrecting myself with [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			AncestralGuidance = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			AstralShift = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			WindRushTotem = {
				Messages = {
					Placed = {"[LINK] placed!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Ascendance = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			AncestralVision = {
				Messages = {
					Start = {"Casting [LINK]!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			AncestralProtection = {
				Messages = {
					Placed = {"[LINK] placed!"},
					Cast = {"[LINK] resurrected [TARGET]!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			LightningSurge = {
				Messages = {
					Placed = {"[LINK] placed!"},
					Cast = {"[LINK] activated!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Cloudburst = {
				Messages = {
					Placed = {"[LINK] placed!"},
					Heal = {"[LINK] healed for [AMOUNT]!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			EarthenShieldTotem = {
				Messages = {
					Placed = {"[LINK] placed!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			GroundingTotem = {
				Messages = {
					Placed = {"[LINK] placed!"},
					DamageAbsorb = {"[LINK] absorbed [AMOUNT] from [TARGET]'s [TARLINK]!"},
					EffectAbsorb = {"[LINK] absorbed [TARGET]'s [TARLINK]!"},
					End = {"[LINK] ended and absorbed [AMOUNT] enemy!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			EarthGrabTotem = {
				Messages = {
					Placed = {"[LINK] placed!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
		},
	}
	return Shaman
end
DefaultOptions.profile.Shaman = Shaman()

local function Warlock()
	local Warlock = {
		Reminders = {
			SpellName = "",
		},
		Spells = {
			SoulWell = {
				Messages = {
					Start = {"Casting [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			SummonStone = {
				Messages = {
					Start = {"Casting [LINK], please assist!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Suffering = {
				Messages = {
					Cast = {"Taunted [TARGET]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			SingeMagic = {
				Messages = {
					Dispel = {"[LINK] on [TARGET] removed [AURALINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Banish = {
				Messages = {
					Cast = {"Banished [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Fear = {
				Messages = {
					Cast = {"Fearing [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Seduce = {
				Messages = {
					Cast = {"Seducing [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			SpellLock = {
				Messages = {
					Interrupt = {"Interrupted [TARGET]'s [TARLINK]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Soulstone = {
				Messages = {
					Start = {"Casting [LINK] on [TARGET]!"},
					Cast = {"Successfully Soulstoned [TARGET]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
				SmartGroup = true,
			},
			DeathCoil = {
				Messages = {
					Cast = {"[LINK] cast on [TARGET]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Shadowfury = {
				Messages = {
					Start = {"Casting [LINK]!"},
					Cast = {"[LINK] activated!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			UnendingResolve = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Gateway = {
				Messages = {
					Cast = {"[LINK] placed!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			DarkPact = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			DevourMagic = {
				Messages = {
					Dispel = {"[LINK] on [TARGET] removed [AURALINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			AxeToss = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
		},
	}
	return Warlock
end
DefaultOptions.profile.Warlock = Warlock()

local function Warrior()
	local Warrior = {
		Reminders = {
			SpellName = "",
		},
		Spells = {
			ShieldWall = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Pummel = {
				Messages = {
					Interrupt = {"Pummeled [TARGET]'s [TARLINK]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			DemoralizingShout = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Taunt = {
				Messages = {
					Cast = {"Taunted [TARGET]!"},
					Resist = {"My [LINK] [MISSTYPE] [TARGET]!"},
					Immune = {"[TARGET] is immune to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			LastStand = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			EnragedRegeneration = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			SpellReflect = {
				Messages = {
					Damage = {"Reflected [TARGET]'s [LINK], dealing [AMOUNT]!"},
					Debuff = {"Reflected [TARGET]'s [LINK]!"},
					Resist = {"[TARGET] resisted it's own [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Recklessness = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			RallyingCry = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Intercept = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
			},
			DieByTheSword = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			StormBolt = {
				Messages = {
					Start = {"[LINK] cast on [TARGET]!"},
					End = {"[LINK] on [TARGET] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Shockwave = {
				Messages = {
					Start = {"[LINK] on [AMOUNT]!"},
					End = {"[LINK] has ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			NeltharionsFury = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			MassSpellReflection = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] faded!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			IntimidatingShout = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {"[LINK] ended!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
		},
	}
	return Warrior
end
DefaultOptions.profile.Warrior = Warrior()

local function Racials()
	local Racials = {
		Spells = {
			EMFH = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Stoneform = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Shadowmeld = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			EscapeArtist = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			GOTN = {
				Messages = {
					Cast = {"[LINK] cast on [TARGET]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Darkflight = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			BloodFury = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			WOTF = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			WarStomp = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Berserking = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			ArcaneTorrent = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			RocketJump = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			SpatialRift = {
				Messages = {
					Placed = {"[LINK] activated!"},
					Cast = {"Teleported to my [LINK]!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Fireblood = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			ArcanePulse = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			BullRush = {
				Messages = {
					Cast = {"[LINK] activated!"},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			AncestralCall = {
				Messages = {
					Start = {"[LINK] activated!"},
					End = {},
				},
				CustomChannel = {
					Channel = "",
				},
			},

		},
	}
	return Racials
end
DefaultOptions.profile.Racials = Racials()

local function Utilities()
	local Utilities = {
		Spells = {
			Jeeves = {
				Messages = {
					Placed = {"[LINK] cast by [TARGET]!"},
					End = {"[TARGET]'s [LINK] ended."},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Feasts = {
				Messages = {
					Placed = {"[LINK] placed by [TARGET]!"},
					End = {"[TARGET]'s [LINK] ended."},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Drums = {
				Messages = {
					Start = {"[LINK] used by [TARGET]!"},
					End = {"[LINK] faded."},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			Cauldrons = {
				Messages = {
					Start = {"[TARGET] placing a [LINK]!"},
					End = {"[LINK] ended."},
				},
				CustomChannel = {
					Channel = "",
				},
				SmartGroup = true,
			},
			SleepPotions = {
				Messages = {
					Start = {"Using [LINK]!"},
					End = {"[LINK] ended."},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			Codex = {
				Messages = {
					Start = {"[TARGET] placing a [LINK]!"},
					End = {"[LINK] ended."},
				},
				CustomChannel = {
					Channel = "",
				},
			},
			EngineerRessBFA = {
				Messages = {
					Cast = {"Used [LINK] on [TARGET]!", "Battle Ressed [TARGET]"},
					AcceptedRess = {"[TARGET] accepted my resurrect from [LINK]!", "[TARGET] is back in the fight!"},
				},
				CustomChannel = {
					Channel = "",
				},
				Whisper = true,
				SmartGroup = true,
			},
		},
	}
	return Utilities
end
DefaultOptions.profile.Utilities = Utilities()

RSA.DefaultOptions = DefaultOptions
