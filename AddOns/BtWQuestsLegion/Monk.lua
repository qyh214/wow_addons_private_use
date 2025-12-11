local L = BtWQuests.L;
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_BREWMASTER, {
    name = L["BREWMASTER_FU_ZAN_THE_WANDERERS_COMPANION"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_BLOOD,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_HAVOC,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_BALANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_BEASTMASTERY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_ARCANE,
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
            id = BTWQUESTS_CLASS_ID_MONK,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("MONK", 1),
    active = BtWQuests.LegionArtifactActive("MONK", 1),
    completed = {
        type = "quest",
        id = 42765,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Monk-Brewmaster",
    items = {
        {
            type = "quest",
            id = 42762,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42766,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42767,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42957,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42868,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42765,
            x = 3,
            y = 5,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_WINDWALKER, {
    name = L["WINDWALKER_FISTS_OF_THE_HEAVENS"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FROST,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FERAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_MARKSMANSHIP,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FIRE,
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
            id = BTWQUESTS_CLASS_ID_MONK,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("MONK", 2),
    active = BtWQuests.LegionArtifactActive("MONK", 2),
    completed = {
        type = "quest",
        id = 40570,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Monk-Windwalker",
    items = {
        {
            type = "quest",
            id = 40569,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40633,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40634,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40570,
            x = 3,
            y = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_MISTWEAVER, {
    name = L["MISTWEAVER_SHEILUN_STAFF_OF_THE_MISTS"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_UNHOLY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_GUARDIAN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_SURVIVAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FROST,
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
            id = BTWQUESTS_CLASS_ID_MONK,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("MONK", 3),
    active = BtWQuests.LegionArtifactActive("MONK", 3),
    completed = {
        type = "quest",
        id = 41003,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Monk-Mistweaver",
    items = {
        {
            type = "quest",
            id = 41003,
            x = 3,
            y = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_CAMPAIGN, {
    name = L["BTWQUESTS_MONK_CAMPAIGN"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_MONK,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_CAMPAIGN,
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
            id = BTWQUESTS_CLASS_ID_MONK,
        },
    },
    completed = {
        type = "quest",
        id = 41087,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 12103,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40236,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40636,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3, 4,
            },
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_BREWMASTER,
            active = {
                type = "quest",
                id = 40636,
            },
            visible = BtWQuests.LegionArtifactNonSelected("MONK"),
            x = 1,
            y = 3,
            connections = {
                4
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_MISTWEAVER,
            active = {
                type = "quest",
                id = 40636,
            },
            visible = BtWQuests.LegionArtifactNonSelected("MONK"),
            x = 3,
            y = 3,
            connections = {
                3
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_WINDWALKER,
            active = {
                type = "quest",
                id = 40636,
            },
            visible = BtWQuests.LegionArtifactNonSelected("MONK"),
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
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_BREWMASTER,
                    restrictions = {
                        type = "quest",
                        id = 40640,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_MISTWEAVER,
                    restrictions = {
                        type = "quest",
                        id = 40639,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_WINDWALKER,
                    restrictions = {
                        type = "quest",
                        id = 40638,
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

        -- {
        --     type = "quest",
        --     id = 40698,
        --     x = 3,
        --     y = 4,
        --     connections = {
        --         1
        --     },
        -- },
        {
            type = "quest",
            id = 40793,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40795,
            x = 3,
            y = 6,
            connections = {
                2
            },
        },


        {
            type = "level",
            level = 101,
            x = 5,
            y = 6.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42186,
            breadcrumb = true,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42187,
            x = 3,
            y = 8,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41945,
            x = 3,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41946,
            x = 3,
            y = 10,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42210,
            x = 3,
            y = 11,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42191,
            x = 3,
            y = 12,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41905,
            x = 3,
            y = 13,
            connections = {
                2
            },
        },
        {
            type = "level",
            level = 103,
            x = 5,
            y = 13.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41728,
            x = 3,
            y = 14,
            connections = {
                1, 2, 3
            },
        },


        {
            type = "quest",
            id = 41729,
            x = 1,
            y = 15,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 41730,
            x = 3,
            y = 15,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 41731,
            x = 5,
            y = 15,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 41732,
            x = 3,
            y = 16,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41733,
            x = 3,
            y = 17,
            connections = {
                1, 2, 3
            },
        },


        {
            type = "quest",
            id = 41907,
            x = 1,
            y = 18,
            connections = {
                4
            },
        },
        {
            type = "quest",
            id = 43062,
            x = 3,
            y = 18,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 41909,
            x = 5,
            y = 18,
            connections = {
                2
            },
        },


        {
            type = "level",
            level = 45,
            x = 5,
            y = 19.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41849,
            x = 3,
            y = 20,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41850,
            x = 3,
            y = 21,
            connections = {
                1, 2, 3
            },
        },



        {
            type = "quest",
            id = 41852,
            x = 1,
            y = 22,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 41853,
            x = 3,
            y = 22,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 41851,
            x = 5,
            y = 22,
            connections = {
                1
            },
        },



        {
            type = "quest",
            id = 41854,
            x = 3,
            y = 23,
            connections = {
                1, 2, 3
            },
        },



        {
            type = "quest",
            id = 41737,
            x = 1,
            y = 24,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 41738,
            x = 3,
            y = 24,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 41736,
            x = 5,
            y = 24,
            connections = {
                1
            },
        },



        {
            type = "quest",
            id = 41038,
            x = 3,
            y = 25,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41039,
            x = 3,
            y = 26,
            connections = {
                1, 2, 3, 4
            },
        },


        {
            type = "quest",
            id = 41040,
            x = 0,
            y = 27,
            connections = {
                4
            },
        },
        {
            type = "quest",
            id = 41910,
            x = 2,
            y = 27,
            connections = {
                5
            },
        },
        {
            type = "quest",
            id = 41086,
            x = 4,
            y = 27,
            connections = {
                4
            },
        },
        {
            type = "quest",
            id = 41911,
            x = 6,
            y = 27,
            connections = {
                2
            },
        },


        {
            type = "quest",
            id = 41059,
            x = 0,
            y = 28,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43151,
            x = 6,
            y = 28,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 32442,
            x = 3,
            y = 29,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41087,
            x = 3,
            y = 30,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 41739,
            x = 2,
            y = 31,
        },
        {
            type = "quest",
            id = 43359,
            x = 4,
            y = 31,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_FOLLOWER, {
    name = { -- Champion: Almai
		type = "quest",
		id = 45790,
	},
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_MONK,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FOLLOWER,
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
            id = BTWQUESTS_CLASS_ID_MONK,
        },
    },
    completed = {
        type = "quest",
        id = 45790,
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
            id = 45440,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45404,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45459,
            x = 3,
            y = 3,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 45574,
            x = 1,
            y = 4,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 45449,
            x = 3,
            y = 4,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45545,
            x = 5,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46320,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45442,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45771,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45790,
            x = 3,
            y = 8,
            connections = {
                1
            },
        },



        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            aside = true,
            x = 3,
            y = 9,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_MOUNT, {
    name = L["BTWQUESTS_MONK_MOUNT"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_MONK,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_MOUNT,
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
            id = BTWQUESTS_CLASS_ID_MONK,
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
        id = 46350,
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
            id = 46353,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46341,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46342,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46343,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46344,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46346,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46347,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46348,
            x = 3,
            y = 8,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46349,
            x = 3,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46350,
            x = 3,
            y = 10,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_CLASSES_MONK, {
    name = LOCALIZED_CLASS_NAMES_MALE["MONK"],
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DEATHKNIGHT,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DEMONHUNTER,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DRUID,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_HUNTER,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_MAGE,
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
            id = BTWQUESTS_CLASS_ID_MONK,
        }
    },
    -- buttonImage = 1041999,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_CAMPAIGN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_FOLLOWER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_MOUNT,
        },
    },
})