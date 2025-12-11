local L = BtWQuests.L;
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_STARTING_ZONE, {
    name = L["DEMON_HUNTER_STARTING_ZONE"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_DEMONHUNTER,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_DEMONHUNTER,
        },
    },
    completed = {
        type = "quest",
        id = 44663,
    },
    range = {98},
    items = {
        {
            type = "quest",
            id = 40077,
            x = 3,
            y = 0,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 40378,
            x = 3,
            y = 1,
            connections = {
                2,
                3,
                4,
            },
        },
        {
            type = "quest",
            id = 39279,
            aside = true,
            x = 5,
            y = 1,
        },
        {
            type = "quest",
            id = 38759,
            x = 1,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 39049,
            x = 3,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40379,
            x = 5,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39050,
            x = 3,
            y = 3,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 38765,
            x = 2,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 38766,
            x = 4,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38813,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39262,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39495,
            x = 3,
            y = 7,
            connections = {
                1,
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 38727,
            x = 1,
            y = 8,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 38725,
            x = 3,
            y = 8,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 38819,
            x = 5,
            y = 8,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40222,
            x = 3,
            y = 9,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40051,
            x = 3,
            y = 10,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 39516,
                    restrictions = {
                        {
                            type = "quest",
                            id = 39517,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 39515,
                    restrictions = {
                        {
                            type = "quest",
                            id = 39518,
                        },
                    },
                },
            },
            x = 3,
            y = 11,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39663,
            x = 3,
            y = 12,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38728,
            x = 3,
            y = 13,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38729,
            x = 3,
            y = 14,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38672,
            x = 3,
            y = 15,
            connections = {
                1,
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 39742,
            x = 5,
            y = 15,
        },
        {
            type = "quest",
            id = 38689,
            x = 2,
            y = 16,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 38690,
            x = 4,
            y = 16,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 38723,
                    restrictions = {
                        {
                            type = "quest",
                            id = 39517,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40253,
                    restrictions = {
                        {
                            type = "quest",
                            id = 39518,
                        },
                    },
                },
            },
            x = 3,
            y = 17,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39682,
            x = 3,
            y = 18,
            connections = {
                1,
                2,
                3,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 39683,
                    restrictions = {
                        {
                            type = "quest",
                            id = 39517,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40254,
                    restrictions = {
                        {
                            type = "quest",
                            id = 39518,
                        },
                    },
                },
            },
            x = 1,
            y = 19,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 39684,
            x = 3,
            y = 19,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 39685,
            x = 5,
            y = 19,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39686,
            x = 3,
            y = 20,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40373,
            x = 3,
            y = 21,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 39688,
                    restrictions = {
                        {
                            type = "quest",
                            id = 39517,
                        },
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 39694,
                    restrictions = {
                        {
                            type = "quest",
                            id = 39517,
                        },
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40255,
                    restrictions = {
                        {
                            type = "quest",
                            id = 39518,
                        },
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40256,
                    restrictions = {
                        {
                            type = "quest",
                            id = 39518,
                        },
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                },
            },
            x = 3,
            y = 22,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 39689,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 39690,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                },
            },
            x = 3,
            y = 23,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 39691,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40976,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                },
            },
            x = 3,
            y = 24,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 44471,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40982,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                },
            },
            x = 3,
            y = 25,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 44463,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40983,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                },
            },
            x = 3,
            y = 26,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 44473,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 41002,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                },
            },
            x = 3,
            y = 27,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 44663,
            x = 3,
            y = 28,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_CAMPAIGN,
            aside = true,
            x = 3,
            y = 29,
        }
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_HAVOC, {
    name = L["HAVOC_TWINBLADES_OF_THE_DECEIVER"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_BLOOD,
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
            id = BTWQUESTS_CLASS_ID_DEMONHUNTER,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("DEMONHUNTER", 1),
    active = BtWQuests.LegionArtifactActive("DEMONHUNTER", 1),
    completed = {
        type = "quest",
        id = 41119,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-DemonHunter-Havoc",
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 40819,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 41120,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 39051,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 41121,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 39247,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 41119,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 2,
        }
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE, {
    name = L["VENGEANCE_ALDRACHI_WARBLADES"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FROST,
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
            id = BTWQUESTS_CLASS_ID_DEMONHUNTER,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("DEMONHUNTER", 2),
    active = BtWQuests.LegionArtifactActive("DEMONHUNTER", 2),
    completed = {
        type = "quest",
        id = 40249,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-DemonHunter-Vengeance",
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 40247,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 41803,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 41804,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41806,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41807,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 40249,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 41863,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 4,
        }
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_CAMPAIGN, {
    name = L["BTWQUESTS_DEMONHUNTER_CAMPAIGN"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_DEMONHUNTER,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_CAMPAIGN,
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
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_STARTING_ZONE
        },
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_DEMONHUNTER,
        },
    },
    completed = {
        type = "quest",
        id = 43186,
    },
    range = {98,45},
    items = {
        {
            variations = {
                { -- Kayn
                    type = "quest",
                    id = 39261,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        }
                    },
                },
                { -- Altruis
                    type = "quest",
                    id = 39047,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        }
                    },
                },
            },
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 40814,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40816,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 1,
            connections = {
                1, 2, 3,
            },
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_HAVOC,
            active = {
                type = "quest",
                id = 40814,
            },
            visible = BtWQuests.LegionArtifactNonSelected("DEMONHUNTER"),
            x = 2,
            y = 2,
            connections = {
                3
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
            active = {
                type = "quest",
                id = 40814,
            },
            visible = BtWQuests.LegionArtifactNonSelected("DEMONHUNTER"),
            x = 4,
            y = 2,
            connections = {
                2
            },
        },


        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_HAVOC,
                    restrictions = {
						type = "quest",
						id = 40817,
					},
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
                    restrictions = {
						type = "quest",
						id = 40818,
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
            id = 42869,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42872,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 41221,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 41033,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 41037,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 41060,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 41062,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 41070,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        -- {
        --     type = "quest",
        --     id = 41064,
        --     x = 3,
        --     y = 8,
        --     connections = {
        --         1
        --     },
        -- },
        {
            type = "quest",
            id = 41066,
            x = 3,
            y = 9,
            connections = {
                1
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 41067,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 41096,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 10,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 41069,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 41099,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 11,
            connections = {
                2,
            },
        },
        {
            type = "level",
            level = 101,
            x = 5,
            y = 11.5,
            connections = {
                1
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 44087,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 42666,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            breadcrumb = true,
            x = 3,
            y = 12,
            connections = {
                1,
            },
        },


        {
            variations = {
                {
                    type = "quest",
                    id = 42671,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 42670,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 13,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 42677,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 44161,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 14,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 42679,
            x = 3,
            y = 15,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42681,
            x = 3,
            y = 16,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42683,
            x = 3,
            y = 17,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42682,
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
            id = 37447,
            x = 3,
            y = 19,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42510,
            x = 3,
            y = 20,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42522,
            x = 3,
            y = 21,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42593,
            x = 3,
            y = 22,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42594,
            x = 3,
            y = 23,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42801,
            x = 3,
            y = 24,
            connections = {
                1
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 42921,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 42634,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 25,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 42665,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 39741,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 26,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 42131,
            x = 2,
            y = 27,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42802,
            x = 4,
            y = 27,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42731,
            x = 2,
            y = 28,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 42808,
            x = 4,
            y = 28,
            connections = {
                2
            },
        },



        {
            type = "level",
            level = 45,
            x = 6,
            y = 28.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42787,
            x = 3,
            y = 29,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42735,
            x = 3,
            y = 30,
            connections = {
                1, 2, 3, 4
            },
        },
        {
            type = "quest",
            id = 42736,
            visible = {
                {
                    type = "quest",
                    id = 42736,
                    active = false,
                }
            },
            x = 3,
            y = 31,
            connections = {
                4
            },
        },
        {
            type = "quest",
            id = 42737,
            visible = {
                {
                    type = "quest",
                    id = 42736,
                    active = true,
                }
            },
            x = 1,
            y = 31,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 42739,
            visible = {
                {
                    type = "quest",
                    id = 42736,
                    active = true,
                }
            },
            x = 3,
            y = 31,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42738,
            visible = {
                {
                    type = "quest",
                    id = 42736,
                    active = true,
                }
            },
            x = 5,
            y = 31,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42749,
            x = 3,
            y = 32,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42752,
            x = 3,
            y = 33,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42775,
            x = 3,
            y = 34,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42776,
            x = 3,
            y = 35,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 42669,
            x = 2,
            y = 36,
            connections = {
                2, 3
            },
        },
        {
            type = "quest",
            id = 44694,
            x = 4,
            y = 36,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 42733,
            x = 2,
            y = 37,
            connections = {
                2
            },
        },
        -- {
        --     type = "quest",
        --     id = 44616,
        --     x = 4,
        --     y = 37,
        --     connections = {
        --         1
        --     },
        -- },
        {
            type = "quest",
            id = 42732,
            x = 4,
            y = 37,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42754,
            x = 3,
            y = 38,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42810,
            x = 3,
            y = 39,
            connections = {
                1
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 42920,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40374,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 42809,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40375,
                        },
                    },
                },
            },
            x = 3,
            y = 40,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 42132,
            x = 3,
            y = 41,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43186,
            x = 3,
            y = 42,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 44214,
            x = 2,
            y = 43,
        },
        {
            type = "quest",
            id = 43412,
            x = 4,
            y = 43,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_FOLLOWER, {
    name = { -- Champion: Lady S'theno
		type = "quest",
		id = 45391,
	},
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_DEMONHUNTER,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FOLLOWER,
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
            id = BTWQUESTS_CLASS_ID_DEMONHUNTER,
        },
    },
    completed = {
        type = "quest",
        id = 45391,
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
            id = 46159,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45301,
            x = 3,
            y = 2,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 45330,
            x = 2,
            y = 3,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45329,
            x = 4,
            y = 3,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 45339,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45385,
            x = 3,
            y = 5,
            connections = {
                1, 2, 3
            },
        },


        {
            type = "quest",
            id = 45764,
            x = 1,
            y = 6,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 46725,
            x = 3,
            y = 6,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45798,
            x = 5,
            y = 6,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 46266,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45391,
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
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_MOUNT, {
    name = L["BTWQUESTS_DEMONHUNTER_MOUNT"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_DEMONHUNTER,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_MOUNT,
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
            id = BTWQUESTS_CLASS_ID_DEMONHUNTER,
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
        id = 46334,
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
            id = 46334,
            x = 3,
            y = 1,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_CLASSES_DEMONHUNTER, {
    name = LOCALIZED_CLASS_NAMES_MALE["DEMONHUNTER"],
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DEATHKNIGHT,
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
            id = BTWQUESTS_CLASS_ID_DEMONHUNTER,
        }
    },
    -- buttonImage = 1041999,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_STARTING_ZONE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_CAMPAIGN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_FOLLOWER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_MOUNT,
        },
    },
})