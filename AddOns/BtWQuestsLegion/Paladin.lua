local L = BtWQuests.L;
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_HOLY, {
    name = L["HOLY_THE_SILVER_HAND"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_BLOOD,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_HAVOC,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_BALANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_BEASTMASTERY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_ARCANE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_BREWMASTER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_DISCIPLINE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_ASSASSINATION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ELEMENTAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_AFFLICTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_ARMS,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_PALADIN,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("PALADIN", 1),
    active = BtWQuests.LegionArtifactActive("PALADIN", 1),
    completed = {
        type = "quest",
        id = 42120,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Paladin-Holy",
    items = {
        {
            type = "quest",
            id = 42231,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42120,
            x = 3,
            y = 1,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_PROTECTION, {
    name = L["PROTECTION_TRUTHGUARD"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FROST,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FERAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_MARKSMANSHIP,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FIRE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_WINDWALKER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_HOLY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_OUTLAW,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ENHANCEMENT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_DEMONOLOGY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FURY,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_PALADIN,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("PALADIN", 2),
    active = BtWQuests.LegionArtifactActive("PALADIN", 2),
    completed = {
        type = "quest",
        id = 42017,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Paladin-Protection",
    items = {
        {
            type = "quest",
            id = 42000,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42002,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42005,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42017,
            x = 3,
            y = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_RETRIBUTION, {
    name = L["RETRIBUTION_ASHBRINGER"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_UNHOLY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_GUARDIAN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_SURVIVAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FROST,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_MISTWEAVER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_SHADOW,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_SUBTLETY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_RESTORATION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_DESTRUCTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_PROTECTION,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_PALADIN,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("PALADIN", 3),
    active = BtWQuests.LegionArtifactActive("PALADIN", 3),
    completed = {
        type = "quest",
        id = 38376,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Paladin-Retribution",
    items = {
        {
            type = "quest",
            id = 42770,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42772,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42771,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42773,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42774,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 38376,
            x = 3,
            y = 5,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_CAMPAIGN, {
    name = L["BTWQUESTS_PALADIN_CAMPAIGN"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_PALADIN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_CAMPAIGN,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_PALADIN,
        },
    },
    completed = {
        type = "quest",
        id = 43697,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 38710,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40408,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3, 4,
            },
        },



        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_HOLY,
            active = {
                type = "quest",
                id = 40408,
            },
            visible = BtWQuests.LegionArtifactNonSelected("PALADIN"),
            x = 1,
            y = 2,
            connections = {
                4
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_PROTECTION,
            active = {
                type = "quest",
                id = 40408,
            },
            visible = BtWQuests.LegionArtifactNonSelected("PALADIN"),
            x = 3,
            y = 2,
            connections = {
                3
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_RETRIBUTION,
            active = {
                type = "quest",
                id = 40408,
            },
            visible = BtWQuests.LegionArtifactNonSelected("PALADIN"),
            x = 5,
            y = 2,
            connections = {
                2
            },
        },



        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_HOLY,
                    restrictions = {
                        type = "quest",
                        id = 40410,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_PROTECTION,
                    restrictions = {
                        type = "quest",
                        id = 40411,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_RETRIBUTION,
                    restrictions = {
                        type = "quest",
                        id = 40409,
                    },
                },
                {
                    visible = false,
                },
            },
            x = 3,
            y = 2,
            connections = {
                1
            },
        },



        {
            type = "quest",
            id = 38576,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 38566,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        -- {
        --     type = "quest",
        --     id = 39722,
        --     x = 3,
        --     y = 5,
        --     connections = {
        --         1
        --     },
        -- },
        {
            type = "quest",
            id = 38933,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39756,
            x = 3,
            y = 7,
            connections = {
                2
            },
        },




        {
            type = "level",
            level = 101,
            x = 5,
            y = 7.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42844,
            breadcrumb = true,
            x = 3,
            y = 8,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39696,
            x = 3,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42846,
            x = 3,
            y = 10,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42847,
            x = 3,
            y = 11,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 42848,
            x = 2,
            y = 12,
            connections = {
                2
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ORDERHALL_LIGHTSHEART,
            completed = {
                type = "quest",
                id = 44153,
            },
            x = 4,
            y = 12,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42849,
            x = 2,
            y = 13,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42867,
            x = 4,
            y = 13,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42850,
            x = 2,
            y = 14,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42919,
            x = 4,
            y = 14,
            connections = {
                1
            },
        },
        { -- @TODO have different tooltips, not sure where it decides which to do
            type = "quest",
            ids = {42885, 42966, 42967, 42968},
            x = 3,
            y = 15,
            connections = {
                2
            },
        },

        {
            type = "level",
            level = 103,
            x = 5,
            y = 15.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42886,
            x = 3,
            y = 16,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42887,
            x = 3,
            y = 17,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 43462,
            x = 2,
            y = 18,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42888,
            x = 4,
            y = 18,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 42890,
            x = 3,
            y = 19,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 42852,
            x = 2,
            y = 20,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 42851,
            x = 4,
            y = 20,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43494,
            aside = true,
            x = 6,
            y = 20,
        },


        {
            type = "quest",
            id = 43486,
            x = 3,
            y = 21,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 43487,
            x = 2,
            y = 22,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43488,
            x = 4,
            y = 22,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43535,
            x = 3,
            y = 23,
            connections = {
                2
            },
        },



        {
            type = "level",
            level = 45,
            x = 5,
            y = 23.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43493,
            x = 3,
            y = 24,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43489,
            x = 3,
            y = 25,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43490,
            x = 3,
            y = 26,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 43491,
            x = 2,
            y = 27,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43540,
            x = 4,
            y = 27,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43541,
            x = 3,
            y = 28,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 43492,
            x = 2,
            y = 30,
            connections = {
                3, 4, 5
            },
        },
        {
            type = "quest",
            id = 43934,
            x = 4,
            y = 29,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43933,
            x = 4,
            y = 30,
            connections = {
                1, 2, 3
            },
        },


        {
            type = "quest",
            id = 43699,
            x = 1,
            y = 31,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 43698,
            x = 3,
            y = 31,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43534,
            x = 5,
            y = 31,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43700,
            x = 3,
            y = 32,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43697,
            x = 3,
            y = 33,
            connections = {
                1, 2, 3
            },
        },


        {
            type = "quest",
            id = 43785,
            aside = true,
            x = 1,
            y = 34,
        },
        {
            type = "quest",
            id = 43424,
            x = 3,
            y = 34,
        },
        {
            type = "quest",
            id = 43701,
            aside = true,
            x = 5,
            y = 34,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_FOLLOWER, {
    name = { -- Champion: Nerus Moonfang
		type = "quest",
		id = 46045,
	},
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_PALADIN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_FOLLOWER,
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
            id = BTWQUESTS_CLASS_ID_PALADIN,
        },
    },
    completed = {
        type = "quest",
        id = 46045,
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
            id = 47137,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45143,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45890,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46259,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45145,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45146,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45147,
            x = 3,
            y = 7,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 45148,
            x = 2,
            y = 8,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45149,
            x = 4,
            y = 8,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46045,
            x = 3,
            y = 9,
            connections = {
                1
            },
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            aside = true,
            x = 3,
            y = 10,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_OTHER_FOLLOWER, {
    name = L["CHAMPION_MAXIMILLIAN_OF_NORTHSHIRE"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_PALADIN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_ANNOYING_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_FOLLOWER,
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
            id = BTWQUESTS_CLASS_ID_PALADIN,
        },
    },
    prerequisites = {
        {
            type = "quest",
            id = 24707,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_FOLLOWER,
        }
    },
    completed = {
        type = "quest",
        id = 45813,
    },
    range = {110},
    items = {
        {
            type = "quest",
            id = 24707,
            x = 2,
            y = 0,
            connections = {
                2
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_FOLLOWER,
            breadcrumb = true,
            x = 4,
            y = 0,
            connections = {
                1
            },
        },
        {
            name = L["WAIT_FOR_A_MAIL_FROM_MAXIMILLIAN"],
            type = "quest",
            id = 45773,
            breadcrumb = true,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45561,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45562,
            x = 3,
            y = 3,
            connections = {
                1, 2, 3, 4
            },
        },
        {
            type = "quest",
            id = 45565,
            x = 0,
            y = 4,
            connections = {
                4
            },
        },
        {
            type = "quest",
            id = 45566,
            x = 2,
            y = 4,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 45567,
            x = 4,
            y = 4,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45568,
            x = 6,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45644,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45645,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45813,
            x = 3,
            y = 7,
        }
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_MOUNT, {
    name = L["BTWQUESTS_PALADIN_MOUNT"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_PALADIN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_MOUNT,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_PALADIN,
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
        id = 45770,
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
            id = 46069,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46070,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46071,
            x = 3,
            y = 3,
            connections = {
                2
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_SURAMAR_MASQUERADE,
            x = 1,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46083,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46074,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45770,
            x = 3,
            y = 6,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_CLASSES_PALADIN, {
    name = LOCALIZED_CLASS_NAMES_MALE["PALADIN"],
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DEATHKNIGHT,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DEMONHUNTER,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DRUID,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_HUNTER,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_MAGE,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_MONK,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_PRIEST,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_ROGUE,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_SHAMAN,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_WARLOCK,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_WARRIOR,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_PALADIN,
        }
    },
    -- buttonImage = 1041999,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_CAMPAIGN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_FOLLOWER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_OTHER_FOLLOWER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_MOUNT,
        },
    },
})