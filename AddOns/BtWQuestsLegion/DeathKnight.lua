local L = BtWQuests.L;
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_BLOOD, {
    name = L["BLOOD_MAW_OF_THE_DAMNED"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_HAVOC,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_BALANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_BEASTMASTERY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_ARCANE,
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
            id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("DEATHKNIGHT", 1),
    active = BtWQuests.LegionArtifactActive("DEATHKNIGHT", 1),
    completed = {
        type = "quest",
        id = 40740,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-DeathKnight-Blood",
    items = {
        {
            type = "quest",
            id = 40740,
            x = 3,
            y = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FROST, {
    name = L["FROST_BLADES_OF_THE_FALLEN_PRINCE"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FERAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_MARKSMANSHIP,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FIRE,
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
            id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("DEATHKNIGHT", 2),
    active = BtWQuests.LegionArtifactActive("DEATHKNIGHT", 2),
    completed = {
        type = "quest",
        id = 38990,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-DeathKnight-Frost",
    items = {
        {
            type = "quest",
            id = 38990,
            x = 3,
            y = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_UNHOLY, {
    name = L["UNHOLY_APOCALYPSE"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_GUARDIAN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_SURVIVAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FROST,
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
            id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("DEATHKNIGHT", 3),
    active = BtWQuests.LegionArtifactActive("DEATHKNIGHT", 3),
    completed = {
        type = "quest",
        id = 40935,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-DeathKnight-Unholy",
    items = {
        {
            type = "quest",
            id = 40930,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40931,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40932,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40933,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40934,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40935,
            x = 3,
            y = 5,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_CAMPAIGN, {
    name = L["BTWQUESTS_DEATHKNIGHT_CAMPAIGN"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_DEATHKNIGHT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_CAMPAIGN,
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
            id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    completed = {
        type = "quest",
        id = 43686,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 40714,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40715,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3, 4,
            },
        },



        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_BLOOD,
            active = {
                type = "quest",
                id = 40715,
            },
            visible = BtWQuests.LegionArtifactNonSelected("DEATHKNIGHT"),
            x = 1,
            y = 2,
            connections = {
                4
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FROST,
            active = {
                type = "quest",
                id = 40715,
            },
            visible = BtWQuests.LegionArtifactNonSelected("DEATHKNIGHT"),
            x = 3,
            y = 2,
            connections = {
                3
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_UNHOLY,
            active = {
                type = "quest",
                id = 40715,
            },
            visible = BtWQuests.LegionArtifactNonSelected("DEATHKNIGHT"),
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
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_BLOOD,
                    restrictions = {
                        type = "quest",
                        id = 40722,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FROST,
                    restrictions = {
                        type = "quest",
                        id = 40723,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_UNHOLY,
                    restrictions = {
                        type = "quest",
                        id = 40724,
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




        -- {
        --     type = "quest",
        --     id = 39757,
        --     x = 3,
        --     y = 3,
        --     connections = {
        --         1
        --     },
        -- },


        -- {
        --     type = "quest",
        --     id = 39761,
        --     x = 3,
        --     y = 4,
        --     connections = {
        --         1
        --     },
        -- },
        {
            type = "quest",
            id = 39832,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39799,
            x = 3,
            y = 6,
            connections = {
                1--, 2, 3, 4, 5
            },
        },
        -- {
            -- type = "chain",
            -- id = BTWQUESTS_CHAIN_LEGION_AZSUNA_BEHINDENEMYLINES,
            -- name = BtWQuests_GetMapName(1015),
            -- aside = true,
            -- x = 1,
            -- y = 5.5,
        -- },
        -- {
            -- type = "chain",
            -- id = BTWQUESTS_CHAIN_LEGION_VALSHARAH_INTRODUCTION,
            -- name = BtWQuests_GetMapName(1018),
            -- aside = true,
            -- x = 1,
            -- y = 6.5
        -- },
        -- {
            -- type = "chain",
            -- id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERMANE_TRIBE,
            -- name = BtWQuests_GetMapName(1024),
            -- aside = true,
            -- x = 5,
            -- y = 5.5,
        -- },
        -- {
            -- type = "chain",
            -- id = BTWQUESTS_CHAIN_LEGION_STORMHEIM_GREYMANES_GAMBIT,
            -- name = BtWQuests_GetMapName(1017),
            -- aside = true,
            -- x = 5,
            -- y = 6.5,
        -- },
        {
            type = "quest",
            id = 42449,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42484,
            x = 3,
            y = 8,
            connections = {
                2
            },
        },


        {
            type = "level",
            level = 101,
            x = 5,
            y = 8.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44550,
            breadcrumb = true,
            x = 3,
            y = 9,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43264,
            x = 3,
            y = 10,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 39818,
            x = 1,
            y = 11,
        },
        {
            type = "quest",
            id = 39816,
            x = 5,
            y = 11,
        },
        {
            type = "quest",
            id = 43265,
            x = 3,
            y = 11,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43266,
            x = 3,
            y = 12,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43267,
            x = 3,
            y = 13,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43539,
            x = 3,
            y = 14,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43268,
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
            id = 42533,
            x = 3,
            y = 16,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 42534,
            x = 3,
            y = 17,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42535,
            x = 3,
            y = 18,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42536,
            x = 3,
            y = 19,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42537,
            x = 3,
            y = 20,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 44243,
            x = 5,
            y = 20,
        },
        {
            type = "quest",
            id = 42708,
            x = 3,
            y = 21,
            connections = {
                1, 2, 3, 4
            },
        },
        {
            type = "quest",
            id = 44244,
            x = 1,
            y = 21,
        },
        {
            type = "quest",
            id = 44082,
            x = 5,
            y = 21,
        },
        {
            type = "quest",
            id = 43899,
            x = 2,
            y = 22,
            connections = {
                5
            },
        },
        {
            type = "quest",
            id = 43571,
            x = 4,
            y = 22,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43572,
            x = 4,
            y = 23,
            connections = {
                3
            },
        },


        {
            type = "level",
            level = 45,
            x = 6,
            y = 23.5,
            connections = {
                1, 2
            },
        },

        {
            type = "quest",
            id = 44217,
            aside = true,
            x = 6,
            y = 24.5,
        },


        {
            type = "quest",
            id = 42818,
            x = 3,
            y = 24,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 42882,
            x = 2,
            y = 25,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42821,
            x = 4,
            y = 25,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42823,
            x = 3,
            y = 26,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42824,
            x = 3,
            y = 27,
            connections = {
                1, 2, 3, 4
            },
        },
        {
            type = "quest",
            id = 44245,
            x = 5,
            y = 27,
        },


        {
            type = "quest",
            id = 43573,
            x = 2,
            y = 28,
            connections = {
                6
            },
        },
        {
            type = "quest",
            id = 43928,
            x = 4,
            y = 28,
            connections = {
                3, 5
            },
        },


        {
            type = "quest",
            id = 44286,
            x = 1,
            y = 27,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44246,
            x = 0,
            y = 28,
        },


        {
            type = "quest",
            id = 44282,
            x = 6,
            y = 28,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44247,
            x = 6,
            y = 29,
        },

        {
            type = "quest",
            id = 44690,
            x = 3,
            y = 29,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43574,
            x = 3,
            y = 30,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43686,
            x = 3,
            y = 31,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 44248,
            x = 2,
            y = 32,
        },
        {
            type = "quest",
            id = 43407,
            x = 4,
            y = 32,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FOLLOWER, {
    name = { -- Champion: Minerva Ravensorrow
		type = "quest",
		id = 46050,
	},
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_DEATHKNIGHT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FOLLOWER,
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
            id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
        },
    },
    completed = {
        type = "quest",
        id = 46050,
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
            id = 45240,
            x = 3,
            y = 1,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 45399,
            x = 2,
            y = 2,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45398,
            x = 4,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45331,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44775,
            x = 3,
            y = 4,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 44783,
            x = 2,
            y = 5,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 46305,
            x = 4,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44787,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 45243,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 45103,
            x = 3,
            y = 8,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 46050,
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
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_MOUNT, {
    name = L["BTWQUESTS_DEATHKNIGHT_MOUNT"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_DEATHKNIGHT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_MOUNT,
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
            id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
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
        id = 46720,
    },
    rewards = {
        {
            type = "mount",
            id = 866,
        },
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
            id = 46719,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46720,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46812,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46813,
            x = 3,
            y = 4,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_CLASSES_DEATHKNIGHT, {
    name = LOCALIZED_CLASS_NAMES_MALE["DEATHKNIGHT"],
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DEMONHUNTER,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DRUID,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_HUNTER,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_MAGE,
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
            id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
        }
    },
    -- buttonImage = 1041999,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_CAMPAIGN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FOLLOWER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_MOUNT,
        },
    },
})