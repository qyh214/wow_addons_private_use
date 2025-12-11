local L = BtWQuests.L;
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_ARCANE, {
    name = L["ARCANE_ALUNETH"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_BLOOD,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_HAVOC,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_BALANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_BEASTMASTERY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_BREWMASTER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_HOLY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_DISCIPLINE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_ASSASSINATION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ELEMENTAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_AFFLICTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_ARMS,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_MAGE,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("MAGE", 1),
    active = BtWQuests.LegionArtifactActive("MAGE", 1),
    completed = {
        type = "quest",
        id = 42011,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Mage-Arcane",
    items = {
        {
            type = "quest",
            id = 42001,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42006,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42007,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42008,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42009,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42010,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42011,
            x = 3,
            y = 6,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FIRE, {
    name = L["FIRE_FELOMELORN"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FROST,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FERAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_MARKSMANSHIP,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_WINDWALKER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_PROTECTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_HOLY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_OUTLAW,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ENHANCEMENT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_DEMONOLOGY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FURY,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_MAGE,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("MAGE", 2),
    active = BtWQuests.LegionArtifactActive("MAGE", 2),
    completed = {
        type = "quest",
        id = 11997,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Mage-Fire",
    items = {
        {
            type = "quest",
            id = 40267,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40270,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 11997,
            x = 3,
            y = 2,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FROST, {
    name = L["FROST_EBONCHILL"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_UNHOLY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_GUARDIAN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_SURVIVAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_MISTWEAVER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_RETRIBUTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_SHADOW,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_SUBTLETY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_RESTORATION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_DESTRUCTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_PROTECTION,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_MAGE,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("MAGE", 3),
    active = BtWQuests.LegionArtifactActive("MAGE", 3),
    completed = {
        type = "quest",
        id = 42479,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Mage-Frost",
    items = {
        {
            type = "quest",
            id = 42452,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42455,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42476,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42477,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42479,
            x = 3,
            y = 4,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_CAMPAIGN, {
    name = L["BTWQUESTS_MAGE_CAMPAIGN"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_MAGE,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_CAMPAIGN,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_MAGE,
        },
    },
    completed = {
        type = "quest",
        id = 42734,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 41035,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41036,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41085,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3, 4,
            },
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_ARCANE,
            active = {
                type = "quest",
                id = 41085,
            },
            visible = BtWQuests.LegionArtifactNonSelected("MAGE"),
            x = 1,
            y = 3,
            connections = {
                4
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FIRE,
            active = {
                type = "quest",
                id = 41085,
            },
            visible = BtWQuests.LegionArtifactNonSelected("MAGE"),
            x = 3,
            y = 3,
            connections = {
                3
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FROST,
            active = {
                type = "quest",
                id = 41085,
            },
            visible = BtWQuests.LegionArtifactNonSelected("MAGE"),
            x = 5,
            y = 3,
            connections = {
                2
            },
        },


        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_ARCANE,
                    restrictions = {
                        type = "quest",
                        id = 41079,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FIRE,
                    restrictions = {
                        type = "quest",
                        id = 41080,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FROST,
                    restrictions = {
                        type = "quest",
                        id = 41081,
                    },
                },
                {
                    visible = false,
                },
            },
            x = 3,
            y = 3,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 41114,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        -- {
        --     type = "quest",
        --     id = 41125,
        --     x = 3,
        --     y = 5,
        --     connections = {
        --         1
        --     },
        -- },
        {
            type = "quest",
            id = 41112,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41113,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41124,
            x = 3,
            y = 8,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41141,
            x = 3,
            y = 9,
            connections = {
                2
            },
        },


        {
            type = "level",
            level = 101,
            x = 5,
            y = 9.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42175,
            breadcrumb = true,
            x = 3,
            y = 10,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42663,
            x = 3,
            y = 11,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42703,
            x = 3,
            y = 12,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42126,
            x = 3,
            y = 13,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42127,
            x = 3,
            y = 14,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42696,
            x = 3,
            y = 15,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42433,
            x = 3,
            y = 16,
            connections = {
                2
            },
        },


        {
            type = "level",
            level = 103,
            x = 5,
            y = 16.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42418,
            x = 3,
            y = 17,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42434,
            x = 3,
            y = 18,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42435,
            x = 3,
            y = 19,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42166,
            x = 3,
            y = 20,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 42206,
            x = 2,
            y = 21,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42149,
            x = 4,
            y = 21,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 42171,
            x = 3,
            y = 22,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42222,
            x = 3,
            y = 23,
            connections = {
                1, 2, 3, 4
            },
        },


        {
            type = "quest",
            id = 42706,
            x = 0,
            y = 24,
        },
        {
            type = "quest",
            id = 44098,
            x = 2,
            y = 24,
        },
        {
            type = "quest",
            id = 42416,
            x = 4,
            y = 24,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42705,
            x = 6,
            y = 24,
        },

        {
            type = "quest",
            id = 42423,
            x = 3,
            y = 25,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42424,
            x = 3,
            y = 26,
            connections = {
                2
            },
        },


        {
            type = "level",
            level = 45,
            x = 5,
            y = 26.5,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 42451,
            x = 3,
            y = 27,
            connections = {
                6
            },
        },


        {
            type = "quest",
            id = 42954,
            aside = true,
            x = 5,
            y = 28,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42955,
            aside = true,
            x = 5,
            y = 29,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42956,
            aside = true,
            x = 5,
            y = 30,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42959,
            aside = true,
            x = 5,
            y = 31,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42704,
            aside = true,
            x = 5,
            y = 32,
        },



        {
            type = "quest",
            id = 42508,
            x = 3,
            y = 28,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 42494,
            aside = true,
            x = 1,
            y = 29,
        },
        {
            type = "quest",
            id = 42521,
            x = 3,
            y = 29,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42493,
            x = 3,
            y = 30,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 42520,
            x = 3,
            y = 31,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 42702,
            aside = true,
            x = 1,
            y = 31,
        },
        {
            type = "quest",
            id = 42707,
            x = 1,
            y = 32,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42940,
            x = 3,
            y = 32,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44689,
            x = 3,
            y = 33,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42734,
            x = 3,
            y = 34,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 42917,
            aside = true,
            x = 1,
            y = 35,
        },
        {
            type = "quest",
            id = 42914,
            x = 5,
            y = 35,
        },
        {
            type = "quest",
            id = 43415,
            aside = true,
            x = 3,
            y = 35,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FOLLOWER, {
    name = { -- Champion: Aethas Sunreaver
		type = "quest",
		id = 46043,
	},
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_MAGE,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_ALLIANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_HORDE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FOLLOWER_ALLIANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FOLLOWER_HORDE,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_MAGE,
        },
    },
    completed = {
        type = "quest",
        id = 46043,
    },
    range = {110},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45437,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44766,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46335,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46338,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45207,
            x = 3,
            y = 5,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 46705,
            x = 2,
            y = 6,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 46339,
            x = 4,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46345,
            x = 3,
            y = 7,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 44768,
            x = 2,
            y = 8,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 44770,
            x = 4,
            y = 8,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46351,
            x = 3,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45251,
            x = 3,
            y = 10,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 45614,
            x = 2,
            y = 11,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45586,
            x = 4,
            y = 11,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46000,
            x = 3,
            y = 12,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46290,
            x = 3,
            y = 13,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46043,
            x = 3,
            y = 14,
            connections = {
                1
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            aside = true,
            x = 3,
            y = 15,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_ANNOYING_FOLLOWER, {
    name = { -- Champion: The Great Akazamzarak
		type = "quest",
		id = 46724,
	},
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_MAGE,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_OTHER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_ALLIANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_HORDE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FOLLOWER_ALLIANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FOLLOWER_HORDE,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_MAGE,
        },
    },
    completed = {
        type = "quest",
        id = 46724,
    },
    range = {110},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45615,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45630,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46722,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46723,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46724,
            x = 3,
            y = 5,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_MOUNT, {
    name = L["BTWQUESTS_MAGE_MOUNT"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_MAGE,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_MOUNT,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_MAGE,
        },
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
        },
    },
    completed = {
        type = "quest",
        id = 45354,
    },
    range = {110},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45844,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3
            },
        },

        {
            type = "quest",
            id = 45845,
            x = 1,
            y = 2,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 45846,
            x = 3,
            y = 2,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45847,
            x = 5,
            y = 2,
            connections = {
                1
            },
        },

        {
            type = "quest",
            id = 45354,
            x = 3,
            y = 3,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_CLASSES_MAGE, {
    name = LOCALIZED_CLASS_NAMES_MALE["MAGE"],
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DEATHKNIGHT,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DEMONHUNTER,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DRUID,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_HUNTER,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_MONK,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_PALADIN,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_PRIEST,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_ROGUE,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_SHAMAN,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_WARLOCK,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_WARRIOR,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_MAGE,
        }
    },
    -- buttonImage = 1041999,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_CAMPAIGN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FOLLOWER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_ANNOYING_FOLLOWER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_MOUNT,
        },
    },
})