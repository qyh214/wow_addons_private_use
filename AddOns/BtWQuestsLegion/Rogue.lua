local L = BtWQuests.L;
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_ASSASSINATION, {
    name = L["ASSASSINATION_THE_KINGSLAYERS"],
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
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ELEMENTAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_AFFLICTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_ARMS,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_ROGUE,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("ROGUE", 1),
    active = BtWQuests.LegionArtifactActive("ROGUE", 1),
    completed = {
        type = "quest",
        id = 42504,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Rogue-Assassination",
    items = {
        {
            type = "npc",
            id = 94138,
            x = 3,
            y = 0,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 42501,
            x = 2,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42502,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42503,
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42539,
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42568,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            ids = {42504, 42627},
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_OUTLAW, {
    name = L["OUTLAW_THE_DREADBLADES"],
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
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ENHANCEMENT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_DEMONOLOGY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FURY,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_ROGUE,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("ROGUE", 2),
    active = BtWQuests.LegionArtifactActive("ROGUE", 2),
    completed = {
        type = "quest",
        id = 40849,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Rogue-Outlaw",
    items = {
        {
            type = "npc",
            id = 94159,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40847,
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40849,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_SUBTLETY, {
    name = L["SUBTLETY_FANGS_OF_THE_DEVOURER"],
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
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_RESTORATION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_DESTRUCTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_PROTECTION,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_ROGUE,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("ROGUE", 3),
    active = BtWQuests.LegionArtifactActive("ROGUE", 3),
    completed = {
        type = "quest",
        id = 41924,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Rogue-Subtlety",
    items = {
        {
            type = "quest",
            id = 41919,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41920,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41921,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41922,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41924,
            x = 3,
            y = 4,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_CAMPAIGN, {
    name = L["BTWQUESTS_ROGUE_CAMPAIGN"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_ROGUE,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {10,45},
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_CAMPAIGN,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_ROGUE,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        id = 40832,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 37689,
    },
    items = {
        {
            type = "quest",
            id = 40832,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40839,
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40840,
            x = 3,
            connections = {
                1, 2, 3, 4,
            },
        },



        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_ASSASSINATION,
            active = {
                type = "quest",
                id = 40840,
            },
            visible = BtWQuests.LegionArtifactNonSelected("ROGUE"),
            x = 1,
            connections = {
                4
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_OUTLAW,
            active = {
                type = "quest",
                id = 40840,
            },
            visible = BtWQuests.LegionArtifactNonSelected("ROGUE"),
            connections = {
                3
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_SUBTLETY,
            active = {
                type = "quest",
                id = 40840,
            },
            visible = BtWQuests.LegionArtifactNonSelected("ROGUE"),
            connections = {
                2
            },
        },



        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_ASSASSINATION,
                    restrictions = {
                        type = "quest",
                        id = 40842
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_OUTLAW,
                    restrictions = {
                        type = "quest",
                        id = 40843
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_SUBTLETY,
                    restrictions = {
                        type = "quest",
                        id = 40844
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
            id = 40950,
            x = 3,
            connections = {
                1
            },
        },
        -- {
        --     type = "quest",
        --     id = 40994,
        --     x = 3,
        --     y = 5,
        --     connections = {
        --         1
        --     },
        -- },
        -- {
        --     type = "quest",
        --     id = 40995,
        --     x = 3,
        --     y = 6,
        --     connections = {
        --         1
        --     },
        -- },
        {
            type = "quest",
            id = 40996,
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40997,
            x = 3,
            connections = {
                1
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 43007,
                    restrictions = {
                        type = "quest",
                        id = 43007,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 101513,
                },
            },
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42139,
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42140,
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43013,
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43014,
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43015,
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43958,
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43829,
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44041,
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44116,
            x = 3,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 44155,
            x = 2,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 44117,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44177,
            x = 3,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 43841,
            x = 3,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 44183,
        },
        {
            type = "quest",
            id = 43852,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 44181,
            x = 3,
            connections = {
                1, 2, 3
            },
        },


        {
            type = "quest",
            id = 42730,
            x = 1,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 42684,
            connections = {
                5
            },
        },
        {
            type = "quest",
            id = 43468,
            connections = {
                4
            },
        },



        {
            type = "quest",
            id = 44178,
            x = 1,
            connections = {
                1, 3
            },
        },
        {
            type = "quest",
            id = 44180,
            x = 0,
        },





        {
            type = "level",
            level = 45,
            x = 5,
            y = 25.5,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 43253,
            x = 3,
            y = 26,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 44252,
            x = 5,
            y = 26.5,
        },
        {
            type = "quest",
            id = 43249,
            x = 3,
            y = 27,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43250,
            x = 3,
            y = 28,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 43251,
            x = 2,
            y = 29,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43252,
            x = 4,
            y = 29,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42678,
            x = 3,
            y = 30,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42680,
            x = 3,
            y = 31,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 42800,
            x = 1,
            y = 31,
        },
        {
            type = "quest",
            id = 43469,
            x = 2,
            y = 32,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 43470,
            x = 4,
            y = 32,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43479,
            x = 4,
            y = 33,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43485,
            x = 3,
            y = 34,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43508,
            x = 3,
            y = 35,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 37666,
            x = 3,
            y = 36,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 37448,
            x = 3,
            y = 37,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 37494,
            x = 3,
            y = 38,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 37689,
            x = 3,
            y = 39,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 43723,
            x = 2,
            y = 40,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43724,
            x = 4,
            y = 40,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44215,
            x = 3,
            y = 41,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43422,
            x = 3,
            y = 42,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_ALLIANCE, {
    name = { -- Champion: Tess Greymane
		type = "quest",
		id = 46059,
	},
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_ROGUE,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {45},
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_HORDE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FOLLOWER_ALLIANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FOLLOWER_HORDE,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_ROGUE,
        },
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_ALLIANCE,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            upto = 47137,
            completed = {
                type = "quest",
                id = 47137,
                status = {'active', 'completed'}
            }
        }
    },
    active = {
        type = "quest",
        ids = {45833, 46322},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 46059,
    },
    items = {
        {
            type = "npc",
            id = 101513,
            x = 3,
            y = 1,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 45833,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 2,
            connections = {
                2, 4, 6
            },
        },
        {
            type = "quest",
            id = 46322,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 2,
            connections = {
                2, 4, 5
            },
        },



        {
            type = "quest",
            id = 45835,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 1,
            y = 3,
            connections = {
                5
            },
        },
        {
            type = "quest",
            id = 46324,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 1,
            y = 3,
            connections = {
                4
            },
        },

        {
            type = "quest",
            id = 44758,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 3,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 46323,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 3,
            connections = {
                2
            },
        },

        {
            type = "quest",
            id = 45073,
            x = 5,
            y = 3,
            connections = {
                1
            },
        },



        {
            type = "quest",
            id = 45848,
            x = 3,
            y = 4,
            connections = {
                1, 2
            },
        },

        {
            type = "quest",
            id = 45836,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 5,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 46326,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 5,
            connections = {
                1
            },
        },

        {
            type = "quest",
            id = 45571,
            x = 3,
            y = 6,
            connections = {
                1, 2
            },
        },





        {
            type = "quest",
            id = 45573,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 7,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45576,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 7,
            connections = {
                2
            },
        },

        {
            type = "quest",
            id = 45628,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 8,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45629,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 8,
            connections = {
                2
            },
        },

        {
            type = "quest",
            id = 46260,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 9,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 46827,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 9,
            connections = {
                2
            },
        },

        {
            type = "quest",
            id = 46059,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 10,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 46058,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 10,
            connections = {
                1
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            userdata = {
                scrollTo = {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_ALLIANCE,
                },
            },
            aside = true,
            x = 3,
            y = 11,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_HORDE, {
    name = { -- Champion: Lilian Voss
		type = "quest",
		id = 46058,
	},
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_ROGUE,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {45},
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_ALLIANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FOLLOWER_ALLIANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FOLLOWER_HORDE,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_ROGUE,
        },
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            upto = 47137,
            completed = {
                type = "quest",
                id = 47137,
                status = {'active', 'completed'}
            }
        }
    },
    active = {
        type = "quest",
        ids = {45833, 46322},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 46059,
    },
    items = {
        {
            type = "npc",
            id = 101513,
            x = 3,
            y = 1,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 45833,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 2,
            connections = {
                2, 4, 6
            },
        },
        {
            type = "quest",
            id = 46322,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 2,
            connections = {
                2, 4, 5
            },
        },



        {
            type = "quest",
            id = 45835,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 1,
            y = 3,
            connections = {
                5
            },
        },
        {
            type = "quest",
            id = 46324,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 1,
            y = 3,
            connections = {
                4
            },
        },

        {
            type = "quest",
            id = 44758,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 3,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 46323,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 3,
            connections = {
                2
            },
        },

        {
            type = "quest",
            id = 45073,
            x = 5,
            y = 3,
            connections = {
                1
            },
        },



        {
            type = "quest",
            id = 45848,
            x = 3,
            y = 4,
            connections = {
                1, 2
            },
        },

        {
            type = "quest",
            id = 45836,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 5,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 46326,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 5,
            connections = {
                1
            },
        },

        {
            type = "quest",
            id = 45571,
            x = 3,
            y = 6,
            connections = {
                1, 2
            },
        },





        {
            type = "quest",
            id = 45573,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 7,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45576,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 7,
            connections = {
                2
            },
        },

        {
            type = "quest",
            id = 45628,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 8,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45629,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 8,
            connections = {
                2
            },
        },

        {
            type = "quest",
            id = 46260,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 9,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 46827,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 9,
            connections = {
                2
            },
        },

        {
            type = "quest",
            id = 46059,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 10,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 46058,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 10,
            connections = {
                1
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            userdata = {
                scrollTo = {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_HORDE,
                },
            },
            aside = true,
            x = 3,
            y = 11,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_MOUNT, {
    name = L["BTWQUESTS_ROGUE_MOUNT"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_ROGUE,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {45},
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_MOUNT,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_ROGUE,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
        },
    },
    active = {
        type = "quest",
        id = 46103,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 46089,
    },
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Rogue-Mount",
    items = {
        {
            type = "npc",
            id = 101513,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 46103,
            x = 3,
            y = 1,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 46089,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 2,
        },
        {
            type = "quest",
            id = 46178,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 2,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_CLASSES_ROGUE, {
    name = LOCALIZED_CLASS_NAMES_MALE["ROGUE"],
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
        BTWQUESTS_CATEGORY_LEGION_CLASSES_SHAMAN,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_WARLOCK,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_WARRIOR,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_ROGUE,
        }
    },
    -- buttonImage = 1041999,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_CAMPAIGN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_MOUNT,
        },
    },
})