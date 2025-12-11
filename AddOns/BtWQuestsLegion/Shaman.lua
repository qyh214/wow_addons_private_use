local L = BtWQuests.L;
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ELEMENTAL, {
    name = L["ELEMENTAL_THE_FIST_OF_RADEN"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_BLOOD,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_HAVOC,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_BALANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_BEASTMASTERY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_ARCANE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_BREWMASTER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_HOLY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_DISCIPLINE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_ASSASSINATION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_AFFLICTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_ARMS,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_SHAMAN,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("SHAMAN", 1),
    active = BtWQuests.LegionArtifactActive("SHAMAN", 1),
    completed = {
        type = "quest",
        id = 39771,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Shaman-Elemental",
    items = {
        {
            type = "quest",
            id = 43334,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43338,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39771,
            x = 3,
            y = 2,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ENHANCEMENT, {
    name = L["ENHANCEMENT_DOOMHAMMER"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FROST,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FERAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_MARKSMANSHIP,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FIRE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_WINDWALKER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_PROTECTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_HOLY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_OUTLAW,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_DEMONOLOGY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FURY,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_SHAMAN,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("SHAMAN", 2),
    active = BtWQuests.LegionArtifactActive("SHAMAN", 2),
    completed = {
        type = "quest",
        id = 40224,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Shaman-Enhancement",
    items = {
        {
            type = "quest",
            id = 42931,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42932,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42933,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42935,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42936,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42937,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40224,
            x = 3,
            y = 6,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_RESTORATION, {
    name = L["RESTORATION_SHARASDAL_SCEPTER_OF_TIDES"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_UNHOLY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_GUARDIAN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_SURVIVAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FROST,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_MISTWEAVER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_RETRIBUTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_SHADOW,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_SUBTLETY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_DESTRUCTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_PROTECTION,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_SHAMAN,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("SHAMAN", 3),
    active = BtWQuests.LegionArtifactActive("SHAMAN", 3),
    completed = {
        type = "quest",
        id = 40341,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Shaman-Restoration",
    items = {
        {
            type = "quest",
            id = 43644,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43645,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40341,
            x = 3,
            y = 2,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_CAMPAIGN, {
    name = L["BTWQUESTS_SHAMAN_CAMPAIGN"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_SHAMAN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_CAMPAIGN,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_SHAMAN,
        },
    },
    completed = {
        type = "quest",
        id = 41888,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 39746,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41335,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3, 4,
            },
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ELEMENTAL,
            active = {
                type = "quest",
                id = 41335,
            },
            visible = BtWQuests.LegionArtifactNonSelected("SHAMAN"),
            x = 1,
            y = 2,
            connections = {
                4
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ENHANCEMENT,
            active = {
                type = "quest",
                id = 41335,
            },
            visible = BtWQuests.LegionArtifactNonSelected("SHAMAN"),
            x = 3,
            y = 2,
            connections = {
                3
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_RESTORATION,
            active = {
                type = "quest",
                id = 41335,
            },
            visible = BtWQuests.LegionArtifactNonSelected("SHAMAN"),
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
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ELEMENTAL,
                    restrictions = {
                        type = "quest",
                        id = 41329,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ENHANCEMENT,
                    restrictions = {
                        type = "quest",
                        id = 41328,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_RESTORATION,
                    restrictions = {
                        type = "quest",
                        id = 41330,
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
            id = 40225,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        -- {
        --     type = "quest",
        --     id = 40276,
        --     x = 3,
        --     y = 4,
        --     connections = {
        --         1
        --     },
        -- },
        {
            type = "quest",
            id = 41510,
            x = 3,
            y = 5,
            connections = {
                2
            },
        },


        {
            type = "level",
            level = 101,
            x = 5,
            y = 5.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44544,
            breadcrumb = true,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42188,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42114,
            x = 3,
            y = 8,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42383,
            x = 3,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42141,
            x = 3,
            y = 10,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42142,
            x = 3,
            y = 11,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41741,
            x = 3,
            y = 12,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41740,
            x = 3,
            y = 13,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42184,
            x = 3,
            y = 14,
            connections = {
                2
            },
        },


        {
            type = "level",
            level = 103,
            x = 5,
            y = 14.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42977,
            x = 3,
            y = 15,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43002,
            x = 3,
            y = 16,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41770,
            x = 3,
            y = 17,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41771,
            x = 3,
            y = 18,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41776,
            x = 3,
            y = 19,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41901,
            x = 3,
            y = 20,
            connections = {
                1, 2, 3, 4, 5
            },
        },


        {
            type = "quest",
            id = 41742,
            x = 1,
            y = 20,
        },
        {
            type = "quest",
            id = 41743,
            x = 5,
            y = 20,
        },


        {
            type = "quest",
            id = 44465,
            x = 1,
            y = 21,
        },
        {
            type = "quest",
            id = 42986,
            x = 5,
            y = 21,
        },
        {
            type = "quest",
            id = 42996,
            x = 3,
            y = 21,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 42983,
            x = 3,
            y = 22,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42984,
            x = 3,
            y = 23,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42200,
            x = 3,
            y = 24,
            connections = {
                2
            },
        },



        {
            type = "level",
            level = 45,
            x = 5,
            y = 24.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41775,
            x = 3,
            y = 25,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42068,
            x = 3,
            y = 26,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 41777,
            x = 2,
            y = 27,
            connections = {
                2, 3
            },
        },
        {
            type = "quest",
            id = 41897,
            x = 4,
            y = 27,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 41898,
            x = 2,
            y = 28,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 41899,
            x = 4,
            y = 28,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 42065,
            x = 3,
            y = 29,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41900,
            x = 3,
            y = 30,
            connections = {
                1, 2, 3, 4, 5
            },
        },


        {
            type = "quest",
            id = 41746,
            x = 1,
            y = 30,
        },
        {
            type = "quest",
            id = 41747,
            x = 5,
            y = 30,
        },


        {
            type = "quest",
            id = 42988,
            x = 1,
            y = 31,
        },
        {
            type = "quest",
            id = 42997,
            x = 3,
            y = 31,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42208,
            x = 5,
            y = 31,
        },
        {
            type = "quest",
            id = 42989,
            x = 3,
            y = 32,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42995,
            x = 3,
            y = 33,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43003,
            x = 3,
            y = 34,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42990,
            x = 3,
            y = 35,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 41772,
            x = 3,
            y = 36,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41773,
            x = 3,
            y = 37,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41934,
            x = 3,
            y = 38,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41888,
            x = 3,
            y = 39,
            connections = {
                1, 2, 3
            },
        },


        {
            type = "quest",
            id = 41744,
            aside = true,
            x = 1,
            y = 40,
        },
        {
            type = "quest",
            id = 43418,
            aside = true,
            x = 3,
            y = 40,
        },
        {
            type = "quest",
            id = 41745,
            aside = true,
            x = 5,
            y = 40,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_FOLLOWER, {
    name = { -- Champion: Magatha Grimtotem
		type = "quest",
		id = 46057,
	},
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_SHAMAN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_ALLIANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_HORDE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FOLLOWER_ALLIANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FOLLOWER_HORDE,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_SHAMAN,
        },
    },
    completed = {
        type = "quest",
        id = 46057,
    },
    range = {98,45},
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
            id = 45652,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45706,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3
            },
        },


        {
            type = "quest",
            id = 45723,
            x = 1,
            y = 3,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 45725,
            x = 3,
            y = 3,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45724,
            x = 5,
            y = 3,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 44800,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45763,
            x = 3,
            y = 5,
            connections = {
                1, 2, 3
            },
        },


        {
            type = "quest",
            id = 45971,
            x = 1,
            y = 6,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 45767,
            x = 3,
            y = 6,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45765,
            x = 5,
            y = 6,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 45883,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45769,
            x = 3,
            y = 8,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46258,
            x = 3,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46057,
            x = 3,
            y = 10,
            connections = {
                1
            },
        },



        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            aside = true,
            x = 3,
            y = 11,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_MOUNT, {
    name = L["BTWQUESTS_SHAMAN_MOUNT"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_SHAMAN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_MOUNT,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_SHAMAN,
        },
    },
    completed = {
        type = "quest",
        id = 46792,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 46791,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46792,
            x = 3,
            y = 1,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_CLASSES_SHAMAN, {
    name = LOCALIZED_CLASS_NAMES_MALE["SHAMAN"],
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DEATHKNIGHT,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DEMONHUNTER,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DRUID,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_HUNTER,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_MAGE,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_MONK,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_PALADIN,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_PRIEST,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_ROGUE,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_WARLOCK,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_WARRIOR,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_SHAMAN,
        }
    },
    -- buttonImage = 1041999,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_CAMPAIGN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_FOLLOWER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_MOUNT,
        },
    },
})