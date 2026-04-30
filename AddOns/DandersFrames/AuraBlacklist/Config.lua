local addonName, DF = ...

-- ============================================================
-- AURA BLACKLIST CONFIG
-- Spell data tables for the Aura Blacklist UI.
-- Buffs are organized by class (Aura Designer spells + raid buffs).
-- Debuffs are a universal list (not class-specific).
-- ============================================================

local pairs = pairs
local InCombatLockdown = InCombatLockdown

-- Initialize the AuraBlacklist namespace
DF.AuraBlacklist = DF.AuraBlacklist or {}

-- ============================================================
-- CLASS ORDER
-- Display order for the class dropdown (healer/support classes first)
-- ============================================================
DF.AuraBlacklist.ClassOrder = {
    "DRUID", "PRIEST", "PALADIN", "SHAMAN", "MONK", "EVOKER",
    "MAGE", "WARRIOR", "ROGUE", "HUNTER",
}

-- ============================================================
-- CLASS DISPLAY NAMES
-- ============================================================
DF.AuraBlacklist.ClassNames = {
    DRUID   = "Druid",
    PRIEST  = "Priest",
    PALADIN = "Paladin",
    SHAMAN  = "Shaman",
    MONK    = "Monk",
    EVOKER  = "Evoker",
    MAGE    = "Mage",
    WARRIOR = "Warrior",
    ROGUE   = "Rogue",
    HUNTER  = "Hunter",
}

-- ============================================================
-- BUFF SPELLS PER CLASS
-- Each entry: { spellId, display, iconTexture }
-- iconTexture uses static texture IDs where available (from
-- AuraDesigner.IconTextures) to prevent dynamic icon swapping.
-- Entries are ordered alphabetically within each class.
-- ============================================================
DF.AuraBlacklist.BuffSpells = {
    DRUID = {
        { spellId = 155777, display = "Germination",            icon = 1033478 },
        { spellId = 33763,  display = "Lifebloom",              icon = 134206  },
        { spellId = 1126,   display = "Mark of the Wild",       icon = 136078  },
        { spellId = 8936,   display = "Regrowth",               icon = 136085  },
        { spellId = 774,    display = "Rejuvenation",           icon = 136081  },
        { spellId = 474754, display = "Symbiotic Relationship", icon = 1408837 },
        { spellId = 48438,  display = "Wild Growth",            icon = 236153  },
    },
    PRIEST = {
        { spellId = 194384, display = "Atonement",              icon = 458720  },
        { spellId = 77489,  display = "Echo of Light",          icon = 237537  },
        { spellId = 17,     display = "PW: Shield",             icon = 135940  },
        { spellId = 21562,  display = "Power Word: Fortitude",  icon = 135987  },
        { spellId = 41635,  display = "Prayer of Mending",      icon = 135944  },
        { spellId = 139,    display = "Renew",                  icon = 135953  },
        { spellId = 1253593,display = "Void Shield",            icon = 7514191 },
    },
    PALADIN = {
        { spellId = 156910, display = "Beacon of Faith",        icon = 1030095 },
        { spellId = 53563,  display = "Beacon of Light",        icon = 236247  },
        { spellId = 1244893,display = "Beacon of the Savior",   icon = 7514188 },
        { spellId = 200025, display = "Beacon of Virtue",       icon = 1030094 },
        { spellId = 156322, display = "Eternal Flame",          icon = 135433  },
        { spellId = 433583, display = "Rite of Adjuration",     icon = 237051  },
        { spellId = 433568, display = "Rite of Sanctification", icon = 237172  },
    },
    SHAMAN = {
        { spellId = 207400, display = "Ancestral Vigor",        icon = 237574   },
        { spellId = 974,    display = "Earth Shield",           icon = 136089   },
        { spellId = 382024, display = "Earthliving Weapon",     icon = 237578   },
        { spellId = 319778, display = "Flametongue Weapon",     icon = 135814   },
        { spellId = 444490, display = "Hydrobubble",            icon = 1320371  },
        { spellId = 20608,  display = "Reincarnation",          icon = 451167   },
        { spellId = 61295,  display = "Riptide",                icon = 252995   },
        { spellId = 462854, display = "Skyfury",                icon = 135831   },
        { spellId = 369459, display = "Source of Magic",        icon = 4630412  },
        { spellId = 462757, display = "Thunderstrike Ward",     icon = 5975854  },
        { spellId = 457496, display = "Tidecaller's Guard",     icon = 1355357  },
        { spellId = 319773, display = "Windfury Weapon",        icon = 462329   },
    },
    MONK = {
        { spellId = 450769, display = "Aspect of Harmony",      icon = 5927638 },
        { spellId = 124682, display = "Enveloping Mist",        icon = 775461  },
        { spellId = 119611, display = "Renewing Mist",          icon = 627487  },
        { spellId = 115175, display = "Soothing Mist",          icon = 606550  },
    },
    EVOKER = {
        { spellId = 381748, display = "Blessing of the Bronze", icon = 4622448 },
        { spellId = 360827, display = "Blistering Scales",      icon = 5199621 },
        { spellId = 355941, display = "Dream Breath",           icon = 4622454 },
        { spellId = 363502, display = "Dream Flight",           icon = 4622455 },
        { spellId = 395152, display = "Ebon Might",             icon = 5061347 },
        { spellId = 364343, display = "Echo",                   icon = 4622456 },
        { spellId = 376788, display = "Echo Dream Breath",      icon = 7439198 },
        { spellId = 367364, display = "Echo Reversion",         icon = 4630469 },
        { spellId = 410263, display = "Infernos Blessing",      icon = 5199632 },
        { spellId = 373267, display = "Lifebind",               icon = 4630453 },
        { spellId = 410089, display = "Prescience",             icon = 5199639 },
        { spellId = 366155, display = "Reversion",              icon = 4630467 },
        { spellId = 413984, display = "Shifting Sands",         icon = 5199633 },
        { spellId = 369459, display = "Source of Magic",        icon = 4630412 },
        { spellId = 410686, display = "Symbiotic Bloom",        icon = 4554354 },
    },
    MAGE = {
        { spellId = 1459,   display = "Arcane Intellect",       icon = 135932  },
        { spellId = 205473, display = "Icicles",                icon = 135855  },
    },
    WARRIOR = {
        { spellId = 6673,   display = "Battle Shout",           icon = 132333  },
    },
    ROGUE = {
        { spellId = 381664, display = "Amplifying Poison",      icon = 134207  },
        { spellId = 381637, display = "Atrophic Poison",        icon = 132300  },
        { spellId = 3408,   display = "Crippling Poison",       icon = 132274  },
        { spellId = 2823,   display = "Deadly Poison",          icon = 132290  },
        { spellId = 315584, display = "Instant Poison",         icon = 132273  },
        { spellId = 5761,   display = "Numbing Poison",         icon = 136066  },
        { spellId = 8679,   display = "Wound Poison",           icon = 134197  },
    },
    HUNTER = {
        { spellId = 260286, display = "Tip of the Spear",       icon = 1117879 },
    },
}

-- ============================================================
-- DEBUFF SPELLS (universal, not class-specific)
-- Sated / Exhaustion family — applied after Heroism/Bloodlust
-- ============================================================
DF.AuraBlacklist.DebuffSpells = {
    -- Sated / Exhaustion family
    { spellId = 57723,  display = "Exhaustion",             icon = 136090  },
    { spellId = 160455, display = "Fatigued",               icon = 132307  },
    { spellId = 95809,  display = "Insanity",               icon = 132127  },
    { spellId = 57724,  display = "Sated",                  icon = 136090  },
    { spellId = 80354,  display = "Temporal Displacement",  icon = 236502  },
    -- Deserter
    { spellId = 26013,  display = "BG Deserter",            icon = 135971  },
    { spellId = 71041,  display = "Dungeon Deserter",       icon = 135971  },
    -- Skyriding
    { spellId = 427490, display = "Ride Along Available",   icon = 4640493 },
    { spellId = 447959, display = "Ride Along Active",      icon = 4640493 },
    { spellId = 447960, display = "Ride Along Inactive",    icon = 4640493 },
}

-- ============================================================
-- ALTERNATE SPELL ID MAP
-- Maps alternate spell IDs to their primary ID so a single
-- blacklist entry covers all variants of the same aura.
-- Key = alternate ID, value = primary ID stored in the blacklist.
-- ============================================================
DF.AuraBlacklist.AlternateSpellIDs = {
    -- Earth Shield variants
    [383648] = 974,
    -- Earthliving Weapon variants
    [382021] = 382024,
    [382022] = 382024,
    -- Tidecaller's Guard variant
    [457481] = 457496,
    -- Thunderstrike Ward variant
    [462742] = 462757,
    -- Symbiotic Relationship variants
    [474750] = 474754,
    [474760] = 474754,
    -- Blessing of the Bronze (class-specific buff IDs → primary Evoker ID)
    [381732] = 381748,   -- Death Knight
    [381741] = 381748,   -- Demon Hunter
    [381746] = 381748,   -- Druid
    [381749] = 381748,   -- Hunter
    [381750] = 381748,   -- Mage
    [381751] = 381748,   -- Monk
    [381752] = 381748,   -- Paladin
    [381753] = 381748,   -- Priest
    [381754] = 381748,   -- Rogue
    [381756] = 381748,   -- Shaman
    [381757] = 381748,   -- Warlock
    [381758] = 381748,   -- Warrior
    -- Exhaustion variants
    [390435] = 57723,
    [428628] = 57723,    -- Harrier's Exhaustion (Harrier's Cry)
    -- Fatigued variant
    [264689] = 160455,
}

-- ============================================================
-- HELPER: IsSpellBlacklisted
-- Checks whether a spell ID (or any of its alternates) is in
-- the given blacklist table. Used by the filtering layer.
-- ============================================================
function DF.AuraBlacklist.IsBlacklisted(blacklistTable, spellId)
    if not blacklistTable or not spellId then return false end
    -- Find the entry (direct or via alternate)
    local entry = blacklistTable[spellId]
    if not entry then
        local primary = DF.AuraBlacklist.AlternateSpellIDs[spellId]
        if primary then entry = blacklistTable[primary] end
    end
    if not entry then return false end
    -- Legacy support: plain true = always blacklisted
    if entry == true then return true end
    -- Table format: check combat/ooc flags
    if InCombatLockdown() then
        return entry.combat
    end
    return entry.ooc
end
