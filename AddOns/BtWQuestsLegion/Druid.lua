local L = BtWQuests.L;
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_BALANCE, {
    name = L["BALANCE_SCYTHE_OF_ELUNE"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_BLOOD,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_HAVOC,
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
            id = BTWQUESTS_CLASS_ID_DRUID,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("DRUID", 1),
    active = BtWQuests.LegionArtifactActive("DRUID", 1),
    completed = {
        type = "quest",
        id = 40838,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Druid-Balance",
    items = {
        {
            type = "quest",
            id = 40783,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40784,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40785,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40834,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40835,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40837,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40838,
            x = 3,
            y = 6,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FERAL, {
    name = L["FERAL_FANGS_OF_ASHAMANE"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FROST,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
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
            id = BTWQUESTS_CLASS_ID_DRUID,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("DRUID", 2),
    active = BtWQuests.LegionArtifactActive("DRUID", 2),
    completed = {
        type = "quest",
        id = 42430,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Druid-Feral",
    items = {
        {
            type = "quest",
            id = 42428,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42438,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42439,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42440,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42430,
            x = 3,
            y = 4,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_GUARDIAN, {
    name = L["GUARDIAN_CLAWS_OF_URSOC"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_UNHOLY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
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
            id = BTWQUESTS_CLASS_ID_DRUID,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("DRUID", 3),
    active = BtWQuests.LegionArtifactActive("DRUID", 3),
    completed = {
        type = "quest",
        id = 40647,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Druid-Guardian",
    items = {
        {
            type = "quest",
            id = 41468,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41782,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41783,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41790,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41791,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41792,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40647,
            x = 3,
            y = 6,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_RESTORATION, {
    name = L["RESTORATION_GHANIR_THE_MOTHER_TREE"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_UNHOLY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
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
            id = BTWQUESTS_CLASS_ID_DRUID,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("DRUID", 4),
    active = BtWQuests.LegionArtifactActive("DRUID", 4),
    completed = {
        type = "quest",
        id = 41689,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Druid-Restoration",
    items = {
        {
            type = "quest",
            id = 40649,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41422,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41449,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41436,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41690,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41689,
            x = 3,
            y = 5,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_CAMPAIGN, {
    name = L["BTWQUESTS_DRUID_CAMPAIGN"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_DRUID,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_CAMPAIGN,
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
            id = BTWQUESTS_CLASS_ID_DRUID,
        },
    },
    completed = {
        type = "quest",
        id = 42055,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 40643,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41106,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40644,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40645,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40646,
            x = 3,
            y = 4,
            connections = {
                1, 2, 3, 4, 5,
            },
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_BALANCE,
            active = {
                type = "quest",
                id = 40646,
            },
            visible = BtWQuests.LegionArtifactNonSelected("DRUID"),
            x = 0,
            y = 5,
            connections = {
                5
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FERAL,
            active = {
                type = "quest",
                id = 40646,
            },
            visible = BtWQuests.LegionArtifactNonSelected("DRUID"),
            x = 2,
            y = 5,
            connections = {
                4
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_GUARDIAN,
            active = {
                type = "quest",
                id = 40646,
            },
            visible = BtWQuests.LegionArtifactNonSelected("DRUID"),
            x = 4,
            y = 5,
            connections = {
                3
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_RESTORATION,
            active = {
                type = "quest",
                id = 40646,
            },
            visible = BtWQuests.LegionArtifactNonSelected("DRUID"),
            x = 6,
            y = 5,
            connections = {
                2
            },
        },


        {
            variations = {

                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_BALANCE,
                    restrictions = {
                        type = "quest",
                        id = 40781,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FERAL,
                    restrictions = {
                        type = "quest",
                        id = 40701,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_GUARDIAN,
                    restrictions = {
                        type = "quest",
                        id = 40702,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_RESTORATION,
                    restrictions = {
                        type = "quest",
                        id = 40703,
                    },
                },
                {
                    visible = false,
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
            id = 41918,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        -- {
        --     type = "quest",
        --     id = 40651,
        --     x = 3,
        --     y = 7,
        --     connections = {
        --         1
        --     },
        -- },
        {
            type = "quest",
            id = 41332,
            x = 3,
            y = 8,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40652,
            x = 3,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40653,
            x = 3,
            y = 10,
            connections = {
                2
            },
        },




        {
            type = "level",
            level = 101,
            x = 5,
            y = 10.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42516,
            breadcrumb = true,
            x = 3,
            y = 11,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42583,
            x = 3,
            y = 12,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42584,
            x = 3,
            y = 13,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42585,
            x = 3,
            y = 14,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42586,
            x = 3,
            y = 15,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42588,
            x = 3,
            y = 16,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42032,
            x = 3,
            y = 17,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42031,
            x = 3,
            y = 18,
            connections = {
                2
            },
        },



        {
            type = "level",
            level = 103,
            x = 5,
            y = 18.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42033,
            x = 3,
            y = 19,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42034,
            x = 3,
            y = 20,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42035,
            x = 3,
            y = 21,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42036,
            x = 3,
            y = 22,
            connections = {
                1, 2, 3, 4, 5
            },
        },
        {
            type = "quest",
            id = 42038,
            aside = true,
            x = 1,
            y = 22,
        },
        {
            type = "quest",
            id = 42039,
            aside = true,
            x = 5,
            y = 22,
        },

        {
            type = "quest",
            id = 43991,
            x = 1,
            y = 23,
            connections = {
                3, 4, 5, 6
            },
        },
        {
            type = "quest",
            id = 40654,
            aside = true,
            x = 3,
            y = 23,
        },
        {
            type = "quest",
            id = 42037,
            x = 5,
            y = 23,
            connections = {
                1, 2, 3, 4
            },
        },



        {
            type = "quest",
            id = 44077,
            x = 0,
            y = 24,
            connections = {
                5
            },
        },
        {
            type = "quest",
            id = 44076,
            x = 2,
            y = 24,
            connections = {
                4
            },
        },
        {
            type = "quest",
            id = 44075,
            x = 4,
            y = 24,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 44074,
            x = 6,
            y = 24,
            connections = {
                2
            },
        },

        {
            type = "level",
            level = 45,
            x = 5,
            y = 25.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42040,
            x = 3,
            y = 26,
            connections = {
                1, 2, 3
            },
        },


        {
            type = "quest",
            id = 42042,
            x = 1,
            y = 27,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 42043,
            x = 3,
            y = 27,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42041,
            x = 5,
            y = 27,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 42044,
            x = 3,
            y = 28,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42045,
            x = 3,
            y = 29,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42046,
            x = 3,
            y = 30,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 42048,
            x = 2,
            y = 31,
            connections = {
                2, 3, 4
            },
        },
        {
            type = "quest",
            id = 42047,
            x = 4,
            y = 31,
            connections = {
                1, 2, 3
            },
        },


        {
            type = "quest",
            id = 42049,
            x = 1,
            y = 32,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 42365,
            x = 3,
            y = 32,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43403,
            x = 5,
            y = 32,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 42051,
            x = 3,
            y = 33,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42050,
            x = 3,
            y = 34,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42053,
            x = 3,
            y = 35,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42054,
            x = 3,
            y = 36,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42055,
            x = 3,
            y = 37,
            connections = {
                1, 2, 3
            },
        },

        {
            type = "quest",
            id = 42432,
            aside = true,
            x = 1,
            y = 38,
        },
        {
            type = "quest",
            id = 42056,
            aside = true,
            x = 3,
            y = 38,
        },
        {
            type = "quest",
            id = 43409,
            aside = true,
            x = 5,
            y = 38,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FOLLOWER, {
    name = { -- Champion: Thisalee Crow
		type = "quest",
		id = 46044,
	},
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_DRUID,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_FOLLOWER,
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
            id = BTWQUESTS_CLASS_ID_DRUID,
        },
    },
    completed = {
        type = "quest",
        id = 46044,
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
            id = 44869,
            x = 3,
            y = 1,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 44877,
            x = 2,
            y = 2,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45532,
            x = 4,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44888,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44921,
            x = 3,
            y = 4,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 45498,
            x = 2,
            y = 5,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45528,
            x = 4,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46924,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45426,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46674,
            x = 3,
            y = 8,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 46676,
            x = 2,
            y = 9,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 46675,
            x = 4,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46677,
            x = 3,
            y = 10,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45425,
            x = 3,
            y = 11,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46044,
            x = 3,
            y = 12,
            connections = {
                1
            },
        },



        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            aside = true,
            x = 3,
            y = 13,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_MOUNT, {
    name = L["BTWQUESTS_DRUID_MOUNT"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_DRUID,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_MOUNT,
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
            id = BTWQUESTS_CLASS_ID_DRUID,
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
        id = 46319,
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
            id = 46317,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46318,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46319,
            x = 3,
            y = 3,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_CLASSES_DRUID, {
    name = LOCALIZED_CLASS_NAMES_MALE["DRUID"],
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DEATHKNIGHT,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DEMONHUNTER,
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
            id = BTWQUESTS_CLASS_ID_DRUID,
        }
    },
    -- buttonImage = 1041999,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_CAMPAIGN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FOLLOWER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_MOUNT,
        },
    },
})