local addonName, DF = ...

-- ============================================================
-- AURA DESIGNER CONFIG
-- Spec-specific aura display definitions for the adapter stub
-- ============================================================

local pairs = pairs

-- Initialize the AuraDesigner namespace
DF.AuraDesigner = DF.AuraDesigner or {}

-- ============================================================
-- SPEC MAP
-- Maps CLASS_SPECNUM to internal spec key
-- ============================================================
DF.AuraDesigner.SpecMap = {
    DRUID_4     = "RestorationDruid",
    SHAMAN_3    = "RestorationShaman",
    PRIEST_1    = "DisciplinePriest",
    PRIEST_2    = "HolyPriest",
    PALADIN_1   = "HolyPaladin",
    EVOKER_2    = "PreservationEvoker",
    EVOKER_3    = "AugmentationEvoker",
    MONK_2      = "MistweaverMonk",
}

-- ============================================================
-- SPEC INFO
-- Display names and class tokens for each supported spec
-- ============================================================
DF.AuraDesigner.SpecInfo = {
    PreservationEvoker  = { display = "Preservation Evoker",  class = "EVOKER"  },
    AugmentationEvoker  = { display = "Augmentation Evoker",  class = "EVOKER"  },
    RestorationDruid    = { display = "Restoration Druid",    class = "DRUID"   },
    DisciplinePriest    = { display = "Discipline Priest",    class = "PRIEST"  },
    HolyPriest          = { display = "Holy Priest",          class = "PRIEST"  },
    MistweaverMonk      = { display = "Mistweaver Monk",      class = "MONK"    },
    RestorationShaman   = { display = "Restoration Shaman",   class = "SHAMAN"  },
    HolyPaladin         = { display = "Holy Paladin",         class = "PALADIN" },
}

-- ============================================================
-- STATIC ICON TEXTURES
-- Hardcoded texture IDs for the Aura Designer GUI tiles.
-- C_Spell.GetSpellTexture() dynamically swaps icons when a
-- talent choice node replaces a spell (e.g. Beacon of Virtue
-- replaces Beacon of Light), causing both tiles to show the
-- same icon. Static IDs avoid this entirely.
-- ============================================================
DF.AuraDesigner.IconTextures = {
    -- Preservation Evoker
    Echo                = 4622456,
    Reversion           = 4630467,
    EchoReversion       = 4630469,
    DreamBreath         = 4622454,
    EchoDreamBreath     = 7439198,
    DreamFlight         = 4622455,
    Lifebind            = 4630453,
    TimeDilation        = 4622478,
    Rewind              = 4622474,
    VerdantEmbrace      = 4622471,
    -- Augmentation Evoker
    Prescience          = 5199639,
    ShiftingSands       = 5199633,
    BlisteringScales    = 5199621,
    InfernosBlessing    = 5199632,
    SymbioticBloom      = 4554354,
    EbonMight           = 5061347,
    SourceOfMagic       = 4630412,
    SensePower          = 132160,
    -- Restoration Druid
    Rejuvenation        = 136081,
    Regrowth            = 136085,
    Lifebloom           = 134206,
    Germination         = 1033478,
    WildGrowth          = 236153,
    SymbioticRelationship = 1408837,
    SymbioticBlooms     = 463540,
    IronBark            = 572025,
    -- Discipline Priest
    PowerWordShield     = 135940,
    Atonement           = 458720,
    VoidShield          = 7514191,
    PrayerOfMending     = 135944,
    PainSuppression     = 135936,
    PowerInfusion       = 135939,
    -- Holy Priest
    Renew               = 135953,
    EchoOfLight         = 237537,
    GuardianSpirit      = 237542,
    -- Mistweaver Monk
    RenewingMist        = 627487,
    EnvelopingMist      = 775461,
    SoothingMist        = 606550,
    AspectOfHarmony     = 5927638,
    LifeCocoon          = 627485,
    StrengthOfTheBlackOx = 615340,
    -- Restoration Shaman
    Riptide             = 252995,
    EarthShield         = 136089,
    AncestralVigor      = 237574,
    EarthlivingWeapon   = 237578,
    Hydrobubble         = 1320371,
    -- Holy Paladin
    BeaconOfFaith       = 1030095,
    EternalFlame        = 135433,
    BeaconOfLight       = 236247,
    BeaconOfVirtue      = 1030094,
    BeaconOfTheSavior   = 7514188,
    BlessingOfProtection = 135964,
    HolyArmaments       = 5927636,
    BlessingOfSacrifice = 135966,
    BlessingOfFreedom   = 135968,
    Dawnlight           = 5927633,
}

-- ============================================================
-- TOOLTIP SPELL ID OVERRIDES
-- Some aura spell IDs are internal/secret and produce wrong tooltips
-- (e.g. 409895 shows "Upheaval" instead of "Verdant Embrace").
-- Map aura name → castable spell ID for correct tooltip display.
-- ============================================================
DF.AuraDesigner.TooltipSpellIDs = {
    VerdantEmbrace = 360995,
    EbonMight = 395296,
}

-- ============================================================
-- SPELL IDS PER SPEC
-- Used for runtime aura matching via reverse spell ID lookup
-- ============================================================
DF.AuraDesigner.SpellIDs = {
    PreservationEvoker = {
        Echo = 364343, Reversion = 366155, EchoReversion = 367364,
        DreamBreath = 355941, EchoDreamBreath = 376788,
        DreamFlight = 363502, Lifebind = 373267,
        TimeDilation = 357170, Rewind = 363534, VerdantEmbrace = 409895,
    },
    AugmentationEvoker = {
        Prescience = 410089, ShiftingSands = 413984, BlisteringScales = 360827,
        InfernosBlessing = 410263, SymbioticBloom = 410686, EbonMight = 395152,
        SourceOfMagic = 369459,
        SensePower = 361022,
    },
    RestorationDruid = {
        Rejuvenation = 774, Regrowth = 8936, Lifebloom = 33763,
        Germination = 155777, WildGrowth = 48438, SymbioticRelationship = 474754,
        SymbioticBlooms = 439530, IronBark = 102342,
    },
    DisciplinePriest = {
        PowerWordShield = 17, Atonement = 194384,
        VoidShield = 1253593, PrayerOfMending = 41635,
        PainSuppression = 33206, PowerInfusion = 10060,
    },
    HolyPriest = {
        Renew = 139, EchoOfLight = 77489,
        PrayerOfMending = 41635,
        GuardianSpirit = 47788, PowerInfusion = 10060,
    },
    MistweaverMonk = {
        RenewingMist = 119611, EnvelopingMist = 124682, SoothingMist = 115175,
        AspectOfHarmony = 450769,
        LifeCocoon = 116849, StrengthOfTheBlackOx = 443113,
    },
    RestorationShaman = {
        Riptide = 61295, EarthShield = 383648,
        AncestralVigor = 207400,
        EarthlivingWeapon = 382024,
        Hydrobubble = 444490,
    },
    HolyPaladin = {
        BeaconOfFaith = 156910, EternalFlame = 156322, BeaconOfLight = 53563,
        BeaconOfTheSavior = 1244893, BeaconOfVirtue = 200025,
        BlessingOfProtection = 1022, HolyArmaments = 432502,
        BlessingOfSacrifice = 6940, BlessingOfFreedom = 1044,
        Dawnlight = 431381,
    },
}

-- ============================================================
-- SELF-ONLY SPELL IDS
-- Auras that only appear on the caster (player unit) but are
-- sourced by another unit (e.g. Symbiotic Relationship buff
-- appears on the druid but sourceUnit is the target).
-- These need a separate "HELPFUL" scan (without PLAYER filter)
-- restricted to the player unit only.
-- ============================================================
DF.AuraDesigner.SelfOnlySpellIDs = {
    RestorationDruid = {
        [474754] = "SymbioticRelationship",
    },
    AugmentationEvoker = {
        [395296] = "EbonMight",      -- caster self-buff (secret in combat, readable OOC)
    },
}

-- ============================================================
-- ALTERNATE SPELL IDS
-- Some spells have multiple IDs (e.g. Earth Shield).
-- These are merged into the reverse lookup so both IDs resolve
-- to the same aura name.
-- ============================================================
DF.AuraDesigner.AlternateSpellIDs = {
    RestorationShaman = {
        [974] = "EarthShield",  -- alternate ID for Earth Shield (primary is 383648)
        [382021] = "EarthlivingWeapon",  -- alternate ID (primary is 382024)
        [382022] = "EarthlivingWeapon",  -- alternate ID (primary is 382024)
    },
    HolyPaladin = {
        -- Holy Bulwark (shield) and Sacred Weapon (weapon) are the two
        -- variants of Armament of Light. They share signature "0:1:0:0"
        -- and cannot be distinguished via the aura API, so we track
        -- them as a single "HolyArmaments" indicator.
        [432496] = "HolyArmaments",  -- Holy Bulwark (primary is 432502 / Sacred Weapon)
    },
}

-- ============================================================
-- LINKED AURA RULES
-- Defines inference rules for auras where only one side (caster
-- or target) has a readable spell ID.
--   caster_to_target: Player has readable source buff, infer onto target
--   target_to_caster: Party member has readable buff, infer onto player
-- ============================================================
DF.AuraDesigner.LinkedAuraRules = {
    RestorationDruid = {
        SymbioticRelationship = {
            type = "caster_to_target",
            sourceSpellID = 474754,             -- readable on caster (player)
            targetSpellIDs = { 474750, 474760 }, -- secret on target in combat (dedup from buff bar)
        },
    },
}

-- ============================================================
-- SECRET AURA FINGERPRINTS
-- Identifies auras with secret spell IDs using filter fingerprinting.
-- Each aura's fingerprint = which WoW filter strings it passes + point count.
-- Credit: Filter fingerprinting technique and aura data from Harrek's
-- Advanced Raid Frames (used with permission, credit to Harrek).
-- ============================================================
DF.AuraDesigner.SecretAuraInfo = {
    PreservationEvoker = {
        auras = {
            TimeDilation   = { signature = "1:1:1:0" },
            Rewind         = { signature = "1:1:0:0" },
            VerdantEmbrace = { signature = "0:1:0:0" },
        },
        casts = {
            [357170] = { "TimeDilation" },
            [363534] = { "Rewind" },
            [360995] = { "Lifebind", "VerdantEmbrace" },
        },
    },
    RestorationDruid = {
        auras = {
            IronBark = { signature = "1:1:1:0" },
        },
        casts = {
            [102342] = { "IronBark" },
        },
    },
    DisciplinePriest = {
        auras = {
            PainSuppression = { signature = "1:1:1:0" },
            PowerInfusion   = { signature = "1:0:0:1" },
        },
        casts = {
            [33206] = { "PainSuppression" },
            [10060] = { "PowerInfusion" },
        },
    },
    HolyPriest = {
        auras = {
            GuardianSpirit = { signature = "1:1:1:0" },
            PowerInfusion  = { signature = "1:0:0:1" },
        },
        casts = {
            [47788] = { "GuardianSpirit" },
            [10060] = { "PowerInfusion" },
        },
    },
    MistweaverMonk = {
        auras = {
            LifeCocoon           = { signature = "1:1:1:0" },
            StrengthOfTheBlackOx = { signature = "0:1:0:1" },
        },
        casts = {},
    },
    HolyPaladin = {
        auras = {
            BlessingOfProtection = { signature = "1:1:1:1" },
            HolyArmaments        = { signature = "0:1:0:0" },
            BlessingOfSacrifice  = { signature = "1:1:1:0" },
            BlessingOfFreedom    = { signature = "1:0:0:1" },
            Dawnlight            = { signature = "0:1:0:0" },
        },
        casts = {
            [1022]   = { "BlessingOfProtection" },
            [432472] = { "HolyArmaments" },
            [6940]   = { "BlessingOfSacrifice" },
        },
    },
    AugmentationEvoker = {
        auras = {
            SensePower = { signature = "0:1:0:0" },
        },
        casts = {},
    },
}

-- ============================================================
-- TRACKABLE AURAS PER SPEC
-- Each aura: { name = "InternalName", display = "Display Name", color = {r,g,b} }
-- Secret auras have secret = true (used for visual distinction in Options UI only)
-- Colors are used for tile accents in the Options UI
-- ============================================================
DF.AuraDesigner.TrackableAuras = {
    PreservationEvoker = {
        { name = "Echo",             display = "Echo",              color = {0.31, 0.76, 0.97} },
        { name = "Reversion",        display = "Reversion",         color = {0.51, 0.78, 0.52} },
        { name = "EchoReversion",    display = "Echo Reversion",    color = {0.40, 0.77, 0.74} },
        { name = "DreamBreath",      display = "Dream Breath",      color = {0.47, 0.87, 0.47} },
        { name = "EchoDreamBreath",  display = "Echo Dream Breath", color = {0.36, 0.82, 0.60} },
        { name = "DreamFlight",      display = "Dream Flight",      color = {0.81, 0.58, 0.93} },
        { name = "Lifebind",         display = "Lifebind",          color = {0.94, 0.50, 0.50} },
        { name = "TimeDilation",     display = "Time Dilation",     color = {0.94, 0.82, 0.31}, secret = true },
        { name = "Rewind",           display = "Rewind",            color = {0.74, 0.85, 0.40}, secret = true },
        { name = "VerdantEmbrace",   display = "Verdant Embrace",   color = {0.47, 0.87, 0.47}, secret = true },
    },
    AugmentationEvoker = {
        { name = "Prescience",       display = "Prescience",        color = {0.81, 0.58, 0.85} },
        { name = "ShiftingSands",    display = "Shifting Sands",    color = {1.00, 0.84, 0.28} },
        { name = "BlisteringScales", display = "Blistering Scales", color = {0.94, 0.50, 0.50} },
        { name = "InfernosBlessing", display = "Infernos Blessing", color = {1.00, 0.60, 0.28} },
        { name = "SymbioticBloom",   display = "Symbiotic Bloom",   color = {0.51, 0.78, 0.52} },
        { name = "EbonMight",        display = "Ebon Might",        color = {0.62, 0.47, 0.85} },
        { name = "SourceOfMagic",    display = "Source of Magic",   color = {0.31, 0.76, 0.97} },
        { name = "SensePower",       display = "Sense Power",      color = {0.94, 0.82, 0.31}, secret = true },
    },
    RestorationDruid = {
        { name = "Rejuvenation",           display = "Rejuvenation",           color = {0.51, 0.78, 0.52} },
        { name = "Regrowth",               display = "Regrowth",               color = {0.31, 0.76, 0.97} },
        { name = "Lifebloom",              display = "Lifebloom",              color = {0.56, 0.93, 0.56} },
        { name = "Germination",            display = "Germination",            color = {0.77, 0.89, 0.42} },
        { name = "WildGrowth",             display = "Wild Growth",            color = {0.81, 0.58, 0.93} },
        { name = "SymbioticRelationship",  display = "Symbiotic Relationship", color = {0.40, 0.77, 0.74} },
        { name = "SymbioticBlooms",        display = "Symbiotic Blooms",      color = {0.45, 0.82, 0.55} },
        { name = "IronBark",               display = "Ironbark",              color = {0.65, 0.47, 0.33}, secret = true },
    },
    DisciplinePriest = {
        { name = "PowerWordShield", display = "PW: Shield",         color = {1.00, 0.84, 0.28} },
        { name = "Atonement",       display = "Atonement",          color = {0.94, 0.50, 0.50} },
        { name = "VoidShield",      display = "Void Shield",        color = {0.62, 0.47, 0.85} },
        { name = "PrayerOfMending", display = "Prayer of Mending",  color = {0.56, 0.93, 0.56} },
        { name = "PainSuppression", display = "Pain Suppression",   color = {0.81, 0.58, 0.93}, secret = true },
        { name = "PowerInfusion",   display = "Power Infusion",     color = {0.94, 0.82, 0.31}, secret = true },
    },
    HolyPriest = {
        { name = "Renew",           display = "Renew",              color = {0.56, 0.93, 0.56} },
        { name = "EchoOfLight",     display = "Echo of Light",      color = {1.00, 0.84, 0.28} },
        { name = "PrayerOfMending", display = "Prayer of Mending",  color = {0.81, 0.58, 0.93} },
        { name = "GuardianSpirit",  display = "Guardian Spirit",    color = {0.94, 0.50, 0.50}, secret = true },
        { name = "PowerInfusion",   display = "Power Infusion",     color = {0.94, 0.82, 0.31}, secret = true },
    },
    MistweaverMonk = {
        { name = "RenewingMist",     display = "Renewing Mist",     color = {0.56, 0.93, 0.56} },
        { name = "EnvelopingMist",   display = "Enveloping Mist",   color = {0.31, 0.76, 0.97} },
        { name = "SoothingMist",     display = "Soothing Mist",     color = {0.47, 0.87, 0.47} },
        { name = "AspectOfHarmony",  display = "Aspect of Harmony", color = {0.81, 0.58, 0.93} },
        { name = "LifeCocoon",       display = "Life Cocoon",       color = {0.31, 0.76, 0.97}, secret = true },
        { name = "StrengthOfTheBlackOx", display = "Strength of the Black Ox", color = {0.40, 0.77, 0.74}, secret = true },
    },
    RestorationShaman = {
        { name = "Riptide",           display = "Riptide",            color = {0.31, 0.76, 0.97} },
        { name = "EarthShield",       display = "Earth Shield",       color = {0.65, 0.47, 0.33} },
        { name = "AncestralVigor",    display = "Ancestral Vigor",    color = {0.56, 0.93, 0.56} },
        { name = "EarthlivingWeapon", display = "Earthliving Weapon", color = {0.47, 0.87, 0.47} },
        { name = "Hydrobubble",       display = "Hydrobubble",        color = {0.31, 0.76, 0.97} },
    },
    HolyPaladin = {
        { name = "BeaconOfFaith",       display = "Beacon of Faith",       color = {1.00, 0.84, 0.28} },
        { name = "EternalFlame",        display = "Eternal Flame",         color = {1.00, 0.60, 0.28} },
        { name = "BeaconOfLight",       display = "Beacon of Light",       color = {1.00, 0.93, 0.47} },
        { name = "BeaconOfVirtue",      display = "Beacon of Virtue",      color = {1.00, 0.88, 0.37}, secret = false },
        { name = "BeaconOfTheSavior",   display = "Beacon of the Savior",  color = {0.93, 0.80, 0.47} },
        { name = "BlessingOfProtection", display = "Blessing of Protection", color = {0.94, 0.82, 0.31}, secret = true },
        { name = "HolyArmaments",        display = "Holy Armaments",         color = {0.81, 0.58, 0.93}, secret = true, warningKey = "HolyArmamentsMerge" },
        { name = "BlessingOfSacrifice",  display = "Blessing of Sacrifice",  color = {0.94, 0.50, 0.50}, secret = true },
        { name = "BlessingOfFreedom",    display = "Blessing of Freedom",    color = {0.56, 0.93, 0.56}, secret = true },
        { name = "Dawnlight",            display = "Dawnlight",              color = {1.00, 0.84, 0.28}, secret = true },
    },
}
